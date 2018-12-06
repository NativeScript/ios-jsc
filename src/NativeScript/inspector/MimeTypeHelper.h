
#ifndef NativeScript_MimeTypeHelper_h
#define NativeScript_MimeTypeHelper_h

#import <MobileCoreServices/MobileCoreServices.h>

namespace NativeScript {

static WTF::String mimeTypeByExtension(WTF::String extension) {
    if (extension.isEmpty()) {
        return WTF::emptyString();
    }

#if PLATFORM(IOS)
    // UTI for iOS doesn't recognize css extensions and returns a dynamic UTI without a Mime Type
    if (WTF::equal(extension, "css")) {
        return "text/css"_s;
    }
#endif

    if (WTF::equal(extension, "ts")) {
        return "text/typescript"_s;
    }

    RetainPtr<CFStringRef> cfExtension = extension.createCFString();

    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, cfExtension.get(), NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);

    WTF::String mimeType = "text/plain"_s;
    if (MIMEType != nullptr) {
        mimeType = WTF::String(MIMEType);
        CFRelease(MIMEType);
    }

    CFRelease(UTI);

    return mimeType;
}
} // namespace NativeScript

#endif
