//
// Created by Panayot Cankov on 26/05/2017.
//

#include "ManualInstrumentation.h"

tns::instrumentation::Mode tns::instrumentation::Frame::mode = tns::instrumentation::Mode::Uninitialized;
const std::chrono::steady_clock::time_point tns::instrumentation::Frame::disabled_time = std::chrono::steady_clock::time_point();
