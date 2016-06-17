#pragma once

namespace NativeScript {
class EditableSourceProvider : public JSC::SourceProvider {
public:
    static Ref<EditableSourceProvider> create(const WTF::String& source, const WTF::String& url, const WTF::TextPosition& startPosition = WTF::TextPosition::minimumPosition()) {
        return adoptRef(*new EditableSourceProvider(source, url, startPosition));
    }

    const String& source() const override {
        return this->m_source;
    }

    void setSource(WTF::String source) {
        this->m_source = source;
    }

private:
    EditableSourceProvider(const WTF::String& source, const WTF::String& url, const WTF::TextPosition& startPosition)
        : JSC::SourceProvider(url, startPosition)
        , m_source(source) {
    }

    WTF::String m_source;
};
}
