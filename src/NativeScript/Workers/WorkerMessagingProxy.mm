//
//  WorkerMessagingProxy.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#include "WorkerMessagingProxy.h"
#include "JSErrors.h"
#include "JSWorkerGlobalObject.h"
#include "TNSRuntime+Private.h"
#include <JavaScriptCore/JSONObject.h>
#include <JavaScriptCore/runtime/Exception.h>
#include <wtf/RunLoop.h>

#define Func(localFunctionName, ...) std::bind(&WorkerMessagingProxy::localFunctionName, this, ##__VA_ARGS__)

#define ASSERT_IS_PARENT_THREAD ASSERT(_parentData->threadId == WTF::currentThread())

#define ASSERT_IS_WORKER_THREAD ASSERT(_workerData->threadId == WTF::currentThread())

namespace NativeScript {
using namespace JSC;

static void parentPerformWork(void* context) {
    static_cast<WorkerMessagingProxy*>(context)->parentPerformWork();
}

static void workerPerformWork(void* context) {
    static_cast<WorkerMessagingProxy*>(context)->workerPerformWork();
}

JSWorkerGlobalObject* WorkerMessagingProxy::WorkerThreadData::globalObject() {
    return jsCast<JSWorkerGlobalObject*>(runtime->_globalObject.get());
}

WorkerMessagingProxy::ThreadMessagingPort::ThreadMessagingPort(CFRunLoopRef runLoop, void (*performWork)(void*), void* info)
    : runLoop(nullptr) {
    CFRunLoopSourceContext sourceContext = { 0, info, 0, 0, 0, 0, 0, 0, 0, performWork };
    this->runLoopTasksSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContext);
    this->swapRunLoop(runLoop);
}

void WorkerMessagingProxy::ThreadMessagingPort::swapRunLoop(CFRunLoopRef newRunLoop) {
    if (runLoop)
        CFRunLoopRemoveSource(runLoop, runLoopTasksSource, kCFRunLoopCommonModes);
    runLoop = newRunLoop;
    if (runLoop)
        CFRunLoopAddSource(runLoop, runLoopTasksSource, kCFRunLoopCommonModes);
}

void WorkerMessagingProxy::parentPerformWork() {
    ASSERT_IS_PARENT_THREAD;
    int initialQueueSize = 1;
    for (int i = 0; i < initialQueueSize; i++) {
        std::function<void()> function;
        {
            LockHolder lock(_parentPortLock);
            if (!_parentPort || _parentPort->tasksQueue.isEmpty())
                break;
            initialQueueSize = (i == 0) ? _parentPort->tasksQueue.size() : initialQueueSize;

            function = _parentPort->tasksQueue.takeFirst();
        }

        JSLockHolder lock = JSLockHolder(_parentData->globalObject->vm());
        auto scope = DECLARE_CATCH_SCOPE(_parentData->globalObject->vm());
        function();
        reportErrorIfAny(_parentData->globalObject->globalExec(), scope);
    }
}

void WorkerMessagingProxy::workerPerformWork() {
    ASSERT_IS_WORKER_THREAD;

    int initialQueueSize = 1;
    for (int i = 0; i < initialQueueSize; i++) {
        if (_workerData->stopExecutingQueueTasksInTheCurrentLoopTick)
            return;

        std::function<void()> function;
        {
            LockHolder lock(_workerPortLock);
            if (!_workerPort || _workerPort->tasksQueue.isEmpty())
                break;
            initialQueueSize = (i == 0) ? _workerPort->tasksQueue.size() : initialQueueSize;
            function = _workerPort->tasksQueue.takeFirst();
        }

        JSLockHolder lock = JSLockHolder(_workerData->globalObject()->vm());
        auto scope = DECLARE_CATCH_SCOPE(_workerData->globalObject()->vm());
        function();
        reportErrorIfAny(_workerData->globalObject()->globalExec(), scope);
    }
}

void WorkerMessagingProxy::parentAppendTask(std::function<void()> task) {
    LockHolder lock(_parentPortLock);
    if (_parentPort)
        _parentPort->appendTask(task);
}

void WorkerMessagingProxy::parentPrependTask(std::function<void()> task) {
    LockHolder lock(_parentPortLock);
    if (_parentPort)
        _parentPort->prependTask(task);
}

void WorkerMessagingProxy::workerAppendTask(std::function<void()> task) {
    LockHolder lock(_workerPortLock);
    if (_workerPort)
        _workerPort->appendTask(task);
}

void WorkerMessagingProxy::workerPrependTask(std::function<void()> task) {
    LockHolder lock(_workerPortLock);
    if (_workerPort)
        _workerPort->prependTask(task);
}

WorkerMessagingProxy::WorkerMessagingProxy(JSWorkerInstance* worker)
    : _parentPort(std::make_unique<ThreadMessagingPort>(CFRunLoopGetCurrent(), NativeScript::parentPerformWork, this))
    , _parentData(std::make_unique<ParentThreadData>(WTF::currentThread(), worker))
    , _workerPort(std::make_unique<ThreadMessagingPort>(nullptr, NativeScript::workerPerformWork, this))
    , _workerData(nullptr) {
    ASSERT_IS_PARENT_THREAD;
}

void WorkerMessagingProxy::parentStartWorkerThread(const WTF::String& applicationPath, const WTF::String& entryModuleId, const WTF::String& referrer) {
    ASSERT_IS_PARENT_THREAD;

    if (_parentData->askedToStartWorker)
        return;
    _parentData->askedToStartWorker = true;

    // _workerData will be initialized on the worker thread after its creation
    ASSERT(!_workerData);
    // The worker's runloop shouldn't be initialized because the thread is not started yet
    ASSERT(_workerPort);
    ASSERT(!_workerPort->runLoop);

    std::shared_ptr<WorkerMessagingProxy> sharedProxy = _parentData->workerInstance->workerMessagingProxy();
    Thread::create("NativeScript: Worker", std::bind(WorkerMessagingProxy::workerThreadMain, sharedProxy, applicationPath, entryModuleId, referrer));
}

void WorkerMessagingProxy::parentTerminateWorkerThread() {
    ASSERT_IS_PARENT_THREAD;

    if (_parentData->askedToTerminateWorker)
        return;
    _parentData->askedToTerminateWorker = true;

    workerPrependTask(Func(workerRunLoopStop));
}

void WorkerMessagingProxy::parentPostMessageToWorkerThread(WTF::String& message) {
    ASSERT_IS_PARENT_THREAD;
    workerAppendTask(Func(workerOnMessagePostedFromParent, message));
}

void WorkerMessagingProxy::parentOnMessagePostedFromWorker(WTF::String& message) {
    ASSERT_IS_PARENT_THREAD;

    ExecState* exec = _parentData->globalObject->globalExec();
    JSValue value = JSONParse(exec, message);
    _parentData->workerInstance->onmessage(exec, value);
}

void WorkerMessagingProxy::parentOnExceptionPosted(const String& message, const String& sourceUrl, unsigned lineNumber, unsigned colNumber) {
    ASSERT_IS_PARENT_THREAD;

    ExecState* exec = _parentData->globalObject->globalExec();
    JSObject* error = JSC::createError(exec, message);
    error->putDirect(exec->vm(), Identifier::fromString(&exec->vm(), "filename"), jsString(exec, sourceUrl));
    error->putDirect(exec->vm(), Identifier::fromString(&exec->vm(), "lineno"), JSValue(lineNumber));
    error->putDirect(exec->vm(), Identifier::fromString(&exec->vm(), "colno"), JSValue(colNumber));
    _parentData->workerInstance->onerror(exec, error);
}

void WorkerMessagingProxy::parentOnWorkerThreadExited() {
    ASSERT_IS_PARENT_THREAD;
    _parentData->workerInstance.clear(); // make the worker instance garbage collectable
}

void WorkerMessagingProxy::workerThreadMain(std::shared_ptr<WorkerMessagingProxy> messagingProxy, const String& applicationPath, const String& entryModuleId, const String& referrer) {
    messagingProxy->workerThreadInitialize(messagingProxy, applicationPath, entryModuleId, referrer);
}

void WorkerMessagingProxy::workerThreadInitialize(std::shared_ptr<WorkerMessagingProxy> messagingProxy, const WTF::String& applicationPath, const WTF::String& entryModuleId, const WTF::String& referrer) {
    {
        WTF::LockHolder lock(_workerPortLock);
        _workerPort->swapRunLoop(CFRunLoopGetCurrent());
        if (_workerPort)
            _workerPort->prependTask([this]() {
                [_workerData->runtime executeModule:_workerData->entryModuleId referredBy:_workerData->referrer];
            });
    }

    @autoreleasepool {
        _workerData = std::make_unique<WorkerThreadData>(WTF::currentThread(), applicationPath, entryModuleId, referrer);
        _workerData->runtime = [[TNSWorkerRuntime alloc] initWithApplicationPath:_workerData->applicationPath];
        _workerData->globalObject()->setWorkerMessagingProxy(messagingProxy);
        [_workerData->runtime scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _workerData->onCloseIdentifier = Identifier::fromString(&_workerData->globalObject()->vm(), "onclose");

        CFRunLoopRun();
        workerThreadExited();
    }

    [_workerData->runtime removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_workerData->runtime release];
    Thread::current().detach();
}

void WorkerMessagingProxy::workerPostMessageToParent(WTF::String& message) {
    ASSERT_IS_WORKER_THREAD;
    parentAppendTask(Func(parentOnMessagePostedFromWorker, message));
}

void WorkerMessagingProxy::workerOnMessagePostedFromParent(WTF::String& message) {
    ASSERT_IS_WORKER_THREAD;
    ExecState* exec = _workerData->globalObject()->globalExec();
    JSValue value = JSONParse(exec, message);
    _workerData->globalObject()->onmessage(exec, value);
}

void WorkerMessagingProxy::workerClose() {
    ASSERT_IS_WORKER_THREAD;
    workerPrependTask(Func(workerClosed));
}

void WorkerMessagingProxy::workerClosed() {
    ASSERT_IS_WORKER_THREAD;

    // call onclose
    JSValue onClose = _workerData->globalObject()->getDirect(_workerData->globalObject()->vm(), _workerData->onCloseIdentifier);
    if (onClose.isCell() && onClose.asCell() != nullptr && onClose.isValidCallee()) {
        JSC::ExecState* execState = _workerData->globalObject()->globalExec();

        JSC::CallData callData;
        JSC::CallType callType = JSC::getCallData(onClose.asCell(), callData);
        if (callType != JSC::CallType::None) {
            MarkedArgumentBuffer args;
            JSC::call(execState, onClose.asCell(), callType, callData, jsUndefined(), args);
        }
    }

    this->workerRunLoopStop();
}

void WorkerMessagingProxy::workerPostException(const WTF::String& message, const WTF::String& filename, int lineNumber, int colNumber) {
    ASSERT_IS_WORKER_THREAD;
    parentAppendTask(Func(parentOnExceptionPosted, message, filename, lineNumber, colNumber));
}

void WorkerMessagingProxy::workerRunLoopStop() {
    ASSERT_IS_WORKER_THREAD;

    _workerData->stopExecutingQueueTasksInTheCurrentLoopTick = true;
    LockHolder lock(_workerPortLock);
    CFRunLoopStop(_workerPort->runLoop);
    _workerPort->invalidate();
}

void WorkerMessagingProxy::workerThreadExited() {
    ASSERT_IS_WORKER_THREAD;

    parentAppendTask(Func(parentOnWorkerThreadExited));
}
}
