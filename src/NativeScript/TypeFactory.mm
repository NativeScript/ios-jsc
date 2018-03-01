//
//  TypeFactory.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 13.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "TypeFactory.h"
#include "FFINumericTypes.h"
#include "FFIPrimitiveTypes.h"
#include "FFISimpleType.h"
#include "FunctionReferenceTypeInstance.h"
#include "ManualInstrumentation.h"
#include "Metadata.h"
#include "ObjCBlockType.h"
#include "ObjCConstructorNative.h"
#include "ObjCPrimitiveTypes.h"
#include "ObjCPrototype.h"
#include "PointerConstructor.h"
#include "PointerPrototype.h"
#include "RecordConstructor.h"
#include "RecordField.h"
#include "RecordPrototype.h"
#include "ReferenceInstance.h"
#include "ReferenceTypeInstance.h"
#include "SymbolLoader.h"
#include <JavaScriptCore/FunctionPrototype.h>
#include <string>

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const ClassInfo TypeFactory::s_info = { "TypeFactory", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(TypeFactory) };

ObjCBlockType* TypeFactory::parseBlockType(GlobalObject* globalObject, const TypeEncodingsList<uint8_t>& typeEncodings) {
    const TypeEncoding* typeEncodingPtr = typeEncodings.first();
    JSCell* returnType = this->parseType(globalObject, typeEncodingPtr);
    const WTF::Vector<JSCell*> parameters = this->parseTypes(globalObject, typeEncodingPtr, typeEncodings.count - 1);
    return this->getObjCBlockType(globalObject, returnType, parameters);
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

JSCell* TypeFactory::parseFunctionReferenceType(GlobalObject* globalObject, const TypeEncodingsList<uint8_t>& typeEncodings) {
    const TypeEncoding* typeEncodingPtr = typeEncodings.first();
    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, typeEncodingPtr);
    const WTF::Vector<JSCell*> parameterTypes = globalObject->typeFactory()->parseTypes(globalObject, typeEncodingPtr, typeEncodings.count - 1);
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
            return jsDynamicCast<FunctionReferenceTypeInstance*>(globalObject->vm(), value->jsValue().asCell());
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

    auto addResult = this->_cacheStruct.set(structName, constructor);
    if (!addResult.isNewEntry) {
        ASSERT_NOT_REACHED();
    }

    WTF::Vector<JSCell*> fieldsTypes;
    WTF::Vector<WTF::String> fieldsNames;

    const StructMeta* structInfo = static_cast<const StructMeta*>(MetaFile::instance()->globalTable()->findMeta(structName.impl()));
    ASSERT(structInfo && structInfo->type() == MetaType::Struct);

    const TypeEncoding* encodingsPtr = structInfo->fieldsEncodings()->first();
    fieldsTypes = parseTypes(globalObject, encodingsPtr, structInfo->fieldsEncodings()->count);

    for (Array<Metadata::String>::iterator it = structInfo->fieldNames().begin(); it != structInfo->fieldNames().end(); it++) {
        fieldsNames.append(WTF::ASCIILiteral((*it).valuePtr()));
    }

    WTF::Vector<RecordField*> fields = createRecordFields(globalObject, fieldsTypes, fieldsNames, ffiType);
    recordPrototype->setFields(vm, globalObject, fields);

    // This could already be initialized at this point.
    if (RecordConstructor* constructor = this->_cacheStruct.get(structName)) {
        return constructor;
    }

    addResult = this->_cacheStruct.set(structName, constructor);
    if (!addResult.isNewEntry) {
        ASSERT_NOT_REACHED();
    }
    return constructor;
}

RecordConstructor* TypeFactory::getAnonymousStructConstructor(GlobalObject* globalObject, const Metadata::TypeEncodingDetails::AnonymousRecordDetails& details) {
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

    for (int i = 0; i < details.fieldsCount; ++i) {
        const Metadata::String* currentName = details.getFieldNames() + i;
        fieldsNames.append(WTF::ASCIILiteral(currentName->valuePtr()));
    }

    const TypeEncoding* encodingsPtr = details.getFieldsEncodings();
    fieldsTypes = parseTypes(globalObject, encodingsPtr, details.fieldsCount);

    WTF::Vector<RecordField*> fields = createRecordFields(globalObject, fieldsTypes, fieldsNames, ffiType);
    recordPrototype->setFields(vm, globalObject, fields);

    return constructor;
}

WTF::Vector<RecordField*> TypeFactory::createRecordFields(GlobalObject* globalObject, const WTF::Vector<JSCell*>& fieldsTypes, const WTF::Vector<WTF::String>& fieldsNames, ffi_type* ffiType) {
    DeferGCForAWhile deferGC(globalObject->vm().heap);

    ASSERT(fieldsNames.size() == fieldsTypes.size());

    VM& vm = globalObject->vm();

    ffiType->elements = new ffi_type*[fieldsTypes.size() + 1];
#if defined(__x86_64__)
    bool hasNestedStruct = false;
#endif
    WTF::Vector<RecordField*> fields;
    for (size_t i = 0; i < fieldsTypes.size(); i++) {
        const ffi_type* fieldFFIType = getFFITypeMethodTable(vm, fieldsTypes[i]).ffiType;
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
        ffiType->elements = new ffi_type*[flattenedFfiTypes.size() + 1];
        memcpy(ffiType->elements, flattenedFfiTypes.data(), flattenedFfiTypes.size() * sizeof(ffi_type*));
        ffiType->elements[flattenedFfiTypes.size()] = nullptr;
    }
#endif

    return fields;
}

ObjCConstructorNative* TypeFactory::getObjCNativeConstructor(GlobalObject* globalObject, const WTF::String& klassName) {
    tns::instrumentation::Frame frame;
    if (ObjCConstructorNative* type = this->_cacheId.get(klassName)) {
        return type;
    }

    VM& vm = globalObject->vm();

    const InterfaceMeta* metadata = static_cast<const InterfaceMeta*>(MetaFile::instance()->globalTable()->findMeta(klassName.impl()));
    Class klass = Nil;

    if (metadata) {
        klass = objc_getClass(metadata->name());
        if (!klass) {
            SymbolLoader::instance().ensureModule(metadata->topLevelModule());
            klass = objc_getClass(metadata->name());
        }
    }

    if (!metadata || !klass) {
#ifdef DEBUG
        NSLog(@"** Can not create constructor for \"%@\". Casting it to \"NSObject\". **", klassName.createCFString().autorelease());
#endif
        ObjCConstructorNative* nsobjectConstructor = this->NSObjectConstructor(globalObject);
        this->_cacheId.set(klassName, nsobjectConstructor);
        return nsobjectConstructor;
    }

    JSValue parentPrototype;
    JSValue parentConstructor;

    const char* superKlassName = metadata->baseName();
    if (superKlassName) {
        parentConstructor = getObjCNativeConstructor(globalObject, superKlassName);
        parentPrototype = parentConstructor.get(globalObject->globalExec(), vm.propertyNames->prototype);
    } else {
        // NSObject and NSProxy don't have a base class and therefore inherit directly from GlobalObject.
        parentPrototype = globalObject->objectPrototype();
        parentConstructor = globalObject->functionPrototype();
    }

    // The parentConstructor may have already initialized our constructor.
    /// If we have a super class which somehow references us we will already be cached when
    /// the parent constructor has been created.
    /// TODO: Move this check in the if (superKlassName) case.
    if (ObjCConstructorNative* type = this->_cacheId.get(klassName)) {
        return type;
    }

    Structure* prototypeStructure = ObjCPrototype::createStructure(vm, globalObject, parentPrototype);
    ObjCPrototype* prototype = ObjCPrototype::create(vm, globalObject, prototypeStructure, metadata);

    Structure* constructorStructure = ObjCConstructorNative::createStructure(vm, globalObject, parentConstructor);
    ObjCConstructorNative* constructor = ObjCConstructorNative::create(vm, globalObject, constructorStructure, prototype, klass);
    prototype->putDirectWithoutTransition(vm, vm.propertyNames->constructor, constructor, DontEnum | DontDelete | ReadOnly);

    auto addResult = this->_cacheId.set(klassName, constructor);
    if (!addResult.isNewEntry) {
        ASSERT_NOT_REACHED();
    }
    prototype->materializeProperties(vm, globalObject);
    constructor->materializeProperties(vm, globalObject);

    if (frame.check()) {
        NSString* classNameNSStr = (NSString*)klassName.createCFString().get();
        frame.log([@"Expose: " stringByAppendingString:classNameNSStr].UTF8String);
    }

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

IndexedRefTypeInstance* TypeFactory::getIndexedRefType(GlobalObject* globalObject, JSCell* innerType, size_t typeSize) {
    WeakImpl* innerWeak = WeakSet::allocate(JSValue(innerType));
    if (this->_cacheReferenceType.contains(innerWeak)) {
        WeakImpl* value = this->_cacheReferenceType.get(innerWeak);
        if (value->state() == WeakImpl::State::Live) {
            return static_cast<IndexedRefTypeInstance*>(value->jsValue().asCell());
        } else {
            this->_cacheReferenceType.remove(innerWeak);
        }
    }

    IndexedRefTypeInstance* result = IndexedRefTypeInstance::create(globalObject->vm(), this->_indexedRefTypeStructure.get(), innerType, typeSize);
    return result;
}

ExtVectorTypeInstance* TypeFactory::getExtVectorType(GlobalObject* globalObject, JSCell* innerType, size_t typeSize) {
    WeakImpl* innerWeak = WeakSet::allocate(JSValue(innerType));
    if (this->_cacheReferenceType.contains(innerWeak)) {
        WeakImpl* value = this->_cacheReferenceType.get(innerWeak);
        if (value->state() == WeakImpl::State::Live) {
            return static_cast<ExtVectorTypeInstance*>(value->jsValue().asCell());
        } else {
            this->_cacheReferenceType.remove(innerWeak);
        }
    }

    ExtVectorTypeInstance* result = ExtVectorTypeInstance::create(globalObject->vm(), this->_extVectorTypeStructure.get(), innerType, typeSize);
    return result;
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

JSC::JSCell* TypeFactory::parseType(GlobalObject* globalObject, const Metadata::TypeEncoding*& typeEncoding) {
    DeferGCForAWhile deferGC(globalObject->vm().heap);

    JSC::JSCell* result = nullptr;

    switch (typeEncoding->type) {
    case BinaryTypeEncodingType::VoidEncoding:
        result = this->_voidType.get();
        break;
    case BinaryTypeEncodingType::BoolEncoding:
        result = this->_boolType.get();
        break;
    case BinaryTypeEncodingType::ShortEncoding:
        result = this->_int16Type.get();
        break;
    case BinaryTypeEncodingType::UShortEncoding:
        result = this->_uint16Type.get();
        break;
    case BinaryTypeEncodingType::IntEncoding:
        result = this->_int32Type.get();
        break;
    case BinaryTypeEncodingType::UIntEncoding:
        result = this->_uint32Type.get();
        break;
    case BinaryTypeEncodingType::LongEncoding:
#if defined(__LP64__)
        COMPILE_ASSERT(sizeof(long) == sizeof(int64_t), "sizeof long");
        result = this->_int64Type.get();
#else
        COMPILE_ASSERT(sizeof(long) == sizeof(int32_t), "sizeof long");
        result = this->_int32Type.get();
#endif
        break;
    case BinaryTypeEncodingType::ULongEncoding:
#if defined(__LP64__)
        COMPILE_ASSERT(sizeof(unsigned long) == sizeof(uint64_t), "sizeof ulong");
        result = this->_uint64Type.get();
#else
        COMPILE_ASSERT(sizeof(unsigned long) == sizeof(uint32_t), "sizeof ulong");
        result = this->_uint32Type.get();
#endif
        break;
    case BinaryTypeEncodingType::LongLongEncoding:
        result = this->_int64Type.get();
        break;
    case BinaryTypeEncodingType::ULongLongEncoding:
        result = this->_uint64Type.get();
        break;
    case BinaryTypeEncodingType::CharEncoding:
        result = this->_int8Type.get();
        break;
    case BinaryTypeEncodingType::UCharEncoding:
        result = this->_uint8Type.get();
        break;
    case BinaryTypeEncodingType::UnicharEncoding:
        result = this->_unicharType.get();
        break;
    case BinaryTypeEncodingType::CStringEncoding:
        result = this->_utf8CStringType.get();
        break;
    case BinaryTypeEncodingType::FloatEncoding:
        result = this->_floatType.get();
        break;
    case BinaryTypeEncodingType::DoubleEncoding:
        result = this->_doubleType.get();
        break;
    case BinaryTypeEncodingType::InterfaceDeclarationReference: {
        WTF::String declarationName = WTF::String(typeEncoding->details.declarationReference.name.valuePtr());
        result = getObjCNativeConstructor(globalObject, declarationName);
        break;
    }
    case BinaryTypeEncodingType::StructDeclarationReference: {
        WTF::String declarationName = WTF::String(typeEncoding->details.declarationReference.name.valuePtr());
        result = this->getStructConstructor(globalObject, declarationName);
        break;
    }
    case BinaryTypeEncodingType::UnionDeclarationReference: {
        result = this->_noopType.get(); // unions are not supported
        break;
    }
    case BinaryTypeEncodingType::PointerEncoding: {
        const TypeEncoding* innerTypeEncoding = typeEncoding->details.pointer.getInnerType();
        JSCell* innerType = this->parseType(globalObject, innerTypeEncoding);
        if (innerType == this->_voidType.get()) {
            result = this->_pointerConstructor.get();
        } else {
            result = this->getReferenceType(globalObject, innerType);
        }

        break;
    }
    case BinaryTypeEncodingType::VaListEncoding:
        result = this->_noopType.get(); // Not supported
        break;
    case BinaryTypeEncodingType::SelectorEncoding:
        result = this->_objCSelectorType.get();
        break;
    case BinaryTypeEncodingType::ClassEncoding:
        result = this->_objCClassType.get();
        break;
    case BinaryTypeEncodingType::ProtocolEncoding:
        result = this->_objCProtocolType.get();
        break;
    case BinaryTypeEncodingType::InstanceTypeEncoding:
        result = this->_objCInstancetypeType.get();
        break;
    case BinaryTypeEncodingType::IdEncoding:
        result = this->NSObjectConstructor(globalObject);
        break;
    case BinaryTypeEncodingType::ConstantArrayEncoding: {
        const TypeEncoding* innerTypeEncoding = typeEncoding->details.constantArray.getInnerType();
        size_t arraySize = typeEncoding->details.constantArray.size;
        JSCell* innerType = this->parseType(globalObject, innerTypeEncoding);
        result = this->getIndexedRefType(globalObject, innerType, arraySize);
        break;
    }
    case BinaryTypeEncodingType::ExtVectorEncoding: {
        const TypeEncoding* innerTypeEncoding = typeEncoding->details.extVector.getInnerType();
        size_t arraySize = typeEncoding->details.extVector.size;
        JSCell* innerType = this->parseType(globalObject, innerTypeEncoding);
        result = this->getExtVectorType(globalObject, innerType, arraySize);
        break;
    }
    case BinaryTypeEncodingType::IncompleteArrayEncoding: {
        const TypeEncoding* innerTypeEncoding = typeEncoding->details.incompleteArray.getInnerType();
        JSCell* innerType = this->parseType(globalObject, innerTypeEncoding);
        result = this->getReferenceType(globalObject, innerType);
        break;
    }
    case BinaryTypeEncodingType::FunctionPointerEncoding:
        result = this->parseFunctionReferenceType(globalObject, typeEncoding->details.functionPointer.signature);
        break;
    case BinaryTypeEncodingType::BlockEncoding:
        result = this->parseBlockType(globalObject, typeEncoding->details.block.signature);
        break;
    case BinaryTypeEncodingType::AnonymousStructEncoding:
        result = this->getAnonymousStructConstructor(globalObject, typeEncoding->details.anonymousRecord);
        break;
    case BinaryTypeEncodingType::AnonymousUnionEncoding:
        result = this->_noopType.get(); // unions are not supported
        break;
    default:
        ASSERT_NOT_REACHED(); // Unknown type encoding
    }
    typeEncoding = typeEncoding->next();
    return result;
}

const WTF::Vector<JSC::JSCell*> TypeFactory::parseTypes(GlobalObject* globalObject, const Metadata::TypeEncoding*& typeEncodings, int count) {
    DeferGCForAWhile deferGC(globalObject->vm().heap);

    WTF::Vector<JSCell*> types;
    for (int i = 0; i < count; i++) {
        types.append(parseType(globalObject, typeEncodings));
    }
    return types;
}

void TypeFactory::finishCreation(VM& vm, GlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->_referenceTypeStructure.set(vm, this, ReferenceTypeInstance::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_indexedRefTypeStructure.set(vm, this, IndexedRefTypeInstance::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_extVectorTypeStructure.set(vm, this, ExtVectorTypeInstance::createStructure(vm, globalObject, globalObject->objectPrototype()));
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

    visitor.append(typeFactory->_referenceTypeStructure);
    visitor.append(typeFactory->_indexedRefTypeStructure);
    visitor.append(typeFactory->_extVectorTypeStructure);
    visitor.append(typeFactory->_objCBlockTypeStructure);
    visitor.append(typeFactory->_functionReferenceTypeStructure);
    visitor.append(typeFactory->_recordPrototypeStructure);
    visitor.append(typeFactory->_recordConstructorStructure);
    visitor.append(typeFactory->_recordFieldStructure);

    visitor.append(typeFactory->_noopType);
    visitor.append(typeFactory->_voidType);
    visitor.append(typeFactory->_boolType);
    visitor.append(typeFactory->_utf8CStringType);
    visitor.append(typeFactory->_unicharType);

    visitor.append(typeFactory->_int8Type);
    visitor.append(typeFactory->_uint8Type);
    visitor.append(typeFactory->_int16Type);
    visitor.append(typeFactory->_uint16Type);
    visitor.append(typeFactory->_int32Type);
    visitor.append(typeFactory->_uint32Type);
    visitor.append(typeFactory->_int64Type);
    visitor.append(typeFactory->_uint64Type);
    visitor.append(typeFactory->_floatType);
    visitor.append(typeFactory->_doubleType);

    visitor.append(typeFactory->_objCInstancetypeType);
    visitor.append(typeFactory->_objCProtocolType);
    visitor.append(typeFactory->_objCClassType);
    visitor.append(typeFactory->_objCSelectorType);

    visitor.append(typeFactory->_nsObjectConstructor);
    visitor.append(typeFactory->_pointerConstructor);
}
}
