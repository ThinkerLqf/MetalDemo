//
//  TriangleShader.metal
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/4.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#include <metal_stdlib>
#include "TriangleShaderTypes.h"
using namespace metal;

typedef struct {
    vector_float4 position [[position]];
    vector_float4 color;
} RasterizationData;

vertex RasterizationData
vertexShader (constant Vertex *vertexArr [[buffer(0)]],
              uint vid [[vertex_id]])
{
    RasterizationData out;
    
    float4 position = vector_float4(vertexArr[vid].coordinates, 0, 1.0);
    out.position = position;
    
    return out;
}


fragment float4
fragmentShader (RasterizationData in [[stage_in]]) {
//    return in.color;
    return {0.984, 0.447, 0.6, 1};
}
