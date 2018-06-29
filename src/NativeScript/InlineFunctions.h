//
//  InlineFunctions.h
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 6/27/18.
//

#import <SceneKit/SceneKit.h>

// This FOUNDATION_EXPORT here is required due to
// certain metadata-generator behavior we encountered
// while implementing following inline functions.
// As cpp compilation mangles symbols we had to mark
// functions as 'extern C'.
// Metadata-generator though works in ObjC mode
// and doesn't parse cpp constructs.

#pragma mark - SceneKit

FOUNDATION_EXPORT SCNVector3 _SCNVector3Make(float x, float y, float z);

FOUNDATION_EXPORT SCNVector4 _SCNVector4Make(float x, float y, float z, float w);

FOUNDATION_EXPORT SCNMatrix4 _SCNMatrix4Translate(SCNMatrix4 m, float tx, float ty, float tz);

FOUNDATION_EXPORT vector_float3 _SCNVector3ToFloat3(SCNVector3 v);

FOUNDATION_EXPORT vector_float4 _SCNVector4ToFloat4(SCNVector4 v);

FOUNDATION_EXPORT matrix_float4x4 _SCNMatrix4ToMat4(SCNMatrix4 m);

FOUNDATION_EXPORT SCNVector3 _SCNVector3FromFloat3(vector_float3 v);

FOUNDATION_EXPORT SCNVector4 _SCNVector4FromFloat4(vector_float4 v);

FOUNDATION_EXPORT SCNMatrix4 _SCNMatrix4FromMat4(matrix_float4x4 m);
