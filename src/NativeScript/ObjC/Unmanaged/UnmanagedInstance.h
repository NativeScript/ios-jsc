#ifndef UnmanagedInstance_h
#define UnmanagedInstance_h

namespace NativeScript {
class UnmanagedInstance : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    DECLARE_INFO;

    static UnmanagedInstance* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSCell* returnType, void* value = nullptr) {
        UnmanagedInstance* object = new (NotNull, JSC::allocateCell<UnmanagedInstance>(vm.heap)) UnmanagedInstance(vm, structure);
        object->finishCreation(vm, returnType, value);
        return object;
    }

    static JSC::Structure* createStructure(JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(globalObject->vm(), globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

    JSC::JSCell* returnType() const {
        return this->_returnType.get();
    }

    CFTypeRef data() const {
        return this->_data;
    }
    void setData(void* data) {
        this->_data = data;
    }

private:
    CFTypeRef _data;
    JSC::WriteBarrier<JSC::JSCell> _returnType;

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static void destroy(JSC::JSCell* cell) {
        static_cast<UnmanagedInstance*>(cell)->~UnmanagedInstance();
    }

    UnmanagedInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSCell*, void*);
};
} // namespace NativeScript
#endif /* UnmanagedInstance_h */
