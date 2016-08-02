#import "TNSReturnsUnmanaged.h"

CFArrayRef functionReturnsUnmanaged() {
    CFStringRef values[] = { CFSTR("String One"), CFSTR("String Two"), CFSTR("String Three") };
    CFArrayRef array = CFArrayCreate(NULL, (const void**)values, sizeof(values) / sizeof(values[0]), &kCFTypeArrayCallBacks);
    return array;
}
