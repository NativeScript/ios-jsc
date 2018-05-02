#ifndef UnmanagedPrototype_h
#define UnmanagedPrototype_h

namespace NativeScript {
class UnmanagedPrototype : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static UnmanagedPrototype* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure) {
        UnmanagedPrototype* prototype = new (NotNull, JSC::allocateCell<UnmanagedPrototype>(vm.heap)) UnmanagedPrototype(vm, structure);
        prototype->finishCreation(vm, globalObject);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    UnmanagedPrototype(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*);
};
} // namespace NativeScript
#endif /* UnmanagedPrototype_h */
