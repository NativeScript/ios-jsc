
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
        return WTF::ASCIILiteral("text/css");
    }
#endif

    if (WTF::equal(extension, "ts")) {
        return WTF::ASCIILiteral("text/typescript");
    }

    RetainPtr<CFStringRef> cfExtension = extension.createCFString();

    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, cfExtension.get(), NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);

    WTF::String mimeType = WTF::ASCIILiteral("text/plain");
    if (MIMEType != nullptr) {
        mimeType = WTF::String(MIMEType);
        CFRelease(MIMEType);
    }

    CFRelease(UTI);

    return mimeType;
}
}

#endif
