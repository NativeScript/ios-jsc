// Copyright 2012 the V8 project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "TextualDifferencesHelper.h"
#include <JavaScriptCore/ContentSearchUtilities.h>

namespace NativeScript {
const uint32_t kMaxUInt32 = 0xffffffff;

// A general-purpose comparator between 2 arrays.
class Comparator {
public:
    // Holds 2 arrays of some elements allowing to compare any pair of
    // element from the first array and element from the second array.
    class Input {
    public:
        virtual int GetLength1() = 0;
        virtual int GetLength2() = 0;
        virtual bool Equals(int index1, int index2) = 0;

    protected:
        virtual ~Input() {}
    };

    // Receives compare result as a series of chunks.
    class Output {
    public:
        // Puts another chunk in result list. Note that technically speaking
        // only 3 arguments actually needed with 4th being derivable.
        virtual void AddChunk(int pos1, int pos2, int len1, int len2) = 0;

    protected:
        virtual ~Output() {}
    };

    // Finds the difference between 2 arrays of elements.
    static void CalculateDifference(Input* input,
                                    Output* result_writer);
};

// A simple implementation of dynamic programming algorithm. It solves
// the problem of finding the difference of 2 arrays. It uses a table of results
// of subproblems. Each cell contains a number together with 2-bit flag
// that helps building the chunk list.
class Differencer {
public:
    explicit Differencer(Comparator::Input* input)
        : input_(input)
        , len1_(input->GetLength1())
        , len2_(input->GetLength2()) {
        buffer_ = new int[len1_ * len2_];
    }
    ~Differencer() {
        delete[] buffer_;
    }

    void Initialize() {
        int array_size = len1_ * len2_;
        for (int i = 0; i < array_size; i++) {
            buffer_[i] = kEmptyCellValue;
        }
    }

    // Makes sure that result for the full problem is calculated and stored
    // in the table together with flags showing a path through subproblems.
    void FillTable() {
        CompareUpToTail(0, 0);
    }

    void SaveResult(Comparator::Output* chunk_writer) {
        ResultWriter writer(chunk_writer);

        int pos1 = 0;
        int pos2 = 0;
        while (true) {
            if (pos1 < len1_) {
                if (pos2 < len2_) {
                    Direction dir = get_direction(pos1, pos2);
                    switch (dir) {
                    case EQ:
                        writer.eq();
                        pos1++;
                        pos2++;
                        break;
                    case SKIP1:
                        writer.skip1(1);
                        pos1++;
                        break;
                    case SKIP2:
                    case SKIP_ANY:
                        writer.skip2(1);
                        pos2++;
                        break;
                    default:
                        ASSERT_NOT_REACHED();
                    }
                } else {
                    writer.skip1(len1_ - pos1);
                    break;
                }
            } else {
                if (len2_ != pos2) {
                    writer.skip2(len2_ - pos2);
                }
                break;
            }
        }
        writer.close();
    }

private:
    Comparator::Input* input_;
    int* buffer_;
    int len1_;
    int len2_;

    enum Direction {
        EQ = 0,
        SKIP1,
        SKIP2,
        SKIP_ANY,

        MAX_DIRECTION_FLAG_VALUE = SKIP_ANY
    };

    // Computes result for a subtask and optionally caches it in the buffer table.
    // All results values are shifted to make space for flags in the lower bits.
    int CompareUpToTail(int pos1, int pos2) {
        if (pos1 < len1_) {
            if (pos2 < len2_) {
                int cached_res = get_value4(pos1, pos2);
                if (cached_res == kEmptyCellValue) {
                    Direction dir;
                    int res;
                    if (input_->Equals(pos1, pos2)) {
                        res = CompareUpToTail(pos1 + 1, pos2 + 1);
                        dir = EQ;
                    } else {
                        int res1 = CompareUpToTail(pos1 + 1, pos2) + (1 << kDirectionSizeBits);
                        int res2 = CompareUpToTail(pos1, pos2 + 1) + (1 << kDirectionSizeBits);
                        if (res1 == res2) {
                            res = res1;
                            dir = SKIP_ANY;
                        } else if (res1 < res2) {
                            res = res1;
                            dir = SKIP1;
                        } else {
                            res = res2;
                            dir = SKIP2;
                        }
                    }
                    set_value4_and_dir(pos1, pos2, res, dir);
                    cached_res = res;
                }
                return cached_res;
            } else {
                return (len1_ - pos1) << kDirectionSizeBits;
            }
        } else {
            return (len2_ - pos2) << kDirectionSizeBits;
        }
    }

    inline int& get_cell(int i1, int i2) {
        return buffer_[i1 + i2 * len1_];
    }

    // Each cell keeps a value plus direction. Value is multiplied by 4.
    void set_value4_and_dir(int i1, int i2, int value4, Direction dir) {
        ASSERT((value4 & kDirectionMask) == 0);
        get_cell(i1, i2) = value4 | dir;
    }

    int get_value4(int i1, int i2) {
        return get_cell(i1, i2) & (kMaxUInt32 ^ kDirectionMask);
    }
    Direction get_direction(int i1, int i2) {
        return static_cast<Direction>(get_cell(i1, i2) & kDirectionMask);
    }

    static const int kDirectionSizeBits = 2;
    static const int kDirectionMask = (1 << kDirectionSizeBits) - 1;
    static const int kEmptyCellValue = ~0u << kDirectionSizeBits;

    class ResultWriter {
    public:
        explicit ResultWriter(Comparator::Output* chunk_writer)
            : chunk_writer_(chunk_writer)
            , pos1_(0)
            , pos2_(0)
            , pos1_begin_(-1)
            , pos2_begin_(-1)
            , has_open_chunk_(false) {
        }
        void eq() {
            FlushChunk();
            pos1_++;
            pos2_++;
        }
        void skip1(int len1) {
            StartChunk();
            pos1_ += len1;
        }
        void skip2(int len2) {
            StartChunk();
            pos2_ += len2;
        }
        void close() {
            FlushChunk();
        }

    private:
        Comparator::Output* chunk_writer_;
        int pos1_;
        int pos2_;
        int pos1_begin_;
        int pos2_begin_;
        bool has_open_chunk_;

        void StartChunk() {
            if (!has_open_chunk_) {
                pos1_begin_ = pos1_;
                pos2_begin_ = pos2_;
                has_open_chunk_ = true;
            }
        }

        void FlushChunk() {
            if (has_open_chunk_) {
                chunk_writer_->AddChunk(pos1_begin_, pos2_begin_,
                                        pos1_ - pos1_begin_, pos2_ - pos2_begin_);
                has_open_chunk_ = false;
            }
        }
    };
};

// Additional to Input interface. Lets switch Input range to subrange.
// More elegant way would be to wrap one Input as another Input object
// and translate positions there, but that would cost us additional virtual
// call per comparison.
class SubrangableInput : public Comparator::Input {
public:
    virtual void SetSubrange1(int offset, int len) = 0;
    virtual void SetSubrange2(int offset, int len) = 0;
};

class SubrangableOutput : public Comparator::Output {
public:
    virtual void SetSubrange1(int offset, int len) = 0;
    virtual void SetSubrange2(int offset, int len) = 0;
};

// Wraps raw n-elements line_ends array as a list of n+1 lines. The last line
// never has terminating new line character.
class LineEndsWrapper {
public:
    explicit LineEndsWrapper(WTF::String string)
        : ends_array_(Inspector::ContentSearchUtilities::lineEndings(string))
        , string_len_(string.length()) {
        //        ends_array_ = std::move(Inspector::ContentSearchUtilities::lineEndings(string));
    }

    int length() {
        return ends_array_->size() + 1;
    }
    // Returns start for any line including start of the imaginary line after
    // the last line.
    int GetLineStart(int index) {
        if (index == 0) {
            return 0;
        } else {
            return GetLineEnd(index - 1);
        }
    }
    int GetLineEnd(int index) {
        if ((size_t)index == ends_array_->size()) {
            // End of the last line is always an end of the whole string.
            // If the string ends with a new line character, the last line is an
            // empty string after this character.
            return string_len_;
        } else {
            return GetPosAfterNewLine(index);
        }
    }

private:
    std::unique_ptr<Vector<size_t>> ends_array_;
    int string_len_;

    int GetPosAfterNewLine(int index) {
        return ends_array_->at(index) + 1;
    }
};

static bool CompareSubstrings(WTF::String s1, int pos1,
                              WTF::String s2, int pos2, int len) {
    for (int i = 0; i < len; i++) {
        if (s1.at(i + pos1) != s2.at(i + pos2)) {
            return false;
        }
    }
    return true;
}

// Represents 2 strings as 2 arrays of lines.
class LineArrayCompareInput : public SubrangableInput {
public:
    LineArrayCompareInput(WTF::String s1, WTF::String s2,
                          LineEndsWrapper& line_ends1, LineEndsWrapper& line_ends2)
        : s1_(s1)
        , s2_(s2)
        , line_ends1_(line_ends1)
        , line_ends2_(line_ends2)
        , subrange_offset1_(0)
        , subrange_offset2_(0)
        , subrange_len1_(line_ends1_.length())
        , subrange_len2_(line_ends2_.length()) {
    }
    int GetLength1() {
        return subrange_len1_;
    }
    int GetLength2() {
        return subrange_len2_;
    }
    bool Equals(int index1, int index2) {
        index1 += subrange_offset1_;
        index2 += subrange_offset2_;

        int line_start1 = line_ends1_.GetLineStart(index1);
        int line_start2 = line_ends2_.GetLineStart(index2);
        int line_end1 = line_ends1_.GetLineEnd(index1);
        int line_end2 = line_ends2_.GetLineEnd(index2);
        int len1 = line_end1 - line_start1;
        int len2 = line_end2 - line_start2;
        if (len1 != len2) {
            return false;
        }
        return CompareSubstrings(s1_, line_start1, s2_, line_start2,
                                 len1);
    }
    void SetSubrange1(int offset, int len) {
        subrange_offset1_ = offset;
        subrange_len1_ = len;
    }
    void SetSubrange2(int offset, int len) {
        subrange_offset2_ = offset;
        subrange_len2_ = len;
    }

private:
    WTF::String s1_;
    WTF::String s2_;
    LineEndsWrapper& line_ends1_;
    LineEndsWrapper& line_ends2_;
    int subrange_offset1_;
    int subrange_offset2_;
    int subrange_len1_;
    int subrange_len2_;
};

// A helper class that writes chunk numbers into JSArray.
// Each chunk is stored as 3 array elements: (pos1_begin, pos1_end, pos2_end).
class CompareOutputArrayWriter {
public:
    explicit CompareOutputArrayWriter()
        : array_()
        , current_size_(0) {}

    WTF::Vector<int> GetResult() {
        return array_;
    }

    void WriteChunk(int char_pos1, int char_pos2, int char_len1, int char_len2) {
        array_.insert(current_size_, char_pos1);
        array_.insert(current_size_ + 1, char_pos1 + char_len1);
        array_.insert(current_size_ + 2, char_pos2 + char_len2);

        current_size_ += 3;
    }

private:
    WTF::Vector<int> array_;
    int current_size_;
};

// Represents 2 strings as 2 arrays of tokens.
// TODO(LiveEdit): Currently it's actually an array of charactres.
//     Make array of tokens instead.
class TokensCompareInput : public Comparator::Input {
public:
    TokensCompareInput(WTF::String s1, int offset1, int len1,
                       WTF::String s2, int offset2, int len2)
        : s1_(s1)
        , offset1_(offset1)
        , len1_(len1)
        , s2_(s2)
        , offset2_(offset2)
        , len2_(len2) {
    }
    virtual int GetLength1() {
        return len1_;
    }
    virtual int GetLength2() {
        return len2_;
    }
    bool Equals(int index1, int index2) {
        return s1_.at(offset1_ + index1) == s2_.at(offset2_ + index2);
    }

private:
    WTF::String s1_;
    int offset1_;
    int len1_;
    WTF::String s2_;
    int offset2_;
    int len2_;
};

// Stores compare result in JSArray. Converts substring positions
// to absolute positions.
class TokensCompareOutput : public Comparator::Output {
public:
    TokensCompareOutput(CompareOutputArrayWriter* array_writer,
                        int offset1, int offset2)
        : array_writer_(array_writer)
        , offset1_(offset1)
        , offset2_(offset2) {
    }

    void AddChunk(int pos1, int pos2, int len1, int len2) {
        array_writer_->WriteChunk(pos1 + offset1_, pos2 + offset2_, len1, len2);
    }

private:
    CompareOutputArrayWriter* array_writer_;
    int offset1_;
    int offset2_;
};

void Comparator::CalculateDifference(Comparator::Input* input,
                                     Comparator::Output* result_writer) {
    Differencer differencer(input);
    differencer.Initialize();
    differencer.FillTable();
    differencer.SaveResult(result_writer);
}

// Stores compare result in JSArray. For each chunk tries to conduct
// a fine-grained nested diff token-wise.
class TokenizingLineArrayCompareOutput : public SubrangableOutput {
public:
    TokenizingLineArrayCompareOutput(LineEndsWrapper& line_ends1,
                                     LineEndsWrapper& line_ends2,
                                     WTF::String s1, WTF::String s2)
        : array_writer_()
        , line_ends1_(line_ends1)
        , line_ends2_(line_ends2)
        , s1_(s1)
        , s2_(s2)
        , subrange_offset1_(0)
        , subrange_offset2_(0) {
    }

    void AddChunk(int line_pos1, int line_pos2, int line_len1, int line_len2) {
        line_pos1 += subrange_offset1_;
        line_pos2 += subrange_offset2_;

        int char_pos1 = line_ends1_.GetLineStart(line_pos1);
        int char_pos2 = line_ends2_.GetLineStart(line_pos2);
        int char_len1 = line_ends1_.GetLineStart(line_pos1 + line_len1) - char_pos1;
        int char_len2 = line_ends2_.GetLineStart(line_pos2 + line_len2) - char_pos2;

        if (char_len1 < CHUNK_LEN_LIMIT && char_len2 < CHUNK_LEN_LIMIT) {
            // Chunk is small enough to conduct a nested token-level diff.

            TokensCompareInput tokens_input(s1_, char_pos1, char_len1,
                                            s2_, char_pos2, char_len2);
            TokensCompareOutput tokens_output(&array_writer_, char_pos1,
                                              char_pos2);

            Comparator::CalculateDifference(&tokens_input, &tokens_output);
        } else {
            array_writer_.WriteChunk(char_pos1, char_pos2, char_len1, char_len2);
        }
    }
    void SetSubrange1(int offset, int len) {
        subrange_offset1_ = offset;
    }
    void SetSubrange2(int offset, int len) {
        subrange_offset2_ = offset;
    }

    WTF::Vector<int> GetResult() {
        return array_writer_.GetResult();
    }

private:
    static const int CHUNK_LEN_LIMIT = 800;

    CompareOutputArrayWriter array_writer_;
    LineEndsWrapper& line_ends1_;
    LineEndsWrapper& line_ends2_;
    WTF::String s1_;
    WTF::String s2_;
    int subrange_offset1_;
    int subrange_offset2_;
};

static int min(int a, int b) {
    return a < b ? a : b;
}

// Finds common prefix and suffix in input. This parts shouldn't take space in
// linear programming table. Enable subranging in input and output.
static void NarrowDownInput(SubrangableInput* input,
                            SubrangableOutput* output) {
    const int len1 = input->GetLength1();
    const int len2 = input->GetLength2();

    int common_prefix_len;
    int common_suffix_len;

    {
        common_prefix_len = 0;
        int prefix_limit = min(len1, len2);
        while (common_prefix_len < prefix_limit && input->Equals(common_prefix_len, common_prefix_len)) {
            common_prefix_len++;
        }

        common_suffix_len = 0;
        int suffix_limit = min(len1 - common_prefix_len, len2 - common_prefix_len);

        while (common_suffix_len < suffix_limit && input->Equals(len1 - common_suffix_len - 1, len2 - common_suffix_len - 1)) {
            common_suffix_len++;
        }
    }

    if (common_prefix_len > 0 || common_suffix_len > 0) {
        int new_len1 = len1 - common_suffix_len - common_prefix_len;
        int new_len2 = len2 - common_suffix_len - common_prefix_len;

        input->SetSubrange1(common_prefix_len, new_len1);
        input->SetSubrange2(common_prefix_len, new_len2);

        output->SetSubrange1(common_prefix_len, new_len1);
        output->SetSubrange2(common_prefix_len, new_len2);
    }
}

class PosTranslator {
public:
    PosTranslator(WTF::Vector<int> diff_array)
        : m_diffArray(diff_array) {
        int current_diff = 0;
        for (int i = 0; (size_t)i < diff_array.size(); i += 3) {
            int pos1_begin = diff_array.at(i);
            int pos2_begin = pos1_begin + current_diff;
            int pos1_end = diff_array.at(i + 1);
            int pos2_end = diff_array.at(i + 2);
            m_chunks.append(DiffChunk{ pos1_begin, pos2_begin, pos1_end - pos1_begin, pos2_end - pos2_begin });
            current_diff = pos2_end - pos1_end;
        }
    }

    WTF::Vector<DiffChunk> GetResult() {
        return m_chunks;
    }

private:
    WTF::Vector<int> m_diffArray;
    WTF::Vector<DiffChunk> m_chunks;
};

WTF::Vector<DiffChunk> TextualDifferencesHelper::CompareStrings(WTF::String s1, WTF::String s2) {
    LineEndsWrapper line_ends1(s1);
    LineEndsWrapper line_ends2(s2);

    LineArrayCompareInput input(s1, s2, line_ends1, line_ends2);
    TokenizingLineArrayCompareOutput output(line_ends1, line_ends2, s1, s2);

    NarrowDownInput(&input, &output);

    Comparator::CalculateDifference(&input, &output);

    auto result = output.GetResult();
    PosTranslator posTranslator(result);

    return posTranslator.GetResult();
}
}