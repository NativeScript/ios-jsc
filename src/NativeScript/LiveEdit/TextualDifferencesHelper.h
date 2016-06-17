// Copyright 2012 the V8 project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#pragma once

namespace NativeScript {

struct DiffChunk {
    int pos1;
    int pos2;
    int len1;
    int len2;
};

class TextualDifferencesHelper {
public:
    static WTF::Vector<DiffChunk> CompareStrings(WTF::String s1, WTF::String s2);
};
}