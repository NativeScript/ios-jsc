//
//  ConstantArrayTypeInstance.h
//  NativeScript
//
//  Created by Deyan Ginev on 8.01.18.
//

#include "ReferenceInstance.h"
#include "ReferenceTypeInstance.h"

namespace NativeScript {
using namespace JSC;
class ConstantArrayTypeInstance : public JSDestructibleObject {
public:
    typedef JSDestructibleObject Base;

    static ConstantArrayTypeInstance* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSCell* innerType, size_t size) {
        ConstantArrayTypeInstance* cell = new (NotNull, JSC::allocateCell<ConstantArrayTypeInstance>(vm.heap)) ConstantArrayTypeInstance(vm, structure, size);
        cell->finishCreation(vm, innerType);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const FFITypeMethodTable& ffiTypeMethodTable() const {
        return this->_ffiTypeMethodTable;
    }

    JSC::JSCell* innerType() const {
        return this->_innerType.get();
    }

    void finishCreation(JSC::VM&, JSC::JSCell*);
    static JSC::JSValue read(JSC::ExecState*, void const*, JSC::JSCell*);

private:
    FFITypeMethodTable _ffiTypeMethodTable;
    JSC::WriteBarrier<JSC::JSCell> _innerType;
    ffi_type* _constArrayType;
    size_t _size;
    ConstantArrayTypeInstance(JSC::VM& vm, JSC::Structure* structure, size_t size)
        : Base(vm, structure)
        , _size(size) {
    }

    ~ConstantArrayTypeInstance() {
        delete this->_constArrayType;
    }
    static void write(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);
    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<ConstantArrayTypeInstance*>(cell)->~ConstantArrayTypeInstance();
    }
};
} // namespace NativeScript
