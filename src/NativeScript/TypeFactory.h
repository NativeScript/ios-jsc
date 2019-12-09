//
//  TypeFactory.h
//  NativeScript
//
//  Created by Yavor Georgiev on 13.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__TypeFactory__
#define __NativeScript__TypeFactory__

#include "ConstructorKey.h"
#include "ExtVectorTypeInstance.h"
#include "FFIType.h"
#include "IndexedRefTypeInstance.h"
#include "ManualInstrumentation.h"
#include "Metadata/Metadata.h"
#include "WeakHandleOwners.h"
#include <unordered_map>
#include <wtf/HashFunctions.h>

namespace Metadata {
struct InterfaceMeta;
}

namespace NativeScript {
class ObjCConstructorNative;
class RecordConstructor;
class RecordField;
class ReferenceTypeInstance;
class IndexedRefTypeInstance;
class ObjCBlockType;
class FunctionReferenceTypeInstance;
class FFISimpleType;
class PointerConstructor;

class TypeFactory : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static JSC::Strong<TypeFactory> create(JSC::VM& vm, GlobalObject* globalObject, JSC::Structure* structure) {
        JSC::Strong<TypeFactory> object(vm, new (NotNull, JSC::allocateCell<TypeFactory>(vm.heap)) TypeFactory(vm, structure));
        object->finishCreation(vm, globalObject);
        return object;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    Strong<JSC::JSCell> parseType(GlobalObject*, const Metadata::TypeEncoding*&, bool isStructMember);

    const WTF::Vector<JSC::Strong<JSC::JSCell>> parseTypes(GlobalObject*, const Metadata::TypeEncoding*& typeEncodings, int count, bool isStructMember);

    JSC::Strong<ObjCConstructorNative> getObjCNativeConstructorByNativeName(GlobalObject* globalObject, Class klass, const Metadata::ProtocolMetas& protocols);
    JSC::Strong<ObjCConstructorNative> getObjCNativeConstructorByJsName(GlobalObject* globalObject, const WTF::String& klassName, const Metadata::ProtocolMetas& protocols);
    JSC::Strong<ObjCConstructorNative> getObjCNativeConstructor(GlobalObject*, const Metadata::InterfaceMeta* metadata, const Metadata::ProtocolMetas& protocols);

    JSC::Strong<ObjCConstructorNative> getObjCNativeConstructor(GlobalObject*, const ConstructorKey& constructorKey, const Metadata::InterfaceMeta* metadata,
                                                                const tns::instrumentation::Frame& frame = tns::instrumentation::Frame());

    JSC::Strong<RecordConstructor> getStructConstructor(GlobalObject*, const WTF::String& structName);

    JSC::Strong<ObjCConstructorNative> NSObjectConstructor(GlobalObject*);

    JSC::Strong<ReferenceTypeInstance> getReferenceType(GlobalObject* globalObject, JSC::JSCell* innerType);

    JSC::Strong<IndexedRefTypeInstance> getIndexedRefType(GlobalObject* globalObject, JSCell* innerType, size_t typeSize);

    JSC::Strong<ExtVectorTypeInstance> getExtVectorType(GlobalObject* globalObject, JSCell* innerType, size_t typeSize, bool isStructMember);

    JSC::Strong<FunctionReferenceTypeInstance> getFunctionReferenceTypeInstance(GlobalObject* globalObject, JSC::JSCell* returnType, WTF::Vector<Strong<JSCell>> parametersTypes);

    JSC::Strong<ObjCBlockType> getObjCBlockType(GlobalObject* globalObject, JSCell* returnType, WTF::Vector<Strong<JSCell>> parametersTypes);

    PointerConstructor* pointerConstructor() const {
        return this->_pointerConstructor.get();
    }

    FFISimpleType* noopType() const {
        return this->_noopType.get();
    };
    FFISimpleType* voidType() const {
        return this->_voidType.get();
    };
    FFISimpleType* boolType() const {
        return this->_boolType.get();
    };
    FFISimpleType* utf8CStringType() const {
        return this->_utf8CStringType.get();
    };
    FFISimpleType* unicharType() const {
        return this->_unicharType.get();
    };
    FFISimpleType* int8Type() const {
        return this->_int8Type.get();
    };
    FFISimpleType* uint8Type() const {
        return this->_uint8Type.get();
    };
    FFISimpleType* int16Type() const {
        return this->_int16Type.get();
    };
    FFISimpleType* uint16Type() const {
        return this->_uint16Type.get();
    };
    FFISimpleType* int32Type() const {
        return this->_int32Type.get();
    };
    FFISimpleType* uint32Type() const {
        return this->_uint32Type.get();
    };
    FFISimpleType* int64Type() const {
        return this->_int64Type.get();
    };
    FFISimpleType* uint64Type() const {
        return this->_uint64Type.get();
    };
    FFISimpleType* floatType() const {
        return this->_floatType.get();
    };
    FFISimpleType* doubleType() const {
        return this->_doubleType.get();
    };
    FFISimpleType* objCInstancetypeType() const {
        return this->_objCInstancetypeType.get();
    };
    FFISimpleType* objCProtocolType() const {
        return this->_objCProtocolType.get();
    };
    FFISimpleType* objCClassType() const {
        return this->_objCClassType.get();
    };
    FFISimpleType* objCSelectorType() const {
        return this->_objCSelectorType.get();
    };

private:
    TypeFactory(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure)
        , _cacheReferenceTypeWeakHandleOwner(ReferenceTypesWeakHandleOwner(_cacheReferenceType))
        , _cacheArray(vm)
        , _cacheStruct(vm)
        , _cacheId(vm) {
    }

    static void destroy(JSC::JSCell* cell) {
        static_cast<TypeFactory*>(cell)->~TypeFactory();
    }

    static void visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor);

    static Metadata::ProtocolMetas getProtocolMetas(Metadata::PtrTo<Metadata::Array<Metadata::String>> protocolsPtr);

    void finishCreation(JSC::VM&, GlobalObject*);

    Strong<JSC::JSCell> parsePrimitiveType(JSC::JSGlobalObject* globalOBject, const Metadata::TypeEncoding*& typeEncoding);
    size_t resolveConstArrayTypeSize(const Metadata::TypeEncoding* typeEncoding, const Metadata::TypeEncoding* innerTypeEncoding);

    WTF::Vector<Strong<RecordField>> createRecordFields(GlobalObject*, const WTF::Vector<Strong<JSCell>>& fieldsTypes, const WTF::Vector<WTF::String>& fieldsNames, ffi_type* ffiType);

    Strong<ObjCBlockType> parseBlockType(GlobalObject*, const Metadata::TypeEncodingsList<uint8_t>& typeEncodings);

    Strong<JSC::JSCell> parseFunctionReferenceType(GlobalObject* globalObject, const Metadata::TypeEncodingsList<uint8_t>& typeEncodings);

    JSC::Strong<RecordConstructor> getAnonymousStructConstructor(GlobalObject*, const Metadata::TypeEncodingDetails::AnonymousRecordDetails& details);

    JSC::Strong<ObjCConstructorNative> createConstructorNative(GlobalObject*, const Metadata::InterfaceMeta* metadata, const ConstructorKey& constructorKey);

    JSC::WriteBarrier<FFISimpleType> _noopType;
    JSC::WriteBarrier<FFISimpleType> _voidType;
    JSC::WriteBarrier<FFISimpleType> _boolType;
    JSC::WriteBarrier<FFISimpleType> _utf8CStringType;
    JSC::WriteBarrier<FFISimpleType> _unicharType;
    JSC::WriteBarrier<FFISimpleType> _int8Type;
    JSC::WriteBarrier<FFISimpleType> _uint8Type;
    JSC::WriteBarrier<FFISimpleType> _int16Type;
    JSC::WriteBarrier<FFISimpleType> _uint16Type;
    JSC::WriteBarrier<FFISimpleType> _int32Type;
    JSC::WriteBarrier<FFISimpleType> _uint32Type;
    JSC::WriteBarrier<FFISimpleType> _int64Type;
    JSC::WriteBarrier<FFISimpleType> _uint64Type;
    JSC::WriteBarrier<FFISimpleType> _floatType;
    JSC::WriteBarrier<FFISimpleType> _doubleType;
    JSC::WriteBarrier<FFISimpleType> _objCInstancetypeType;
    JSC::WriteBarrier<FFISimpleType> _objCProtocolType;
    JSC::WriteBarrier<FFISimpleType> _objCClassType;
    JSC::WriteBarrier<FFISimpleType> _objCSelectorType;

    JSC::WriteBarrier<ObjCConstructorNative> _nsObjectConstructor;
    JSC::WriteBarrier<PointerConstructor> _pointerConstructor;

    JSC::WriteBarrier<JSC::Structure> _referenceTypeStructure;
    JSC::WriteBarrier<JSC::Structure> _indexedRefTypeStructure;
    JSC::WriteBarrier<JSC::Structure> _extVectorTypeStructure;
    JSC::WriteBarrier<JSC::Structure> _objCBlockTypeStructure;
    JSC::WriteBarrier<JSC::Structure> _functionReferenceTypeStructure;
    JSC::WriteBarrier<JSC::Structure> _recordPrototypeStructure;
    JSC::WriteBarrier<JSC::Structure> _recordConstructorStructure;
    JSC::WriteBarrier<JSC::Structure> _recordFieldStructure;

    WTF::HashMap<JSC::WeakImpl*, JSC::WeakImpl*, WeakImplHashTraits> _cacheReferenceType;
    ReferenceTypesWeakHandleOwner _cacheReferenceTypeWeakHandleOwner;
    WTF::HashMap<WTF::Vector<JSC::WeakImpl*>, JSC::WeakImpl*, WeakImplVectorHashTraits, WeakImplVectorKeyTraits> _cacheFunctionReferenceType;
    WTF::HashMap<WTF::Vector<JSC::WeakImpl*>, JSC::WeakImpl*, WeakImplVectorHashTraits, WeakImplVectorKeyTraits> _cacheObjCBlockType;
    JSC::WeakGCMap<WTF::String, JSC::JSCell> _cacheArray;
    JSC::WeakGCMap<WTF::String, RecordConstructor> _cacheStruct;
    JSC::WeakGCMap<ConstructorKey, ObjCConstructorNative> _cacheId;
};

#ifdef __OBJC__
#endif
} // namespace NativeScript

#endif /* defined(__NativeScript__TypeFactory__) */
