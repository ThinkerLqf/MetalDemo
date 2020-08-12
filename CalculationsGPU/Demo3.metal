//
//  Demo3.metal
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/11.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// 编译阶段加入Metal库
kernel void my_add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]]) {
    result[index] = inA[index] + inB[index];
}
