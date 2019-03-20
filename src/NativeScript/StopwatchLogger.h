#include <Foundation/Foundation.h>

#include <chrono>
#include <sstream>
#include <string>

// Used to measure time of single invocation as well as the total time of all invocations of
// one or more C++ scopes. The template argument can be used to split the measurement scopes and is
// used to instantiate a separate set of [count, totalDuration] pairs. The message field can be used
// to differentiate between different branches of the logic without introducing new counters.
//
// Sample usage (with pseudocode):
#if 0
const char StopwatchLabel_getOwnPropertySlot[] = "ObjCPrototype::getOwnPropertySlot";
bool ObjCPrototype::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
  StopwatchLogger<StopwatchLabel_getOwnPropertySlot> stopwatch;
  if (<property>) { ...
        stopwatch.message << "(prop) " << className << "." << propName;
  } else if (<method>) { ...
        stopwatch.message << "(method) " << className << "." << methodName;
  } ...
}
#endif
// Expected output format:
// **** Stopwatch(ObjCPrototype::getOwnPropertySlot) (method) NSProcessInfo.isOperatingSystemAtLeastVersion: 1.989000 ms (Total: 1.989000 ms Count: 1)
// **** Stopwatch(ObjCPrototype::getOwnPropertySlot) (prop) NSProcessInfo.environment: 1.352000 ms (Total: 3.344000 ms Count: 3)
// ...

template <const char* STOPWATCH_LABEL>
struct StopwatchLogger {

    explicit StopwatchLogger() {}
    explicit StopwatchLogger(std::string message)
        : message(message) {}

    ~StopwatchLogger() {
        std::chrono::time_point<std::chrono::system_clock> endTime = std::chrono::system_clock::now();
        double duration = std::chrono::duration_cast<std::chrono::microseconds>(endTime - startTime).count() / 1000.;
        count++;
        totalDuration += duration;

        NSLog(@"**** Stopwatch(%s) %s: %f ms (Total: %f ms Count: %d)", STOPWATCH_LABEL, this->message.str().c_str(), duration, totalDuration, count);
    }

    static int count;
    static double totalDuration;

    std::chrono::time_point<std::chrono::system_clock> startTime = std::chrono::system_clock::now();
    std::ostringstream message;
};

template <const char* STOPWATCH_LABEL>
int StopwatchLogger<STOPWATCH_LABEL>::count;

template <const char* STOPWATCH_LABEL>
double StopwatchLogger<STOPWATCH_LABEL>::totalDuration;
