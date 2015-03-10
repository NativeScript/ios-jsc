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
#include "SymbolLoader.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const ClassInfo TypeFactory::s_info = { "TypeFactory", 0, 0, 0, CREATE_METHOD_TABLE(TypeFactory) };

ObjCBlockType* TypeFactory::parseBlockType(GlobalObject* globalObject, Metadata::MetaFileOffset& cursor) {
    uint8_t encodingCount = getMetadata()->moveInHeap(cursor++)->readByte();
    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, cursor);
    const WTF::Vector<JSCell*> parameterTypes = globalObject->typeFactory()->parseTypes(globalObject, cursor, encodingCount - 1);
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

JSCell* TypeFactory::parseFunctionReferenceType(GlobalObject* globalObject, Metadata::MetaFileOffset& cursor) {
    uint8_t encodingCount = getMetadata()->moveInHeap(cursor++)->readByte();
    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, cursor);
    const WTF::Vector<JSCell*> parameterTypes = globalObject->typeFactory()->parseTypes(globalObject, cursor, encodingCount - 1);
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

    const StructMeta* structInfo = static_cast<const StructMeta*>(getMetadata()->findMeta(structName.utf8().data()));
    ASSERT(structInfo);

    MetaFileOffset cursor = structInfo->fieldsEncodingsOffset();
    fieldsTypes = parseTypes(globalObject, cursor, structInfo->fieldsCount());

    for (unsigned int i = 0; i < structInfo->fieldsCount(); i++) {
        fieldsNames.append(WTF::ASCIILiteral(structInfo->fieldAt(i)));
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

RecordConstructor* TypeFactory::getAnonymousStructConstructor(GlobalObject* globalObject, Metadata::MetaFileOffset& cursor) {
    ffi_type* ffiType = new ffi_type({ .size = 0,
                                       .alignment = 0,
                                       .type = FFI_TYPE_STRUCT });

    VM& vm = globalObject->vm();

    // Handle linked list structures
    RecordPrototype* recordPrototype = RecordPrototype::create(vm, globalObject, _recordPrototypeStructure.get());
    RecordConstructor* constructor = RecordConstructor::create(vm, globalObject, _recordConstructorStructure.get(), recordPrototype, "?", ffiType, RecordType::Struct);
    recordPrototype->putDirect(vm, vm.propertyNames->constructor, constructor, DontEnum);

    WTF::Vector<JSCell*> fieldsTypes;
    WTF::Vector<WTF::String> fieldsNames;

    Byte fieldCount = getMetadata()->moveInHeap(cursor++)->readByte();

    for (int i = 0; i < fieldCount; ++i) {
        fieldsNames.append(WTF::ASCIILiteral(getMetadata()->moveInHeap(cursor)->follow()->readString()));
        cursor += sizeof(MetaFileOffset); // advance cursor with one metafileoffset
    }

    fieldsTypes = parseTypes(globalObject, cursor, fieldCount);

    WTF::Vector<RecordField*> fields = createRecordFields(globalObject, fieldsTypes, fieldsNames, ffiType);
    recordPrototype->setFields(vm, globalObject, fields);

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

        delete[] ffiType -> elements;
        ffiType->elements = new ffi_type* [flattenedFfiTypes.size() + 1];
        memcpy(ffiType->elements, flattenedFfiTypes.data(), flattenedFfiTypes.size() * sizeof(ffi_type*));
        ffiType->elements[flattenedFfiTypes.size()] = nullptr;
    }
#endif

    return fields;
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

    Class klass = objc_getClass(klassNameCharPtr);
    if (!klass) {
        SymbolLoader::instance().ensureFramework(metadata->framework());
        klass = objc_getClass(klassNameCharPtr);
    }

    Structure* constructorStructure = ObjCConstructorNative::createStructure(vm, globalObject, parentConstructor);
    ObjCConstructorNative* constructor = ObjCConstructorNative::create(vm, globalObject, constructorStructure, prototype, klass, metadata);
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

JSC::JSCell* TypeFactory::parseType(GlobalObject* globalObject, Metadata::MetaFileOffset& cursor) {
    BinaryTypeEncodingType encodingType = (BinaryTypeEncodingType)getMetadata()->moveInHeap(cursor++)->readByte();

    switch (encodingType) {
    case BinaryTypeEncodingType::VoidEncoding:
        return this->_voidType.get();
    case BinaryTypeEncodingType::BoolEncoding:
        return this->_boolType.get();
    case BinaryTypeEncodingType::ShortEncoding:
        return this->_int16Type.get();
    case BinaryTypeEncodingType::UShortEncoding:
        return this->_uint16Type.get();
    case BinaryTypeEncodingType::IntEncoding:
        return this->_int32Type.get();
    case BinaryTypeEncodingType::UIntEncoding:
        return this->_uint32Type.get();
    case BinaryTypeEncodingType::LongEncoding:
#if defined(__LP64__)
        COMPILE_ASSERT(sizeof(long) == sizeof(int64_t), "sizeof long");
        return this->_int64Type.get();
#else
        COMPILE_ASSERT(sizeof(long) == sizeof(int32_t), "sizeof long");
        return this->_int32Type.get();
#endif
    case BinaryTypeEncodingType::ULongEncoding:
#if defined(__LP64__)
        COMPILE_ASSERT(sizeof(unsigned long) == sizeof(uint64_t), "sizeof ulong");
        return this->_uint64Type.get();
#else
        COMPILE_ASSERT(sizeof(unsigned long) == sizeof(uint32_t), "sizeof ulong");
        return this->_uint32Type.get();
#endif
    case BinaryTypeEncodingType::LongLongEncoding:
        return this->_int64Type.get();
    case BinaryTypeEncodingType::ULongLongEncoding:
        return this->_uint64Type.get();
    case BinaryTypeEncodingType::CharEncoding:
        return this->_int8Type.get();
    case BinaryTypeEncodingType::UCharEncoding:
        return this->_uint8Type.get();
    case BinaryTypeEncodingType::UnicharEncoding:
        return this->_unicharType.get();
    case BinaryTypeEncodingType::CStringEncoding:
        return this->_utf8CStringType.get();
    case BinaryTypeEncodingType::FloatEncoding:
        return this->_floatType.get();
    case BinaryTypeEncodingType::DoubleEncoding:
        return this->_doubleType.get();
    case BinaryTypeEncodingType::InterfaceDeclarationReference: {
        WTF::String declarationName = WTF::String(getMetadata()->moveInHeap(cursor)->follow()->readString());
        cursor += sizeof(MetaFileOffset); // advance cursor with one metafileoffset
        return getObjCNativeConstructor(globalObject, declarationName);
    }
    case BinaryTypeEncodingType::StructDeclarationReference: {
        WTF::String declarationName = WTF::String(getMetadata()->moveInHeap(cursor)->follow()->readString());
        cursor += sizeof(MetaFileOffset); // advance cursor with one metafileoffset
        return this->getStructConstructor(globalObject, declarationName);
    }
    case BinaryTypeEncodingType::UnionDeclarationReference: {
        cursor += sizeof(MetaFileOffset); // advance cursor with one metafileoffset
        return this->_noopType.get(); // unions are not supported
    }
    case BinaryTypeEncodingType::InterfaceDeclarationEncoding:
        return this->_noopType.get(); // Not supported
    case BinaryTypeEncodingType::PointerEncoding: {
        JSCell* innerType = this->parseType(globalObject, cursor);
        if (innerType == this->_voidType.get()) {
            return this->_pointerConstructor.get();
        }
        return this->getReferenceType(globalObject, innerType);
    }
    case BinaryTypeEncodingType::VaListEncoding:
        return this->_noopType.get(); // Not supported
    case BinaryTypeEncodingType::SelectorEncoding:
        return this->_objCSelectorType.get();
    case BinaryTypeEncodingType::ClassEncoding:
        return this->_objCClassType.get();
    case BinaryTypeEncodingType::ProtocolEncoding:
        return this->_objCProtocolType.get();
    case BinaryTypeEncodingType::InstanceTypeEncoding:
        return this->_objCInstancetypeType.get();
    case BinaryTypeEncodingType::IdEncoding:
        return this->NSObjectConstructor(globalObject);
    case BinaryTypeEncodingType::ConstantArrayEncoding: {
        cursor += sizeof(MetaArrayCount); // skip array count
        JSCell* innerType = this->parseType(globalObject, cursor);
        return this->getReferenceType(globalObject, innerType);
    };
    case BinaryTypeEncodingType::IncompleteArrayEncoding: {
        JSCell* innerType = this->parseType(globalObject, cursor);
        return this->getReferenceType(globalObject, innerType);
    };
    case BinaryTypeEncodingType::FunctionPointerEncoding:
        return this->parseFunctionReferenceType(globalObject, cursor);
    case BinaryTypeEncodingType::BlockEncoding:
        return this->parseBlockType(globalObject, cursor);
    case BinaryTypeEncodingType::AnonymousStructEncoding:
        return this->getAnonymousStructConstructor(globalObject, cursor);
    case BinaryTypeEncodingType::AnonymousUnionEncodingn:
        return this->_noopType.get(); // unions are not supported
    default:
        ASSERT_NOT_REACHED(); // Unknown type encoding
    }

    return nullptr;
}

const WTF::Vector<JSC::JSCell*> TypeFactory::parseTypes(GlobalObject* globalObject, Metadata::MetaFileOffset& cursor, Byte count) {
    WTF::Vector<JSCell*> types;
    for (Byte i = 0; i < count; i++) {
        types.append(parseType(globalObject, cursor));
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
