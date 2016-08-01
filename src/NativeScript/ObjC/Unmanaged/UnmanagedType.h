#ifndef UnmanagedType_h
#define UnmanagedType_h

#include "FFIType.h"
#include "UnmanagedInstance.h"
#include "UnmanagedPrototype.h"
#include <stdio.h>

namespace NativeScript {
class UnmanagedType : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static UnmanagedType* create(JSC::VM& vm, JSC::JSCell* returnType, JSC::Structure* structure) {
        UnmanagedType* constructor = new (NotNull, JSC::allocateCell<UnmanagedType>(vm.heap)) UnmanagedType(vm, structure);
        constructor->finishCreation(vm, returnType);
        return constructor;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const FFITypeMethodTable& ffiTypeMethodTable() const {
        return this->_ffiTypeMethodTable;
    }

private:
    UnmanagedType(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<UnmanagedType*>(cell)->~UnmanagedType();
    }

    static JSC::JSValue read(JSC::ExecState*, void const*, JSC::JSCell*);
    static void write(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell* self);
    static bool canConvert(JSC::ExecState*, const JSC::JSValue&, JSC::JSCell* self);
    static const char* encode(JSC::JSCell* self);

    void finishCreation(JSC::VM&, JSC::JSCell*);

    JSC::WriteBarrier<JSC::JSCell> _returnType;
    FFITypeMethodTable _ffiTypeMethodTable;
};
}

#endif /* UnmanagedType_h */
