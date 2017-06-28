//
// Created by Panayot Cankov on 26/05/2017.
//

#ifndef MANUALINSTRUMENTATION_H
#define MANUALINSTRUMENTATION_H

#import <chrono>
#include <string>
#include <WTF/Assertions.h>

namespace tns {
    namespace instrumentation {
        enum Mode {
            Disabled = 0,
            Uninitialized = 1,
            Enabled = 2
        };
        class Frame {
        public:
            inline Frame() : Frame("") { }
            inline Frame(std::string name) : start(mode == Mode::Disabled ? disabled_time : std::chrono::steady_clock::now()), name(name) {}
            inline Frame(const Frame &copy) : start(copy.start), name(copy.name) {}
            
            inline ~Frame() {
                if (!name.empty() && check()) {
                    log(name);
                }
            }
            
            inline bool check() const {
                if (mode == Mode::Disabled) {
                    return false;
                }
                std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
                auto duration = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::operator-(end, start)).count();
                return duration >= 16000;
            }
            
            inline void log(const char * message) const {
                if (mode == Mode::Disabled) {
                    return;
                }
                std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
                auto startMilis = std::chrono::time_point_cast<std::chrono::microseconds>(start).time_since_epoch().count() / 1000.0;
                auto endMilis = std::chrono::time_point_cast<std::chrono::microseconds>(end).time_since_epoch().count() / 1000.0;
                WTFLogAlways("CONSOLE LOG Timeline: Runtime: %s  (%.3fms - %.3fms)\n", message, startMilis, endMilis);
            }
            
            inline void log(const std::string& message) const {
                log(message.c_str());
            }
            
            static inline void enable() { mode = Mode::Enabled; }
            static inline void disable() { mode = Mode::Disabled; }
            
            /**
             * Use enable() disable() instead.
             */
            static Mode mode;
            static const std::chrono::steady_clock::time_point disabled_time; // Couldn't find reasonable constant

        private:
            const std::chrono::steady_clock::time_point start;
            const std::string name;

            Frame &operator=(const Frame &) = delete;
        };
    };
};

/**
 * Place at the start of a method. Will log to android using the "JS" tag methods that execute relatively slow.
 */
#define TNSPERF() tns::instrumentation::Frame __tns_manual_instrumentation(__func__)

#endif //MANUALINSTRUMENTATION_H
