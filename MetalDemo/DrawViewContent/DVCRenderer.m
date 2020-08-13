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
    
    /* Texture
     纹理：包含图像数据的内存块，可供GPU访问。
     MTKView会创建绘制所需的所有纹理。
     */
    
    /* Rendar Pass
     绘制需要创建渲染过程，也就是储存到纹理中的渲染命令序列。
     此处纹理也可以称为渲染过程的目标。
     */
    
    
    /* Render Pass Descroptor
     创建渲染路径需要一个渲染过程描述符(RPD)。
     RPD可以定义渲染哪些方面，该例不涉及，只有默认的颜色渲染。
     此处使用MTKView进行创建。
     */
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor == nil) {
        return;
    }
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    /*
     Render Command Encoder
     创建渲染过程:将该对象(通过RPD生成)编码到命令缓冲区来实现。
    */
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    [commandEncoder endEncoding];
    
    
    /*
     Drawable Object
     该对象管理可以在屏幕上显示的纹理。并且连接到Core Animation.
    */
    id<MTLDrawable> drawable = view.currentDrawable;
    
    /*
     presentDrawable:方法告诉Metal，与Core Animation协调以在渲染完成后显示纹理。
     */
    [commandBuffer presentDrawable:drawable];
    
    [commandBuffer commit];
    
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end
