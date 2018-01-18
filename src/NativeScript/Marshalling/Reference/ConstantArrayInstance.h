
//
//  Header.h
//  NativeScript
//
//  Created by Deyan Ginev on 16.01.18.
//

#ifndef __NativeScript__ConstantArrayInstance__
#define __NativeScript__ConstantArrayInstance__

#include "FFIType.h"
#include "PointerInstance.h"

namespace NativeScript {

class ConstantArrayInstance : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    DECLARE_INFO;

    static ConstantArrayInstance* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSValue value = JSC::jsUndefined()) {
        ConstantArrayInstance* cell = new (NotNull, JSC::allocateCell<ConstantArrayInstance>(vm.heap)) ConstantArrayInstance(vm, structure);
        cell->finishCreation(vm, value);
        return cell;
    }

    static ConstantArrayInstance* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSCell* innerType, PointerInstance* pointer) {
        ConstantArrayInstance* object = new (NotNull, JSC::allocateCell<ConstantArrayInstance>(vm.heap)) ConstantArrayInstance(vm, structure);
        object->finishCreation(vm, globalObject, innerType, pointer);
        return object;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    void createBackingStorage(JSC::VM&, GlobalObject*, JSC::ExecState*, JSC::JSCell* innerType);

    void* data() const {
        return this->_pointer ? this->_pointer->data() : nullptr;
    }

    PointerInstance* pointer() const {
        return this->_pointer.get();
    }

    JSC::JSCell* innerType() const {
        return this->_innerTypeCell.get();
    }

    const FFITypeMethodTable& ffiTypeMethodTable() {
        return this->_ffiTypeMethodTable;
    }

    static bool getOwnPropertySlotByIndex(JSC::JSObject*, JSC::ExecState*, unsigned int, JSC::PropertySlot&);

    static bool putByIndex(JSCell*, JSC::ExecState*, unsigned int, JSC::JSValue, bool shouldThrow);

private:
    ConstantArrayInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<ConstantArrayInstance*>(cell)->~ConstantArrayInstance();
    }

    void finishCreation(JSC::VM&, JSC::JSValue);

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSCell* innerType, PointerInstance*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    void setType(JSC::VM&, JSC::JSCell* innerType);

    JSC::WriteBarrier<PointerInstance> _pointer;

    JSC::WriteBarrier<JSC::JSCell> _innerTypeCell;

    FFITypeMethodTable _ffiTypeMethodTable;
};
} // namespace NativeScript

#endif /* __NativeScript__ConstantArrayInstance__ */
