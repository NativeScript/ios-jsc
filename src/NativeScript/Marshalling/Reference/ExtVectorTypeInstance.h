//
//  ExtVectorTypeInstance.hpp
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 30/01/2018.
//

#include "ReferenceInstance.h"
#include "ReferenceTypeInstance.h"

namespace NativeScript {
using namespace JSC;
class ExtVectorTypeInstance : public JSDestructibleObject {
public:
    typedef JSDestructibleObject Base;

    static ExtVectorTypeInstance* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSCell* innerType, size_t size) {
        ExtVectorTypeInstance* cell = new (NotNull, JSC::allocateCell<ExtVectorTypeInstance>(vm.heap)) ExtVectorTypeInstance(vm, structure, size);
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
    ffi_type* _extVectorType;
    std::string _compilerEncoding;
    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);
    static const char* encode(VM&, JSC::JSCell*);
    size_t _size;
    ExtVectorTypeInstance(JSC::VM& vm, JSC::Structure* structure, size_t size)
        : Base(vm, structure)
        , _size(size) {
    }

    ~ExtVectorTypeInstance() {
        delete this->_extVectorType;
    }
    static void write(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);
    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<ExtVectorTypeInstance*>(cell)->~ExtVectorTypeInstance();
    }
};
} // namespace NativeScript
