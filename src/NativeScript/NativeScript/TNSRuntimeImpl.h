//
//  TNSRuntimePrivate.h
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__RuntimeImpl__
#define __NativeScript__RuntimeImpl__

struct TNSRuntimeImpl final {
    WTF::RefPtr<JSC::VM> vm;
    JSC::Strong<NativeScript::GlobalObject> globalObject;
    NSString* applicationPath;

    WTF::Vector<JSC::SourceProvider*> sourceProviders;

    TNSRuntimeImpl() {
        this->vm = JSC::VM::create(JSC::SmallHeap);

        JSC::JSLockHolder lock(*this->vm);
        this->globalObject = JSC::Strong<NativeScript::GlobalObject>(*this->vm, NativeScript::GlobalObject::create(*this->vm, NativeScript::GlobalObject::createStructure(*this->vm, JSC::jsNull())));
    }

    ~TNSRuntimeImpl() {
        JSC::JSLockHolder lock(*this->vm);
        this->globalObject.clear();
        this->vm.clear();
    }
};

#endif /* defined(__NativeScript__RuntimeImpl__) */
