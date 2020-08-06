//
//  TriangleRenderer.m
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/4.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import "TriangleRenderer.h"
#import "TriangleShaderTypes.h"

@implementation TriangleRenderer {
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLDepthStencilState> _depthState;
    
    id<MTLBuffer> _vertexBuffer;
}

- (instancetype)initWithMTKView:(MTKView *)mtkView {
    self = [super init];
    if (self) {
        [self _loadMetalWithView:mtkView];
        [self _loadAssets];
    }
    return self;
}

- (void)_loadMetalWithView:(MTKView *)view {
    _device = view.device;
    _commandQueue = [_device newCommandQueue];
    
    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"TrianglePipeline";
    pipelineStateDescriptor.sampleCount = view.sampleCount;
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat;
    
    NSError *error = NULL;
    
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    
    if (!_pipelineState || error) {
        NSAssert(NO, @"_pipelineState init failed.");
    }
    
    MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStateDesc.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
}

- (void)_loadAssets {
    static const Vertex ver[] = {
        {{   0,  0.5}, {0.984, 0.447, 0.6, 1}},
        {{ 0.5, -0.5}, {0.984, 0.447, 0.6, 1}},
        {{-0.5, -0.5}, {0.984, 0.447, 0.6, 1}}
    };
    _vertexBuffer = [_device newBufferWithBytes:ver length:sizeof(ver) options:MTLResourceStorageModeShared];
}

#pragma mark - MTKViewDelegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

- (void)drawInMTKView:(MTKView *)view {
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"TriangleCommanBuffer";
    
    view.clearColor = MTLClearColorMake(0.125, 0.667, 0.886, 1);
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor) {
        
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"TriangleRenderEncoder";
        
        [renderEncoder pushDebugGroup:@"DrawTriangle"];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setDepthStencilState:_depthState];
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [renderEncoder popDebugGroup];
        
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    else {
        return;
    }
    
    [commandBuffer commit];
}

@end
