//
//  ConstantArrayPrototype.hpp
//  NativeScript
//
//  Created by Deyan Ginev on 17.01.18.
//

#ifndef __NativeScript__ConstantArrayPrototype__
#define __NativeScript__ConstantArrayPrototype__

namespace NativeScript {
class ConstantArrayPrototype : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static ConstantArrayPrototype* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure) {
        ConstantArrayPrototype* prototype = new (NotNull, JSC::allocateCell<ConstantArrayPrototype>(vm.heap)) ConstantArrayPrototype(vm, structure);
        prototype->finishCreation(vm, globalObject);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    ConstantArrayPrototype(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*);
};
} // namespace NativeScript

#endif /* __NativeScript__ConstantArrayPrototype__ */
