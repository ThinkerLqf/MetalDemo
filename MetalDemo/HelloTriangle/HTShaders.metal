//
//  HTShaders.metal
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/25.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

// 包含此金属着色器代码和执行Metal API命令的C代码之间共享的枚举和结构体
#import "HTShaderTypes.h"

// 顶点着色器输出和片段着色器输入
typedef struct {
    // 此成员的[[position]]属性表示该值是从vertex函数返回此结构时顶点的剪辑空间位置
    float4 position [[position]];
    /*
     由于该成员没有特殊属性，因此光栅化会使用其他三角形顶点的值对其值进行插值，
     然后将插值值传递给三角形中每个片段的片段着色器。
     */
    float4 color;
} RasterizerData;

vertex RasterizerData
htVertexShader(uint vertexID [[vertex_id]],
               constant HTVertex *vertices [[buffer(HTVertexInputIndexVertices)]],
               constant vector_uint2 *viewportSizePointer [[buffer(HTVertexInputIndexViewportSize)]]) {
    RasterizerData out;
    /*
     索引到位置数组以获取当前顶点。
     位置以像素尺寸指定（即，值100表示距离原点100个像素）。
     */
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    // 获取视口大小并将其转换为浮动值
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    // 要从像素空间中的位置转换为剪辑空间中的位置，请将像素坐标除以视口大小的一半
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    // 将输入颜色直接传递到光栅化器
    out.color = vertices[vertexID].color;
    
    return out;
}

fragment float4 htFragmentShader(RasterizerData in [[stage_in]]) {
    return in.color;
}
