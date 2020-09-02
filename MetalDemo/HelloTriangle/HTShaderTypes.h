//
//  HTShaderTypes.h
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/25.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#ifndef HTShaderTypes_h
#define HTShaderTypes_h

#include <simd/simd.h>

/*
 着色器和C代码之间共享的缓冲区索引值，
 以确保金属着色器缓冲区输入与金属API缓冲区集调用匹配。
 */
typedef enum HTVertexInputIndex {
    HTVertexInputIndexVertices = 0,
    HTVertexInputIndexViewportSize = 1,
} HTVertexInputIndex;

/*
 此结构定义发送到顶点着色器的顶点的布局。
 在.metal着色器和C代码之间共享，
 以确保C代码中顶点数组的布局与.metal顶点着色器预期的布局匹配。
 */
typedef struct {
    vector_float2 position;
    vector_float4 color;
} HTVertex;

#endif /* HTShaderTypes_h */
