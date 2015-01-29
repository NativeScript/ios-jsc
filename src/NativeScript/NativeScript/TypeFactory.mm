//
//  TypeFactory.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 13.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "TypeFactory.h"
#include <string>
#include <JavaScriptCore/FunctionPrototype.h>
#include "Metadata.h"
#include "FFISimpleType.h"
#include "FFIPrimitiveTypes.h"
#include "FFINumericTypes.h"
#include "ReferenceTypeInstance.h"
#include "ObjCConstructorNative.h"
#include "ObjCPrototype.h"
#include "ObjCPrimitiveTypes.h"
#include "ObjCBlockType.h"
#include "FunctionReferenceTypeInstance.h"
#include "ReferenceInstance.h"
#include "RecordConstructor.h"
#include "RecordPrototype.h"
#include "RecordField.h"
#include "PointerConstructor.h"
#include "PointerPrototype.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

static WTF::String extractNestedTypeEncoding(const char* typeEncoding, char initiator, char terminator, ptrdiff_t* consumed) {
    ASSERT(initiator != terminator);

    unsigned openingsFound = 0;
    unsigned i = 0;
    do {
        if (typeEncoding[i] == initiator) {
            openingsFound++;
        } else if (typeEncoding[i] == terminator) {
            openingsFound--;
        }

        i++;
    } while (openingsFound > 0);

    if (consumed) {
        *consumed = i;
    }

    return WTF::String(typeEncoding + 1, i - 2);
}

const ClassInfo TypeFactory::s_info = { "TypeFactory", 0, 0, 0, CREATE_METHOD_TABLE(TypeFactory) };

void TypeFactory::extractInlinedRecordEncoding(GlobalObject* globalObject, const char* start, WTF::Vector<JSCell*>& fieldsTypes, WTF::Vector<WTF::String>& fieldsNames) {
    const char* cursor = start;
    int bracketLevel = 0;
    while (bracketLevel != 0 || *cursor != ',') {
        if (*cursor == '{' || *cursor == '(') {
            bracketLevel++;
        } else if (*cursor == '}' || *cursor == ')') {
            bracketLevel--;
        }
        cursor++;
    }
    // parse fields encodings
    size_t length = cursor - start;
    char* fieldsEncodings = (char*)malloc(sizeof(char) * (length + 1));
    memcpy(fieldsEncodings, start, length);
    *(fieldsEncodings + length) = '\0';
    fieldsTypes = parseTypes(globalObject, fieldsEncodings);
    free(fieldsEncodings);
    // extract fields names
    while (fieldsNames.size() < fieldsTypes.size()) {
        start = cursor + 1;
        cursor = start;
        while (*cursor != ',') {
            cursor++;
        }
        fieldsNames.append(WTF::String(start, cursor - start));
    }
}

ObjCBlockType* TypeFactory::parseBlockType(GlobalObject* globalObject, const char* typeEncoding, ptrdiff_t* consumed) {
    WTF::String nestedTypeEncoding = extractNestedTypeEncoding(typeEncoding, '%', '|', consumed);

    ptrdiff_t local_consumed;
    CString nestedTypeEncodingUTF8 = nestedTypeEncoding.utf8();
    JSCell* returnType = parseType(globalObject, nestedTypeEncodingUTF8.data(), &local_consumed);
    WTF::Vector<JSCell*> parameterTypes = parseTypes(globalObject, nestedTypeEncodingUTF8.data() + local_consumed);

    return this->getObjCBlockType(globalObject, returnType, parameterTypes);
}

ObjCBlockType* TypeFactory::getObjCBlockType(GlobalObject* globalObject, JSCell* returnType, WTF::Vector<JSCell*> parametersTypes) {
    WTF::Vector<JSC::WeakImpl*> weakParametersTypes;
    weakParametersTypes.append(WeakSet::allocate(JSValue(returnType))); // add return value
    for (size_t i = 0; i < parametersTypes.size(); i++) {
        weakParametersTypes.append(WeakSet::allocate(JSValue(parametersTypes[i])));
    }

    if (this->_cacheObjCBlockType.contains(weakParametersTypes)) {
        WeakImpl* value = this->_cacheObjCBlockType.get(weakParametersTypes);
        if (value->state() == WeakImpl::State::Live) {
            return static_cast<ObjCBlockType*>(value->jsValue().asCell());
        } else {
            this->_cacheObjCBlockType.remove(weakParametersTypes);
        }
    }

    ObjCBlockType* result = ObjCBlockType::create(globalObject->vm(), this->_objCBlockTypeStructure.get(), returnType, parametersTypes);
    WeakImpl* resultWeak = WeakSet::allocate(JSValue(result));
    this->_cacheObjCBlockType.add(weakParametersTypes, resultWeak);
    return result;
}

JSCell* TypeFactory::parseFunctionReferenceType(GlobalObject* globalObject, const char* typeEncoding, ptrdiff_t* consumed) {
    WTF::String nestedTypeEncoding = extractNestedTypeEncoding(typeEncoding, '/', '|', consumed);

    ptrdiff_t local_consumed;
    CString nestedTypeEncodingUTF8 = nestedTypeEncoding.utf8();
    JSCell* returnType = parseType(globalObject, nestedTypeEncodingUTF8.data(), &local_consumed);
    WTF::Vector<JSCell*> parameterTypes = parseTypes(globalObject, nestedTypeEncodingUTF8.data() + local_consumed);

    return this->getFunctionReferenceTypeInstance(globalObject, returnType, parameterTypes);
}

FunctionReferenceTypeInstance* TypeFactory::getFunctionReferenceTypeInstance(GlobalObject* globalObject, JSCell* returnType, WTF::Vector<JSCell*> parametersTypes) {
    WTF::Vector<JSC::WeakImpl*> weakParametersTypes;
    weakParametersTypes.append(WeakSet::allocate(JSValue(returnType))); // add return value
    for (size_t i = 0; i < parametersTypes.size(); i++) {
        weakParametersTypes.append(WeakSet::allocate(JSValue(parametersTypes[i])));
    }

    if (this->_cacheFunctionReferenceType.contains(weakParametersTypes)) {
        WeakImpl* value = this->_cacheFunctionReferenceType.get(weakParametersTypes);
        if (value->state() == WeakImpl::State::Live) {
            return jsDynamicCast<FunctionReferenceTypeInstance*>(value->jsValue().asCell());
        } else {
            this->_cacheFunctionReferenceType.remove(weakParametersTypes);
        }
    }

    FunctionReferenceTypeInstance* result = FunctionReferenceTypeInstance::create(globalObject->vm(), this->_functionReferenceTypeStructure.get(), returnType, parametersTypes);
    WeakImpl* resultWeak = WeakSet::allocate(JSValue(result));
    this->_cacheFunctionReferenceType.add(weakParametersTypes, resultWeak);
    return result;
}

// TODO: Create array types
JSCell* TypeFactory::parseArrayType(GlobalObject* globalObject, const char* typeEncoding, ptrdiff_t* consumed) {
    WTF::String nestedTypeEncoding = extractNestedTypeEncoding(typeEncoding, _C_ARY_B, _C_ARY_E, consumed);
    // if (JSCell* type = _cacheArray.get(nestedTypeEncoding)) {
    //     return type;
    // }

    size_t typeOffset = 0;
    size_t length = 0;
    if (WTF::isASCIIDigit(nestedTypeEncoding.at(0))) {
        length = std::stoi(nestedTypeEncoding.utf8().data(), &typeOffset);
    }
    UNUSED_PARAM(length);

    WTF::String referenceEncoding = WTF::String::format("^%s", nestedTypeEncoding.utf8().data() + typeOffset);
    return parseReferenceType(globalObject, referenceEncoding.utf8().data(), nullptr);
}

RecordConstructor* TypeFactory::getStructConstructor(GlobalObject* globalObject, const WTF::String& structName) {
    if (RecordConstructor* constructor = this->_cacheStruct.get(structName)) {
        return constructor;
    }

    ffi_type* ffiType = new ffi_type({ .size = 0,
                                       .alignment = 0,
                                       .type = FFI_TYPE_STRUCT });

    VM& vm = globalObject->vm();

    // Handle linked list structures
    RecordPrototype* recordPrototype = RecordPrototype::create(vm, globalObject, _recordPrototypeStructure.get());
    RecordConstructor* constructor = RecordConstructor::create(vm, globalObject, _recordConstructorStructure.get(), recordPrototype, structName, ffiType, RecordType::Struct);
    recordPrototype->putDirect(vm, vm.propertyNames->constructor, constructor, DontEnum);

    auto addResult = this->_cacheStruct.add(structName, constructor);
    if (!addResult.isNewEntry) {
        ASSERT_NOT_REACHED();
    }

    WTF::Vector<JSCell*> fieldsTypes;
    WTF::Vector<WTF::String> fieldsNames;

    if (structName.length() >= 2 && structName.at(0) == '?' && structName.at(1) == '=') {
        extractInlinedRecordEncoding(globalObject, structName.utf8().data() + 2, fieldsTypes, fieldsNames);
    } else {
        const StructMeta* info = static_cast<const StructMeta*>(getMetadata()->findMeta(structName.utf8().data()));
        ASSERT(info);

        fieldsTypes = parseTypes(globalObject, info->fieldsEncodings());

        for (int i = 0; i < info->fieldsCount(); i++) {
            fieldsNames.append(WTF::ASCIILiteral(info->fieldAt(i)));
        }
    }

    WTF::Vector<RecordField*> fields = createRecordFields(globalObject, fieldsTypes, fieldsNames, ffiType);
    recordPrototype->setFields(vm, globalObject, fields);

    // This could already be initialized at this point.
    if (RecordConstructor* constructor = this->_cacheStruct.get(structName)) {
        return constructor;
    }

    addResult = this->_cacheStruct.add(structName, constructor);
    if (!addResult.isNewEntry) {
        ASSERT_NOT_REACHED();
    }
    return constructor;
}

WTF::Vector<RecordField*> TypeFactory::createRecordFields(GlobalObject* globalObject, const WTF::Vector<JSCell*>& fieldsTypes, const WTF::Vector<WTF::String>& fieldsNames, ffi_type* ffiType) {
    ASSERT(fieldsNames.size() == fieldsTypes.size());

    VM& vm = globalObject->vm();

    ffiType->elements = new ffi_type* [fieldsTypes.size() + 1];
#if defined(__x86_64__)
    bool hasNestedStruct = false;
#endif
    WTF::Vector<RecordField*> fields;
    for (size_t i = 0; i < fieldsTypes.size(); i++) {
        const ffi_type* fieldFFIType = getFFITypeMethodTable(fieldsTypes[i]).ffiType;
#if defined(__x86_64__)
        hasNestedStruct = hasNestedStruct || (fieldFFIType->type == FFI_TYPE_STRUCT);
#endif
        ffiType->elements[i] = const_cast<ffi_type*>(fieldFFIType);

        size_t offset = ffiType->size;
        unsigned short alignment = fieldFFIType->alignment;
        size_t padding = (alignment - (offset % alignment)) % alignment;

        offset += padding;
        ffiType->size = offset + fieldFFIType->size;
        ffiType->alignment = std::max(ffiType->alignment, fieldFFIType->alignment);

        RecordField* field = RecordField::create(vm, this->_recordFieldStructure.get(), fieldsNames[i], fieldsTypes[i], offset);
        fields.append(field);
    }

    ffiType->elements[fieldsTypes.size()] = nullptr;

#if defined(__x86_64__)
    /*
        If on 64-bit architecture, flatten the nested structures, because libffi can't handle them.
    */
    if (hasNestedStruct) {
        WTF::Vector<ffi_type*> flattenedFfiTypes;
        WTF::Vector<ffi_type*> stack{ ffiType }; // simulate recursion with stack (no need of other function)
        while (stack.size() > 0) {
            ffi_type* currentType = stack.takeLast();
            if (currentType->type != FFI_TYPE_STRUCT) {
                flattenedFfiTypes.append(currentType);
            } else {
                ffi_type** nullPtr = currentType->elements; // the end of elements array
                while (*nullPtr != nullptr) {
                    nullPtr++;
                }
                
                // add fields' ffi types in reverse order in the stack, so they will be popped in correct order
                for (ffi_type** field = nullPtr - 1; field >= currentType->elements; field--) {
                    stack.append(*field);
                }
            }
        }

        delete[] ffiType->elements;
        ffiType->elements = new ffi_type* [flattenedFfiTypes.size() + 1];
        memcpy(ffiType->elements, flattenedFfiTypes.data(), flattenedFfiTypes.size() * sizeof(ffi_type*));
        ffiType->elements[flattenedFfiTypes.size()] = nullptr;
    }
#endif

    return fields;
}

RecordConstructor* TypeFactory::parseStructType(GlobalObject* globalObject, const char* const typeEncoding, ptrdiff_t* consumed) {
    WTF::String structName = extractNestedTypeEncoding(typeEncoding, _C_STRUCT_B, _C_STRUCT_E, consumed);
    return getStructConstructor(globalObject, structName);
}

JSCell* TypeFactory::parseUnionType(GlobalObject* globalObject, const char* typeEncoding, ptrdiff_t* consumed) {
    extractNestedTypeEncoding(typeEncoding, _C_UNION_B, _C_UNION_E, consumed);
    return this->_noopType.get();
}

ObjCConstructorNative* TypeFactory::getObjCNativeConstructor(GlobalObject* globalObject, const WTF::String& klassName) {
    if (ObjCConstructorNative* type = this->_cacheId.get(klassName)) {
        return type;
    }

    VM& vm = globalObject->vm();
    const CString klassNameUTF8 = klassName.utf8();
    const char* klassNameCharPtr = klassNameUTF8.data();
    const InterfaceMeta* metadata = static_cast<const InterfaceMeta*>(getMetadata()->findMeta(klassNameCharPtr));
    if (!metadata) {
#if DEBUG
        NSLog(@"** Can not create constructor for \"%s\". Casting it to \"NSObject\". **", klassNameCharPtr);
#endif
        ObjCConstructorNative* nsobjectConstructor = this->NSObjectConstructor(globalObject);
        this->_cacheId.add(klassName, nsobjectConstructor);
        return nsobjectConstructor;
    }

    JSValue parentPrototype;
    JSValue parentConstructor;

    // NSObject and NSProxy don't have a base class
    const char* superKlassName = metadata->baseName();
    if (superKlassName) {
        parentConstructor = getObjCNativeConstructor(globalObject, superKlassName);
        parentPrototype = parentConstructor.get(globalObject->globalExec(), vm.propertyNames->prototype);
    } else {
        parentPrototype = globalObject->objectPrototype();
        parentConstructor = globalObject->functionPrototype();
    }

    // The parentConstructor may have already initialized the constructor.
    if (ObjCConstructorNative* type = this->_cacheId.get(klassName)) {
        return type;
    }

    Structure* prototypeStructure = ObjCPrototype::createStructure(vm, globalObject, parentPrototype);
    ObjCPrototype* prototype = ObjCPrototype::create(vm, globalObject, prototypeStructure, metadata);

    Structure* constructorStructure = ObjCConstructorNative::createStructure(vm, globalObject, parentConstructor);
    ObjCConstructorNative* constructor = ObjCConstructorNative::create(vm, globalObject, constructorStructure, prototype, objc_getClass(klassNameCharPtr), metadata);
    prototype->putDirectWithoutTransition(vm, vm.propertyNames->constructor, constructor, DontEnum | DontDelete | ReadOnly);

    auto addResult = this->_cacheId.add(klassName, constructor);
    if (!addResult.isNewEntry) {
        ASSERT_NOT_REACHED();
    }
    prototype->materializeProperties(vm, globalObject);

    return constructor;
}

ObjCConstructorNative* TypeFactory::NSObjectConstructor(GlobalObject* globalObject) {
    if (LIKELY(this->_nsObjectConstructor)) {
        return this->_nsObjectConstructor.get();
    }

    ObjCConstructorNative* constructor = getObjCNativeConstructor(globalObject, WTF::ASCIILiteral("NSObject"));
    this->_nsObjectConstructor.set(globalObject->vm(), this, constructor);
    return constructor;
}

ObjCConstructorNative* TypeFactory::parseIdType(GlobalObject* globalObject, const char* typeEncoding, ptrdiff_t* consumed) {
    if (*(typeEncoding + 1) == '"') {
        size_t closingQuoteOffset = 2;
        while (*(typeEncoding + closingQuoteOffset) != '"') {
            closingQuoteOffset++;
        }

        if (consumed) {
            *consumed = closingQuoteOffset + 1;
        }

        WTF::String className(typeEncoding + 2, closingQuoteOffset - 2);
        return getObjCNativeConstructor(globalObject, className);
    } else {
        return this->NSObjectConstructor(globalObject);
    }
}

JSCell* TypeFactory::parseReferenceType(GlobalObject* globalObject, const char* typeEncoding, ptrdiff_t* consumed) {
    ptrdiff_t local_consumed;
    JSCell* innerType = parseType(globalObject, typeEncoding + 1, &local_consumed);

    if (consumed) {
        *consumed = local_consumed + 1;
    }

    if (*(typeEncoding + 1) == 'v') {
        ASSERT(*(typeEncoding + 2) == 0);

        return this->pointerConstructor();
    }

    return getReferenceType(globalObject, innerType);
}

ReferenceTypeInstance* TypeFactory::getReferenceType(GlobalObject* globalObject, JSCell* innerType) {
    WeakImpl* innerWeak = WeakSet::allocate(JSValue(innerType));
    if (this->_cacheReferenceType.contains(innerWeak)) {
        WeakImpl* value = this->_cacheReferenceType.get(innerWeak);
        if (value->state() == WeakImpl::State::Live) {
            return static_cast<ReferenceTypeInstance*>(value->jsValue().asCell());
        } else {
            this->_cacheReferenceType.remove(innerWeak);
        }
    }

    ReferenceTypeInstance* result = ReferenceTypeInstance::create(globalObject->vm(), this->_referenceTypeStructure.get(), innerType);
    WeakImpl* resultWeak = WeakSet::allocate(JSValue(result));
    this->_cacheReferenceType.add(innerWeak, resultWeak);
    return result;
}

JSCell* TypeFactory::parseType(GlobalObject* globalObject, const char* typeEncoding, ptrdiff_t* consumed) {
    if (consumed) {
        *consumed = 1;
    }

    switch (*typeEncoding) {
    case _C_ARY_B:
        return parseArrayType(globalObject, typeEncoding, consumed);
    case _C_STRUCT_B:
        return parseStructType(globalObject, typeEncoding, consumed);
    case _C_UNION_B:
        return parseUnionType(globalObject, typeEncoding, consumed);
    case _C_PTR:
        return parseReferenceType(globalObject, typeEncoding, consumed);
    case _C_ID:
        return parseIdType(globalObject, typeEncoding, consumed);
    case '%':
        return parseBlockType(globalObject, typeEncoding, consumed);
    case '/':
        return parseFunctionReferenceType(globalObject, typeEncoding, consumed);
    case 'P':
        return this->_objCProtocolType.get();
    case '&':
        return this->_objCInstancetypeType.get();
    case _C_CLASS:
        return this->_objCClassType.get();
    case _C_SEL:
        return this->_objCSelectorType.get();
    case _C_VOID:
        return this->_voidType.get();
    case _C_BOOL:
        return this->_boolType.get();
    case _C_CHARPTR:
        return this->_utf8CStringType.get();
    case _C_CHR:
        return this->_int8Type.get();
    case _C_UCHR:
        return this->_uint8Type.get();
    case _C_SHT:
        return this->_int16Type.get();
    case _C_USHT:
        return this->_uint16Type.get();
    case 'U':
        return this->_unicharType.get();
    case _C_INT:
        return this->_int32Type.get();
    case _C_UINT:
        return this->_uint32Type.get();
    case _C_LNG:
#if defined(__LP64__)
        COMPILE_ASSERT(sizeof(long) == sizeof(int64_t), "sizeof long");
        return this->_int64Type.get();
#else
        COMPILE_ASSERT(sizeof(long) == sizeof(int32_t), "sizeof long");
        return this->_int32Type.get();
#endif
    case _C_ULNG:
#if defined(__LP64__)
        COMPILE_ASSERT(sizeof(unsigned long) == sizeof(uint64_t), "sizeof ulong");
        return this->_uint64Type.get();
#else
        COMPILE_ASSERT(sizeof(unsigned long) == sizeof(uint32_t), "sizeof ulong");
        return this->_uint32Type.get();
#endif
    case _C_LNG_LNG:
        return this->_int64Type.get();
    case _C_ULNG_LNG:
        return this->_uint64Type.get();
    case _C_FLT:
        return this->_floatType.get();
    case _C_DBL:
        return this->_doubleType.get();
    case 'D':
        return this->_noopType.get();
    case '~':
        return this->_noopType.get();
    default:
        return nullptr;
    }
}

const WTF::Vector<JSCell*> TypeFactory::parseTypes(GlobalObject* globalObject, const char* typeEncoding, ptrdiff_t* consumed) {
    WTF::Vector<JSCell*> types;
    const char* cursor = typeEncoding;

    while (*cursor != 0) {
        ptrdiff_t currentConsumed = 0;
        types.append(parseType(globalObject, cursor, &currentConsumed));
        cursor += currentConsumed;
    }

    if (consumed) {
        *consumed = cursor - typeEncoding;
    }

    return types;
}

void TypeFactory::finishCreation(VM& vm, GlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->_referenceTypeStructure.set(vm, this, ReferenceTypeInstance::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_objCBlockTypeStructure.set(vm, this, ObjCBlockType::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_functionReferenceTypeStructure.set(vm, this, FunctionReferenceTypeInstance::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_recordPrototypeStructure.set(vm, this, RecordPrototype::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_recordConstructorStructure.set(vm, this, RecordConstructor::createStructure(vm, globalObject, globalObject->functionPrototype()));
    this->_recordFieldStructure.set(vm, this, RecordField::createStructure(vm, globalObject, jsNull()));

    PointerPrototype* pointerPrototype = PointerPrototype::create(vm, globalObject, PointerPrototype::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_pointerConstructor.set(vm, this, PointerConstructor::create(vm, PointerConstructor::createStructure(vm, globalObject, globalObject->functionPrototype()), pointerPrototype));
    pointerPrototype->putDirect(vm, vm.propertyNames->constructor, this->_pointerConstructor.get(), DontEnum);

    this->_noopType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("noop"), noopTypeMethodTable));
    this->_voidType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("void"), voidTypeMethodTable));
    this->_boolType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("bool"), boolTypeMethodTable));
    this->_utf8CStringType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("UTF8CString"), utf8CStringTypeMethodTable));
    this->_unicharType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("unichar"), unicharTypeMethodTable));

    this->_int8Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("int8"), int8TypeMethodTable));
    this->_uint8Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("uint8"), uint8TypeMethodTable));
    this->_int16Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("int16"), int16TypeMethodTable));
    this->_uint16Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("uint16"), uint16TypeMethodTable));
    this->_int32Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("int32"), int32TypeMethodTable));
    this->_uint32Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("uint32"), uint32TypeMethodTable));
    this->_int64Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("int64"), int64TypeMethodTable));
    this->_uint64Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("uint64"), uint64TypeMethodTable));
    this->_floatType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("float"), floatTypeMethodTable));
    this->_doubleType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("double"), doubleTypeMethodTable));

    this->_objCInstancetypeType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("instancetype"), objCInstancetypeTypeMethodTable));
    this->_objCProtocolType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("protocol"), objCProtocolTypeMethodTable));
    this->_objCClassType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("class"), objCClassTypeMethodTable));
    this->_objCSelectorType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), WTF::ASCIILiteral("selector"), objCSelectorTypeMethodTable));
}

void TypeFactory::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    TypeFactory* typeFactory = jsCast<TypeFactory*>(cell);
    Base::visitChildren(typeFactory, visitor);

    visitor.append(&typeFactory->_referenceTypeStructure);
    visitor.append(&typeFactory->_objCBlockTypeStructure);
    visitor.append(&typeFactory->_functionReferenceTypeStructure);
    visitor.append(&typeFactory->_recordPrototypeStructure);
    visitor.append(&typeFactory->_recordConstructorStructure);
    visitor.append(&typeFactory->_recordFieldStructure);

    visitor.append(&typeFactory->_noopType);
    visitor.append(&typeFactory->_voidType);
    visitor.append(&typeFactory->_boolType);
    visitor.append(&typeFactory->_utf8CStringType);
    visitor.append(&typeFactory->_unicharType);

    visitor.append(&typeFactory->_int8Type);
    visitor.append(&typeFactory->_uint8Type);
    visitor.append(&typeFactory->_int16Type);
    visitor.append(&typeFactory->_uint16Type);
    visitor.append(&typeFactory->_int32Type);
    visitor.append(&typeFactory->_uint32Type);
    visitor.append(&typeFactory->_int64Type);
    visitor.append(&typeFactory->_uint64Type);
    visitor.append(&typeFactory->_floatType);
    visitor.append(&typeFactory->_doubleType);

    visitor.append(&typeFactory->_objCInstancetypeType);
    visitor.append(&typeFactory->_objCProtocolType);
    visitor.append(&typeFactory->_objCClassType);
    visitor.append(&typeFactory->_objCSelectorType);

    visitor.append(&typeFactory->_nsObjectConstructor);
    visitor.append(&typeFactory->_pointerConstructor);
}
}
