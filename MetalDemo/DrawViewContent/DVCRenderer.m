//
//  DVCRenderer.m
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/12.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import "DVCRenderer.h"

@implementation DVCRenderer
{
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
}

- (instancetype)initWithMTKView:(MTKView *)mtkView
{
    self = [super init];
    if (self) {
        
        _device = mtkView.device;
        
        _commandQueue = [_device newCommandQueue];
        
    }
    return self;
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView *)view {
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor == nil) {
        return;
    }
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    [commandEncoder endEncoding];
    
    id<MTLDrawable> drawable = view.currentDrawable;
    
    [commandBuffer presentDrawable:drawable];
    
    [commandBuffer commit];
    
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end
