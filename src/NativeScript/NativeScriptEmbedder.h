//
//  NativeScriptEmbedder.h
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 6/19/18.
//
#include <UIKit/UIKit.h>

// When embedding NativeScript application embedder needs to conform to this protocol
// in order to have control over the NativeScript UIViewController
// otherwise NativeScript application is presented over the topmost UIViewController.
// Implemented in tns-core-modules by the following PR:
// https://github.com/NativeScript/NativeScript/pull/5967
@protocol NativeScriptEmbedder
- (id)presentNativeScriptApp:(UIViewController*)vc;
@end
