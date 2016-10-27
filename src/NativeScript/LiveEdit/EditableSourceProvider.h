#pragma once

namespace NativeScript {
class EditableSourceProvider : public JSC::SourceProvider {
public:
    static Ref<EditableSourceProvider> create(const WTF::String& source, const WTF::String& url, const WTF::TextPosition& startPosition = WTF::TextPosition::minimumPosition(), JSC::SourceProviderSourceType sourceType = JSC::SourceProviderSourceType::Program) {
        return adoptRef(*new EditableSourceProvider(source, url, startPosition, sourceType));
    }

    unsigned hash() const override {
        return this->m_source.get().hash();
    }

    StringView source() const override {
        return this->m_source.get();
    }

    void setSource(WTF::String source) {
        this->m_source = source.isNull() ? *StringImpl::empty() : *source.impl();
    }

private:
    EditableSourceProvider(const WTF::String& source, const WTF::String& url, const WTF::TextPosition& startPosition, JSC::SourceProviderSourceType sourceType)
        : JSC::SourceProvider(url, startPosition, sourceType)
        , m_source(source.isNull() ? *StringImpl::empty() : *source.impl()) {
    }

    Ref<StringImpl> m_source;
};
}
