//
//  ObjCFastEnumerationIterator.h
//  NativeScript
//
//  Created by Yavor Georgiev on 14.07.15.
//
//

#ifndef __NativeScript__ObjCFastEnumerationIterator__
#define __NativeScript__ObjCFastEnumerationIterator__

#include <JavaScriptCore/JSObject.h>
#include <wtf/RetainPtr.h>
#include <wtf/Vector.h>

#import <Foundation/NSEnumerator.h>

namespace NativeScript {
class ObjCFastEnumerationIterator : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static const unsigned StructureFlags = Base::StructureFlags;

    static ObjCFastEnumerationIterator* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, id object) {
        ObjCFastEnumerationIterator* prototype = new (NotNull, JSC::allocateCell<ObjCFastEnumerationIterator>(vm.heap)) ObjCFastEnumerationIterator(vm, structure);
        prototype->finishCreation(vm, globalObject, object);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    bool next(JSC::ExecState*, JSC::JSValue& value);

private:
    ObjCFastEnumerationIterator(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure)
        , _state({})
        , _index(0) {
    }

    ~ObjCFastEnumerationIterator();

    static void destroy(JSC::JSCell* cell) {
        static_cast<ObjCFastEnumerationIterator*>(cell)->~ObjCFastEnumerationIterator();
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, id);

    NSFastEnumerationState _state;
    std::array<id, 16> _buffer;
    unsigned long _mutationSentinel;

    NSUInteger _count;
    NSUInteger _index;

    WTF::RetainPtr<id> _object;
};
}

#endif /* defined(__NativeScript__ObjCFastEnumerationIterator__) */
