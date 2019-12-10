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

Strong<ObjCBlockType> TypeFactory::parseBlockType(GlobalObject* globalObject, const TypeEncodingsList<uint8_t>& typeEncodings) {
    const TypeEncoding* typeEncodingPtr = typeEncodings.first();
    Strong<JSCell> returnType = this->parseType(globalObject, typeEncodingPtr, false);
    const WTF::Vector<Strong<JSCell>> parameters = this->parseTypes(globalObject, typeEncodingPtr, typeEncodings.count - 1, false);
    return this->getObjCBlockType(globalObject, returnType.get(), parameters);
}

Strong<ObjCBlockType> TypeFactory::getObjCBlockType(GlobalObject* globalObject, JSCell* returnType, WTF::Vector<Strong<JSCell>> parametersTypes) {
    WTF::Vector<JSC::WeakImpl*> weakParametersTypes;
    weakParametersTypes.append(WeakSet::allocate(JSValue(returnType))); // add return value
    for (size_t i = 0; i < parametersTypes.size(); i++) {
        weakParametersTypes.append(WeakSet::allocate(JSValue(parametersTypes[i].get())));
    }

    if (this->_cacheObjCBlockType.contains(weakParametersTypes)) {
        WeakImpl* value = this->_cacheObjCBlockType.get(weakParametersTypes);
        if (value->state() == WeakImpl::State::Live) {
            return Strong<ObjCBlockType>(globalObject->vm(), static_cast<ObjCBlockType*>(value->jsValue().asCell()));
        } else {
            this->_cacheObjCBlockType.remove(weakParametersTypes);
        }
    }

    Strong<ObjCBlockType> result = ObjCBlockType::create(globalObject->vm(), this->_objCBlockTypeStructure.get(), returnType, parametersTypes);
    WeakImpl* resultWeak = WeakSet::allocate(JSValue(result.get()));
    this->_cacheObjCBlockType.add(weakParametersTypes, resultWeak);
    return result;
}

Strong<JSCell> TypeFactory::parseFunctionReferenceType(GlobalObject* globalObject, const TypeEncodingsList<uint8_t>& typeEncodings) {
    const TypeEncoding* typeEncodingPtr = typeEncodings.first();
    Strong<JSCell> returnType = globalObject->typeFactory()->parseType(globalObject, typeEncodingPtr, false);
    const auto parameterTypes = globalObject->typeFactory()->parseTypes(globalObject, typeEncodingPtr, typeEncodings.count - 1, false);
    return this->getFunctionReferenceTypeInstance(globalObject, returnType.get(), parameterTypes);
}

Strong<FunctionReferenceTypeInstance> TypeFactory::getFunctionReferenceTypeInstance(GlobalObject* globalObject, JSCell* returnType, WTF::Vector<Strong<JSCell>> parametersTypes) {
    WTF::Vector<JSC::WeakImpl*> weakParametersTypes;
    weakParametersTypes.append(WeakSet::allocate(JSValue(returnType))); // add return value
    for (size_t i = 0; i < parametersTypes.size(); i++) {
        weakParametersTypes.append(WeakSet::allocate(JSValue(parametersTypes[i].get())));
    }

    if (this->_cacheFunctionReferenceType.contains(weakParametersTypes)) {
        WeakImpl* value = this->_cacheFunctionReferenceType.get(weakParametersTypes);
        if (value->state() == WeakImpl::State::Live) {
            return Strong<FunctionReferenceTypeInstance>(globalObject->vm(), jsDynamicCast<FunctionReferenceTypeInstance*>(globalObject->vm(), value->jsValue().asCell()));
        } else {
            this->_cacheFunctionReferenceType.remove(weakParametersTypes);
        }
    }

    Strong<FunctionReferenceTypeInstance> result(globalObject->vm(), FunctionReferenceTypeInstance::create(globalObject->vm(), this->_functionReferenceTypeStructure.get(), returnType, parametersTypes));
    WeakImpl* resultWeak = WeakSet::allocate(JSValue(result.get()));
    this->_cacheFunctionReferenceType.add(weakParametersTypes, resultWeak);
    return result;
}

Strong<RecordConstructor> TypeFactory::getStructConstructor(GlobalObject* globalObject, const WTF::String& structName) {
    if (RecordConstructor* constructor = this->_cacheStruct.get(structName)) {
        return Strong<RecordConstructor>(globalObject->vm(), constructor);
    }

    ffi_type* ffiType = new ffi_type({ .size = 0,
                                       .alignment = 0,
                                       .type = FFI_TYPE_STRUCT });

    VM& vm = globalObject->vm();

    // Handle linked list structures
    auto recordPrototype = RecordPrototype::create(vm, globalObject, _recordPrototypeStructure.get());
    auto constructor = RecordConstructor::create(vm, globalObject, _recordConstructorStructure.get(), recordPrototype.get(), structName, ffiType, RecordType::Struct);
    recordPrototype->putDirect(vm, vm.propertyNames->constructor, constructor.get(), static_cast<unsigned>(PropertyAttribute::DontEnum));

    auto addResult = this->_cacheStruct.set(structName, constructor.get());
    if (!addResult.isNewEntry) {
        ASSERT_NOT_REACHED();
    }

    WTF::Vector<Strong<JSCell>> fieldsTypes;
    WTF::Vector<WTF::String> fieldsNames;

    const StructMeta* structInfo = static_cast<const StructMeta*>(MetaFile::instance()->globalTableJs()->findMeta(structName.impl()));
    ASSERT(structInfo && structInfo->type() == MetaType::Struct);

    const TypeEncoding* encodingsPtr = structInfo->fieldsEncodings()->first();
    fieldsTypes = parseTypes(globalObject, encodingsPtr, structInfo->fieldsEncodings()->count, true);

    for (Array<Metadata::String>::iterator it = structInfo->fieldNames().begin(); it != structInfo->fieldNames().end(); it++) {
        fieldsNames.append((*it).valuePtr());
    }

    WTF::Vector<Strong<RecordField>> fields = createRecordFields(globalObject, fieldsTypes, fieldsNames, ffiType);
    recordPrototype->setFields(vm, globalObject, fields);

    // This could already be initialized at this point.
    if (RecordConstructor* constructor = this->_cacheStruct.get(structName)) {
        return Strong<RecordConstructor>(globalObject->vm(), constructor);
    }

    addResult = this->_cacheStruct.set(structName, constructor.get());
    if (!addResult.isNewEntry) {
        ASSERT_NOT_REACHED();
    }
    return constructor;
}

Strong<RecordConstructor> TypeFactory::getAnonymousStructConstructor(GlobalObject* globalObject, const Metadata::TypeEncodingDetails::AnonymousRecordDetails& details) {
    ffi_type* ffiType = new ffi_type({ .size = 0,
                                       .alignment = 0,
                                       .type = FFI_TYPE_STRUCT });

    VM& vm = globalObject->vm();

    // Handle linked list structures
    auto recordPrototype = RecordPrototype::create(vm, globalObject, _recordPrototypeStructure.get());
    auto constructor = RecordConstructor::create(vm, globalObject, _recordConstructorStructure.get(), recordPrototype.get(), "?", ffiType, RecordType::Struct);
    recordPrototype->putDirect(vm, vm.propertyNames->constructor, constructor.get(), static_cast<unsigned>(PropertyAttribute::DontEnum));

    WTF::Vector<Strong<JSCell>> fieldsTypes;
    WTF::Vector<WTF::String> fieldsNames;

    for (int i = 0; i < details.fieldsCount; ++i) {
        const Metadata::String* currentName = details.getFieldNames() + i;
        fieldsNames.append(currentName->valuePtr());
    }

    const TypeEncoding* encodingsPtr = details.getFieldsEncodings();
    fieldsTypes = parseTypes(globalObject, encodingsPtr, details.fieldsCount, true);

    auto fields = createRecordFields(globalObject, fieldsTypes, fieldsNames, ffiType);
    recordPrototype->setFields(vm, globalObject, fields);

    return Strong<RecordConstructor>(globalObject->vm(), constructor);
}

WTF::Vector<Strong<RecordField>> TypeFactory::createRecordFields(GlobalObject* globalObject, const WTF::Vector<Strong<JSCell>>& fieldsTypes, const WTF::Vector<WTF::String>& fieldsNames, ffi_type* ffiType) {
    DeferGCForAWhile deferGC(globalObject->vm().heap);

    ASSERT(fieldsNames.size() == fieldsTypes.size());

    VM& vm = globalObject->vm();

    ffiType->elements = new ffi_type*[fieldsTypes.size() + 1];
#if defined(__x86_64__)
    bool hasNestedStruct = false;
#endif
    WTF::Vector<Strong<RecordField>> fields;
    for (size_t i = 0; i < fieldsTypes.size(); i++) {
        const ffi_type* fieldFFIType = getFFITypeMethodTable(vm, fieldsTypes[i].get()).ffiType;
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

        Strong<RecordField> field(vm, RecordField::create(vm, this->_recordFieldStructure.get(), fieldsNames[i], fieldsTypes[i].get(), offset));
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

Strong<ObjCConstructorNative> TypeFactory::getObjCNativeConstructorByNativeName(GlobalObject* globalObject,
                                                                                Class klass,
                                                                                const ProtocolMetas& protocols) {

    if (ObjCConstructorNative* type = this->_cacheId.get(ConstructorKey(klass, protocols))) {
        return Strong<ObjCConstructorNative>(globalObject->vm(), type);
    }

    const InterfaceMeta* metadata = MetaFile::instance()->globalTableNativeInterfaces()->findInterfaceMeta(class_getName(klass));
    return this->getObjCNativeConstructor(globalObject, metadata, protocols);
}

Strong<ObjCConstructorNative> TypeFactory::getObjCNativeConstructorByJsName(GlobalObject* globalObject,
                                                                            const WTF::String& klassName,
                                                                            const ProtocolMetas& protocols) {
    const InterfaceMeta* metadata = MetaFile::instance()->globalTableJs()->findInterfaceMeta(klassName.impl());
    return this->getObjCNativeConstructor(globalObject, metadata, protocols);
}

Strong<ObjCConstructorNative> TypeFactory::getObjCNativeConstructor(GlobalObject* globalObject,
                                                                    const InterfaceMeta* metadata,
                                                                    const ProtocolMetas& protocols) {
    tns::instrumentation::Frame frame;
    Class klass = objc_getClass(metadata->name());
    if (!klass && metadata) {
        SymbolLoader::instance().ensureModule(metadata->topLevelModule());
        klass = objc_getClass(metadata->name());
    }

    if (!klass || !metadata) {
        if (strcmp(metadata->name(), "NSObject") == 0) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"fatal error: NativeScript cannot create constructor for NSObject." userInfo:nil];
        }
#ifdef DEBUG
        NSLog(@"** Can not create constructor for \"%s\". Casting it to \"NSObject\". **", metadata->name());
#endif
        auto nsobjectConstructor = this->NSObjectConstructor(globalObject);
        if (klass) {
            this->_cacheId.set(ConstructorKey(klass), nsobjectConstructor.get());
        }
        return nsobjectConstructor;
    }

    return this->getObjCNativeConstructor(globalObject, ConstructorKey(klass, protocols), metadata, frame);
}

Strong<ObjCConstructorNative> TypeFactory::getObjCNativeConstructor(GlobalObject* globalObject, const ConstructorKey& constructorKey, const InterfaceMeta* metadata, const tns::instrumentation::Frame& frame) {
    assert(constructorKey.klasses.known);

    ConstructorKey dedupedKey(constructorKey.klasses);

    // remove unnecessary protocols which the actual interface already conforms to
    if (constructorKey.additionalProtocols.size()) {
        auto protocolsSet = metadata->deepProtocolsSet();
        for (auto p : constructorKey.additionalProtocols) {
            if (protocolsSet.count(p) == 0) {
                dedupedKey.additionalProtocols.append(p);
            }
        }
    }

    if (ObjCConstructorNative* type = this->_cacheId.get(dedupedKey)) {
        return Strong<ObjCConstructorNative>(globalObject->vm(), type);
    }

    JSValue parentPrototype;
    JSValue parentConstructor;

    JSC::Strong<ObjCConstructorNative> constructor = createConstructorNative(globalObject, metadata, dedupedKey);

    if (frame.check()) {
        frame.log([NSString stringWithFormat:@"Expose: %s", class_getName(constructorKey.klasses.known)].UTF8String);
    }

    return constructor;
}

JSC::Strong<ObjCConstructorNative> TypeFactory::createConstructorNative(GlobalObject* globalObject,
                                                                        const InterfaceMeta* metadata,
                                                                        const ConstructorKey& dedupedKey) {
    VM& vm = globalObject->vm();

    JSValue parentPrototype;
    JSValue parentConstructor;
    // parent constructor should be the one for the pure class if there are additional protocols or an unknown class
    auto superClass = (dedupedKey.additionalProtocols.size() || dedupedKey.klasses.unknown)
                          ? dedupedKey.klasses.known
                          : class_getSuperclass(dedupedKey.klasses.known);

    if (superClass) {
        parentConstructor = getObjCNativeConstructorByNativeName(globalObject, superClass, ProtocolMetas()).get();
        parentPrototype = parentConstructor.get(globalObject->globalExec(), vm.propertyNames->prototype);

        /// If we have a super class which somehow references us, our constructor will already have been cached
        /// during the parent constructor's creation.
        if (ObjCConstructorNative* type = this->_cacheId.get(dedupedKey)) {
            return Strong<ObjCConstructorNative>(globalObject->vm(), type);
        }
    } else {
        // NSObject and NSProxy don't have a base class and therefore inherit directly from GlobalObject.
        parentPrototype = globalObject->objectPrototype();
        parentConstructor = globalObject->functionPrototype();
    }

    Structure* prototypeStructure = ObjCPrototype::createStructure(vm, globalObject, parentPrototype);
    auto prototype = ObjCPrototype::create(vm, globalObject, prototypeStructure, metadata, dedupedKey);

    Structure* constructorStructure = ObjCConstructorNative::createStructure(vm, globalObject, parentConstructor);
    auto constructor = ObjCConstructorNative::create(vm, globalObject, constructorStructure, prototype.get(), dedupedKey);
    prototype->putDirectWithoutTransition(vm, vm.propertyNames->constructor, constructor.get(), PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);

    auto addResult = this->_cacheId.set(dedupedKey, constructor.get());
    if (!addResult.isNewEntry) {
        ASSERT_NOT_REACHED();
    }

    prototype->materializeProperties(vm, globalObject);
    constructor->materializeProperties(vm, globalObject);

    return constructor;
}

Strong<ObjCConstructorNative> TypeFactory::NSObjectConstructor(GlobalObject* globalObject) {
    if (LIKELY(this->_nsObjectConstructor)) {
        return Strong<ObjCConstructorNative>(globalObject->vm(), this->_nsObjectConstructor.get());
    }

    auto constructor = getObjCNativeConstructorByNativeName(globalObject, [NSObject class], ProtocolMetas());
    this->_nsObjectConstructor.set(globalObject->vm(), this, constructor.get());
    return constructor;
}

Strong<IndexedRefTypeInstance> TypeFactory::getIndexedRefType(GlobalObject* globalObject, JSCell* innerType, size_t typeSize) {

    return IndexedRefTypeInstance::create(globalObject->vm(), this->_indexedRefTypeStructure.get(), innerType, typeSize);
}

Strong<ExtVectorTypeInstance> TypeFactory::getExtVectorType(GlobalObject* globalObject, JSCell* innerType, size_t typeSize, bool isStructMember) {
    return ExtVectorTypeInstance::create(globalObject->vm(), this->_extVectorTypeStructure.get(), innerType, typeSize, isStructMember);
}

Strong<ReferenceTypeInstance> TypeFactory::getReferenceType(GlobalObject* globalObject, JSCell* innerType) {
    WeakImpl* innerWeak = WeakSet::allocate(JSValue(innerType));
    if (this->_cacheReferenceType.contains(innerWeak)) {
        WeakImpl* value = this->_cacheReferenceType.get(innerWeak);
        if (value->state() == WeakImpl::State::Live) {
            return Strong<ReferenceTypeInstance>(globalObject->vm(), static_cast<ReferenceTypeInstance*>(value->jsValue().asCell()));
        } else {
            this->_cacheReferenceType.remove(innerWeak);
        }
    }

    auto result = ReferenceTypeInstance::create(globalObject->vm(), this->_referenceTypeStructure.get(), innerType);
    WeakImpl* resultWeak = WeakSet::allocate(JSValue(result.get()));
    this->_cacheReferenceType.add(innerWeak, resultWeak);
    return result;
}

Strong<JSC::JSCell> TypeFactory::parseType(GlobalObject* globalObject, const Metadata::TypeEncoding*& typeEncoding, bool isStructMember) {
    DeferGCForAWhile deferGC(globalObject->vm().heap);

    Strong<JSC::JSCell> result;

    switch (typeEncoding->type) {
    case BinaryTypeEncodingType::VoidEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_voidType.get());
        break;
    case BinaryTypeEncodingType::BoolEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_boolType.get());
        break;
    case BinaryTypeEncodingType::ShortEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_int16Type.get());
        break;
    case BinaryTypeEncodingType::UShortEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_uint16Type.get());
        break;
    case BinaryTypeEncodingType::IntEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_int32Type.get());
        break;
    case BinaryTypeEncodingType::UIntEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_uint32Type.get());
        break;
    case BinaryTypeEncodingType::LongEncoding:
#if defined(__LP64__)
        COMPILE_ASSERT(sizeof(long) == sizeof(int64_t), "sizeof long");
        result = Strong<JSCell>(globalObject->vm(), this->_int64Type.get());
#else
        COMPILE_ASSERT(sizeof(long) == sizeof(int32_t), "sizeof long");
        result = Strong<JSCell>(globalObject->vm(), this->_int32Type.get());
#endif
        break;
    case BinaryTypeEncodingType::ULongEncoding:
#if defined(__LP64__)
        COMPILE_ASSERT(sizeof(unsigned long) == sizeof(uint64_t), "sizeof ulong");
        result = Strong<JSCell>(globalObject->vm(), this->_uint64Type.get());
#else
        COMPILE_ASSERT(sizeof(unsigned long) == sizeof(uint32_t), "sizeof ulong");
        result = Strong<JSCell>(globalObject->vm(), this->_uint32Type.get());
#endif
        break;
    case BinaryTypeEncodingType::LongLongEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_int64Type.get());
        break;
    case BinaryTypeEncodingType::ULongLongEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_uint64Type.get());
        break;
    case BinaryTypeEncodingType::CharEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_int8Type.get());
        break;
    case BinaryTypeEncodingType::UCharEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_uint8Type.get());
        break;
    case BinaryTypeEncodingType::UnicharEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_unicharType.get());
        break;
    case BinaryTypeEncodingType::CStringEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_utf8CStringType.get());
        break;
    case BinaryTypeEncodingType::FloatEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_floatType.get());
        break;
    case BinaryTypeEncodingType::DoubleEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_doubleType.get());
        break;
    case BinaryTypeEncodingType::InterfaceDeclarationReference: {
        WTF::String declarationName = WTF::String(typeEncoding->details.interfaceDeclarationReference.name.valuePtr());
        ProtocolMetas additionalProtocols = this->getProtocolMetas(typeEncoding->details.interfaceDeclarationReference._protocols);

        result = getObjCNativeConstructorByJsName(globalObject, declarationName, additionalProtocols);
        break;
    }
    case BinaryTypeEncodingType::StructDeclarationReference: {
        WTF::String declarationName = WTF::String(typeEncoding->details.declarationReference.name.valuePtr());
        result = this->getStructConstructor(globalObject, declarationName);
        break;
    }
    case BinaryTypeEncodingType::UnionDeclarationReference: {
        result = Strong<JSCell>(globalObject->vm(), this->_noopType.get()); // unions are not supported
        break;
    }
    case BinaryTypeEncodingType::PointerEncoding: {
        const TypeEncoding* innerTypeEncoding = typeEncoding->details.pointer.getInnerType();
        auto innerType = this->parseType(globalObject, innerTypeEncoding, false);
        if (innerType.get() == this->_voidType.get()) {
            result = Strong<JSCell>(globalObject->vm(), this->_pointerConstructor.get());
        } else {
            result = this->getReferenceType(globalObject, innerType.get());
        }

        break;
    }
    case BinaryTypeEncodingType::VaListEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_noopType.get()); // Not supported
        break;
    case BinaryTypeEncodingType::SelectorEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_objCSelectorType.get());
        break;
    case BinaryTypeEncodingType::ClassEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_objCClassType.get());
        break;
    case BinaryTypeEncodingType::ProtocolEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_objCProtocolType.get());
        break;
    case BinaryTypeEncodingType::InstanceTypeEncoding:
        result = Strong<JSCell>(globalObject->vm(), this->_objCInstancetypeType.get());
        break;

    case BinaryTypeEncodingType::IdEncoding: {
        auto additionalProtocols = getProtocolMetas(typeEncoding->details.idDetails._protocols);
        result = getObjCNativeConstructorByNativeName(globalObject, [NSObject class], additionalProtocols);
        break;
    }
    case BinaryTypeEncodingType::ConstantArrayEncoding: {
        const TypeEncoding* innerTypeEncoding = typeEncoding->details.constantArray.getInnerType();
        size_t arraySize = typeEncoding->details.constantArray.size;
        auto innerType = this->parseType(globalObject, innerTypeEncoding, isStructMember);
        if (isStructMember) {
            result = this->getIndexedRefType(globalObject, innerType.get(), arraySize);
        } else {
            result = this->getReferenceType(globalObject, innerType.get());
        }

        break;
    }
    case BinaryTypeEncodingType::ExtVectorEncoding: {
        const TypeEncoding* innerTypeEncoding = typeEncoding->details.extVector.getInnerType();
        size_t arraySize = typeEncoding->details.extVector.size;
        auto innerType = this->parseType(globalObject, innerTypeEncoding, isStructMember);
        result = this->getExtVectorType(globalObject, innerType.get(), arraySize, isStructMember);
        break;
    }
    case BinaryTypeEncodingType::IncompleteArrayEncoding: {
        const TypeEncoding* innerTypeEncoding = typeEncoding->details.incompleteArray.getInnerType();
        auto innerType = this->parseType(globalObject, innerTypeEncoding, isStructMember);
        result = this->getReferenceType(globalObject, innerType.get());
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
        result = Strong<JSCell>(globalObject->vm(), this->_noopType.get()); // unions are not supported
        break;
    default:
        ASSERT_NOT_REACHED(); // Unknown type encoding
    }
    typeEncoding = typeEncoding->next();
    return result;
}

const WTF::Vector<Strong<JSCell>> TypeFactory::parseTypes(GlobalObject* globalObject, const Metadata::TypeEncoding*& typeEncodings, int count, bool isStructMember) {
    DeferGCForAWhile deferGC(globalObject->vm().heap);

    WTF::Vector<Strong<JSCell>> types;
    for (int i = 0; i < count; i++) {
        types.append(parseType(globalObject, typeEncodings, isStructMember));
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

    auto pointerPrototype = PointerPrototype::create(vm, globalObject, PointerPrototype::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_pointerConstructor.set(vm, this,
                                  PointerConstructor::create(vm,
                                                             PointerConstructor::createStructure(vm, globalObject, globalObject->functionPrototype()),
                                                             pointerPrototype.get())
                                      .get());
    pointerPrototype->putDirect(vm, vm.propertyNames->constructor, this->_pointerConstructor.get(), static_cast<unsigned>(PropertyAttribute::DontEnum));

    this->_noopType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "noop"_s, noopTypeMethodTable).get());
    this->_voidType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "void"_s, voidTypeMethodTable).get());
    this->_boolType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "bool"_s, boolTypeMethodTable).get());
    this->_utf8CStringType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "UTF8CString"_s, utf8CStringTypeMethodTable).get());
    this->_unicharType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "unichar"_s, unicharTypeMethodTable).get());

    this->_int8Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "int8"_s, int8TypeMethodTable).get());
    this->_uint8Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "uint8"_s, uint8TypeMethodTable).get());
    this->_int16Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "int16"_s, int16TypeMethodTable).get());
    this->_uint16Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "uint16"_s, uint16TypeMethodTable).get());
    this->_int32Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "int32"_s, int32TypeMethodTable).get());
    this->_uint32Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "uint32"_s, uint32TypeMethodTable).get());
    this->_int64Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "int64"_s, int64TypeMethodTable).get());
    this->_uint64Type.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "uint64"_s, uint64TypeMethodTable).get());
    this->_floatType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "float"_s, floatTypeMethodTable).get());
    this->_doubleType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "double"_s, doubleTypeMethodTable).get());

    this->_objCInstancetypeType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "instancetype"_s, objCInstancetypeTypeMethodTable).get());
    this->_objCProtocolType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "protocol"_s, objCProtocolTypeMethodTable).get());
    this->_objCClassType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "class"_s, objCClassTypeMethodTable).get());
    this->_objCSelectorType.set(vm, this, FFISimpleType::create(vm, FFISimpleType::createStructure(vm, globalObject, globalObject->objectPrototype()), "selector"_s, objCSelectorTypeMethodTable).get());
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

ProtocolMetas TypeFactory::getProtocolMetas(PtrTo<Array<Metadata::String>> protocolsPtr) {
    ProtocolMetas protocols;
    for (auto it = protocolsPtr.valuePtr()->begin(); it != protocolsPtr.valuePtr()->end(); it++) {
        auto protocolName = (*it).valuePtr();
        if (auto p = MetaFile::instance()->globalTableJs()->findProtocol(protocolName)) {
            protocols.append(p);
        } else {
            // Protocols that are present in metadata should be discoverable
            ASSERT(false);
        }
    }

    return protocols;
}

}
