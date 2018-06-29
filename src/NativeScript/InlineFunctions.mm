//
//  InlineFunctions.cpp
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 6/27/18.
//

#include "InlineFunctions.h"

SCNVector3 _SCNVector3Make(float x, float y, float z) {
    return SCNVector3Make(x, y, z);
}

SCNVector4 _SCNVector4Make(float x, float y, float z, float w) {
    return SCNVector4Make(x, y, z, w);
}

SCNMatrix4 _SCNMatrix4Translate(SCNMatrix4 m, float tx, float ty, float tz) {
    return SCNMatrix4Translate(m, tx, ty, tz);
}

vector_float3 _SCNVector3ToFloat3(SCNVector3 v) {
    return SCNVector3ToFloat3(v);
}

vector_float4 _SCNVector4ToFloat4(SCNVector4 v) {
    return SCNVector4ToFloat4(v);
}

matrix_float4x4 _SCNMatrix4ToMat4(SCNMatrix4 m) {
    return SCNMatrix4ToMat4(m);
}

SCNVector3 _SCNVector3FromFloat3(vector_float3 v) {
    return SCNVector3FromFloat3(v);
}

SCNVector4 _SCNVector4FromFloat4(vector_float4 v) {
    return SCNVector4FromFloat4(v);
}

SCNMatrix4 _SCNMatrix4FromMat4(matrix_float4x4 m) {
    return SCNMatrix4FromMat4(m);
}
