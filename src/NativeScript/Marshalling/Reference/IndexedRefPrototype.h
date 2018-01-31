//
//  IndexedRefPrototype.hpp
//  NativeScript
//
//  Created by Deyan Ginev on 17.01.18.
//

#ifndef __NativeScript__IndexedRefPrototype__
#define __NativeScript__IndexedRefPrototype__

namespace NativeScript {
class IndexedRefPrototype : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static IndexedRefPrototype* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure) {
        IndexedRefPrototype* prototype = new (NotNull, JSC::allocateCell<IndexedRefPrototype>(vm.heap)) IndexedRefPrototype(vm, structure);
        prototype->finishCreation(vm, globalObject);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    IndexedRefPrototype(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*);
};
} // namespace NativeScript

#endif /* __NativeScript__IndexedRefPrototype__ */
