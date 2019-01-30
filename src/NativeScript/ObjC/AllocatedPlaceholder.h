//
//  AllocatedPlaceholder.h
//  NativeScript
//
//  Created by Ivan Buhov on 7/9/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#ifndef __NativeScript__AllocatedPlaceholder__
#define __NativeScript__AllocatedPlaceholder__

namespace NativeScript {
class AllocatedPlaceholder : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static JSC::Strong<AllocatedPlaceholder> create(JSC::VM& vm, GlobalObject* globalObject, JSC::Structure* structure, id wrappedObject, JSC::Structure* instanceStructure) {
        JSC::Strong<AllocatedPlaceholder> object(vm, new (NotNull, JSC::allocateCell<AllocatedPlaceholder>(vm.heap)) AllocatedPlaceholder(vm, structure));
        object->finishCreation(vm, globalObject, wrappedObject, instanceStructure);
        return object;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    id wrappedObject() const {
        return this->_wrappedObject;
    }

    JSC::Structure* instanceStructure() const {
        return this->_instanceStructure.get();
    }

private:
    AllocatedPlaceholder(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~AllocatedPlaceholder();

    void finishCreation(JSC::VM& vm, GlobalObject* globalObject, id wrappedObject, JSC::Structure* instanceStructure);

    static void destroy(JSC::JSCell* cell);

    static void visitChildren(JSCell*, JSC::SlotVisitor&);

    // Can't be a RetainPtr<id> because of issues with some types
    // E.g. [NSTimer alloc] retain] causes an endless recursion on iPad (armv7) with iOS 10.3.3
    id _wrappedObject;

    JSC::WriteBarrier<JSC::Structure> _instanceStructure;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__AllocatedPlaceholder__) */
