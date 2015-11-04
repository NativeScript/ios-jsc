#import "TNSReturnsUnmanaged.h"

CFArrayRef functionReturnsUnmanaged() {
    return CFArrayCreate(NULL, NULL, 0, &kCFTypeArrayCallBacks);
}