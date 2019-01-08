//
//  ObjCSuperObject.h
//  NativeScript
//
//  Created by Panayot Cankov on 8.5.14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef NativeScript_ObjCSuperObject_h
#define NativeScript_ObjCSuperObject_h

namespace NativeScript {
class ObjCWrapperObject;

class ObjCSuperObject : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static JSC::Strong<ObjCSuperObject> create(JSC::VM& vm, JSC::Structure* structure, ObjCWrapperObject* wrapper, GlobalObject* globalObject) {
        JSC::Strong<ObjCSuperObject> cell(vm, new (NotNull, JSC::allocateCell<ObjCSuperObject>(vm.heap)) ObjCSuperObject(vm, structure));
        cell->finishCreation(vm, wrapper, globalObject);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    ObjCWrapperObject* wrapperObject() const {
        return this->_wrapperObject.get();
    }

private:
    ObjCSuperObject(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        static_cast<ObjCSuperObject*>(cell)->~ObjCSuperObject();
    }

    void finishCreation(JSC::VM&, ObjCWrapperObject*, GlobalObject*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::JSValue toThis(JSC::JSCell*, JSC::ExecState*, JSC::ECMAMode);

    JSC::WriteBarrier<ObjCWrapperObject> _wrapperObject;
};
} // namespace NativeScript

#endif
