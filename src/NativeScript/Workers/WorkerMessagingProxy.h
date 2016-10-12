//
//  WorkerMessagingProxy.h
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#ifndef __NativeScript__WorkerMessagingProxy__
#define __NativeScript__WorkerMessagingProxy__

#include <JavaScriptCore/InternalFunction.h>
#include <JavaScriptCore/StrongInlines.h>
#include "JSWorkerInstance.h"

@class TNSRuntime;

namespace WTF {
class RunLoop;
}

namespace NativeScript {
class JSWorkerGlobalObject;

class WorkerMessagingProxy {

    struct ParentThreadData {
        ParentThreadData(WTF::ThreadIdentifier threadId, JSWorkerInstance* workerInstance)
            : threadId(threadId)
            , workerInstance(*workerInstance->vm(), workerInstance)
            , globalObject(JSC::jsCast<GlobalObject*>(workerInstance->globalObject()))
            , askedToStartWorker(false)
            , askedToTerminateWorker(false) {
        }

        WTF::ThreadIdentifier threadId;
        JSC::Strong<JSWorkerInstance> workerInstance;
        GlobalObject* globalObject;
        bool askedToStartWorker;
        bool askedToTerminateWorker;
    };

    struct WorkerThreadData {
        WorkerThreadData(WTF::ThreadIdentifier threadId, const WTF::String& applicationPath, const WTF::String& entryModuleId, const WTF::String& referrer)
            : threadId(threadId)
            , applicationPath(applicationPath)
            , entryModuleId(entryModuleId)
            , referrer(referrer)
            , stopExecutingQueueTasksInTheCurrentLoopTick(false) {
        }

        const WTF::ThreadIdentifier threadId;
        const WTF::String applicationPath;
        const WTF::String entryModuleId;
        const WTF::String referrer;
        TNSRuntime* runtime;
        JSC::Identifier onCloseIdentifier;
        bool stopExecutingQueueTasksInTheCurrentLoopTick;

        JSWorkerGlobalObject* globalObject();
    };

    struct ThreadMessagingPort {
        ThreadMessagingPort(CFRunLoopRef runLoop, void (*performWork)(void*), void* info);

        void swapRunLoop(CFRunLoopRef newRunLoop);

        void prependTask(std::function<void()> task) {
            if (!CFRunLoopSourceIsValid(runLoopTasksSource))
                return;
            tasksQueue.prepend(task);
            signalAndWakeUp();
        }

        void appendTask(std::function<void()> task) {
            if (!CFRunLoopSourceIsValid(runLoopTasksSource))
                return;
            tasksQueue.append(task);
            signalAndWakeUp();
        }

        void invalidate() {
            CFRunLoopSourceInvalidate(runLoopTasksSource);
        }

    private:
        void signalAndWakeUp() {
            ASSERT(CFRunLoopSourceIsValid(runLoopTasksSource));
            CFRunLoopSourceSignal(runLoopTasksSource);
            if (runLoop)
                CFRunLoopWakeUp(runLoop);
        }

    public:
        CFRunLoopRef runLoop;
        CFRunLoopSourceRef runLoopTasksSource;
        WTF::Deque<std::function<void()>> tasksQueue;
    };

public:
    WorkerMessagingProxy(JSWorkerInstance* worker);

    // Called on parent thread
    void parentPerformWork();
    void parentStartWorkerThread(const WTF::String& applicationPath, const WTF::String& entryModuleId, const WTF::String& referrer);
    void parentTerminateWorkerThread();
    void parentPostMessageToWorkerThread(WTF::String& message);
    void parentOnMessagePostedFromWorker(WTF::String& message);
    void parentOnExceptionPosted(const WTF::String& message, const WTF::String& sourceUrl, unsigned lineNumber, unsigned colNumber);
    void parentOnWorkerThreadExited();

    // Called on worker thread
    void workerPerformWork();
    static void workerThreadMain(std::shared_ptr<WorkerMessagingProxy> messagingProxy, const WTF::String& applicationPath, const WTF::String& entryModuleId, const WTF::String& referrer);
    void workerThreadInitialize(std::shared_ptr<WorkerMessagingProxy> messagingProxy, const WTF::String& applicationPath, const WTF::String& entryModuleId, const WTF::String& referrer);
    void workerPostMessageToParent(WTF::String& message);
    void workerOnMessagePostedFromParent(WTF::String& message);
    void workerClose();
    void workerClosed();
    void workerPostException(const WTF::String& message = "", const WTF::String& filename = "", int lineNumber = 0, int colNumber = 0);
    void workerRunLoopStop();
    void workerThreadExited();

private:
    void parentAppendTask(std::function<void()> task);
    void parentPrependTask(std::function<void()> task);
    void workerAppendTask(std::function<void()> task);
    void workerPrependTask(std::function<void()> task);

    WTF::Lock _parentPortLock;
    std::unique_ptr<ThreadMessagingPort> _parentPort;
    std::unique_ptr<ParentThreadData> _parentData; // initialized and accessed only by the parent thread, therefore locking is not needed

    WTF::Lock _workerPortLock;
    std::unique_ptr<ThreadMessagingPort> _workerPort;
    std::unique_ptr<WorkerThreadData> _workerData; // initialized and accessed only by the worker thread, therefore locking is not needed
};
}

#endif /* defined(__NativeScript__WorkerMessagingProxy__) */
