//
//  HorseRaceLampRenderer.m
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/3.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import "HorseRaceLampRenderer.h"

typedef struct {
    float red, green, blue, alpha;
} Color;

@interface HorseRaceLampRenderer () {
    id<MTLCommandQueue> _commandQueue;
}

@end

@implementation HorseRaceLampRenderer

- (instancetype)initWithMTKView:(MTKView *)mtkView {
    self = [super init];
    if (self) {
        _commandQueue = [mtkView.device newCommandQueue];
    }
    return self;
}

- (Color)_makeFancyColor {
    
    static BOOL growing = YES;
    
    // 0~3
    static NSUInteger primaryChannel = 0;
    
    static float colorChannels[] = {1.0, 0.0, 0.0, 1.0};
    
    const float dynamicColorRate = 0.015;
    
    if (growing) {
        
        NSUInteger dynamicChannelsIndex = (primaryChannel + 1)%3;
        
        colorChannels[dynamicChannelsIndex] += dynamicColorRate;
        
        if (colorChannels[dynamicChannelsIndex] >= 1.0) {
            
            growing = NO;
            
            primaryChannel = dynamicChannelsIndex;
            
        }
        
    }
    else {
        
        NSUInteger dynamicChannelsIndex = (primaryChannel + 2)%3;
        
        colorChannels[dynamicChannelsIndex] -= dynamicColorRate;
        
        if (colorChannels[dynamicChannelsIndex] <= 0.0) {
            
            growing = YES;
            
        }
        
    }
    
    Color color;
    color.red = colorChannels[0];
    color.green = colorChannels[1];
    color.blue = colorChannels[2];
    color.alpha = colorChannels[3];
    
    return color;
}

#pragma mark MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    Color color = [self _makeFancyColor];
    view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, color.alpha);
    
    id<MTLCommandBuffer> commanBuffer = [_commandQueue commandBuffer];
    commanBuffer.label = @"MyCommanBuffer";
    
    // 渲染描述符
    MTLRenderPassDescriptor *renderPD = view.currentRenderPassDescriptor;
    
    if (renderPD != nil) {
        
        // CommandEncoder 对象
        id <MTLRenderCommandEncoder> renderEncoder = [commanBuffer renderCommandEncoderWithDescriptor:renderPD];
        
        renderEncoder.label = @"MyRenderEncoder";
        
        // 显示到可绘制的View
        [commanBuffer presentDrawable:view.currentDrawable];
        
        [renderEncoder endEncoding];
    }
    
    // 渲染命令结束后，
    [commanBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end
