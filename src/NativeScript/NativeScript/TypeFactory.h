//
//  TypeFactory.h
//  NativeScript
//
//  Created by Yavor Georgiev on 13.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__TypeFactory__
#define __NativeScript__TypeFactory__

#include "FFIType.h"
#include <unordered_map>
#include <wtf/HashFunctions.h>
#include "WeakHandleOwners.h"

namespace Metadata {
struct InterfaceMeta;
}

namespace NativeScript {
class ObjCConstructorNative;
class RecordConstructor;
class RecordField;
class ReferenceTypeInstance;
class ObjCBlockType;
class FunctionReferenceTypeInstance;
class FFISimpleType;
class PointerConstructor;

class TypeFactory : public JSC::JSCell {
public:
    typedef JSC::JSCell Base;

    static TypeFactory* create(JSC::VM& vm, GlobalObject* globalObject, JSC::Structure* structure) {
        TypeFactory* object = new (NotNull, JSC::allocateCell<TypeFactory>(vm.heap)) TypeFactory(vm, structure);
        object->finishCreation(vm, globalObject);
        vm.heap.addFinalizer(object, destroy);
        return object;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    JSC::JSCell* parseType(GlobalObject*, const char* typeEncoding, ptrdiff_t* consumed = nullptr);

    const WTF::Vector<JSC::JSCell*> parseTypes(GlobalObject*, const char* typeEncoding, ptrdiff_t* consumed = nullptr);

    ObjCConstructorNative* getObjCNativeConstructor(GlobalObject*, const WTF::String& klassName);

    RecordConstructor* getStructConstructor(GlobalObject*, const WTF::String& structName);

    ObjCConstructorNative* NSObjectConstructor(GlobalObject*);

    ReferenceTypeInstance* getReferenceType(GlobalObject* globalObject, JSC::JSCell* innerType);

    FunctionReferenceTypeInstance* getFunctionReferenceTypeInstance(GlobalObject* globalObject, JSC::JSCell* returnType, WTF::Vector<JSCell*> parametersTypes);

    ObjCBlockType* getObjCBlockType(GlobalObject* globalObject, JSCell* returnType, WTF::Vector<JSCell*> parametersTypes);

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
        , _cacheReferenceTypeWeakHandleOwner(ReferenceTypesWeakHandleOwner(_cacheReferenceType)) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<TypeFactory*>(cell)->~TypeFactory();
    }

    void finishCreation(JSC::VM&, GlobalObject*);

    static void visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor);

    void extractInlinedRecordEncoding(GlobalObject*, const char* start, WTF::Vector<JSC::JSCell*>& fieldsTypes, WTF::Vector<WTF::String>& fieldsNames);

    WTF::Vector<RecordField*> createRecordFields(GlobalObject*, const WTF::Vector<JSCell*>& fieldsTypes, const WTF::Vector<WTF::String>& fieldsNames, ffi_type* ffiType);

    JSC::JSCell* parseReferenceType(GlobalObject*, char const* typeEncoding, ptrdiff_t* consumed);

    ObjCBlockType* parseBlockType(GlobalObject*, char const* typeEncoding, ptrdiff_t* consumed);

    JSC::JSCell* parseFunctionReferenceType(GlobalObject* globalObject, const char* typeEncoding, ptrdiff_t* consumed);

    JSC::JSCell* parseArrayType(GlobalObject*, char const* typeEncoding, ptrdiff_t* consumed);

    RecordConstructor* parseStructType(GlobalObject*, char const* typeEncoding, ptrdiff_t* consumed);

    JSC::JSCell* parseUnionType(GlobalObject*, char const* typeEncoding, ptrdiff_t* consumed);

    ObjCConstructorNative* parseIdType(GlobalObject*, const char* typeEncoding, ptrdiff_t* consumed);

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
    JSC::WeakGCMap<WTF::String, ObjCConstructorNative> _cacheId;
};

#ifdef __OBJC__
#endif
}

#endif /* defined(__NativeScript__TypeFactory__) */
