//
//  Demo3Adder.m
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/11.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import "Demo3Adder.h"

// 官方文档及译文：https://www.jianshu.com/p/2aa27b07e9c4

// 比官方demo的length小很多，方便调试，打印每个元素的值
const unsigned int arrayLength = 1 << 4;
const unsigned int bufferSize = arrayLength * sizeof(float);

@implementation Demo3Adder
{
    id<MTLDevice> _mDevice;
    
    id<MTLComputePipelineState> _mAddFunctionPSO;
    
    id<MTLCommandQueue> _mCommanQueue;
    
    id<MTLBuffer> _mBufferA;
    id<MTLBuffer> _mBufferB;
    id<MTLBuffer> _mBufferResult;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    self = [super init];
    if (self)
    {
        // 初始化基本的Metal对象
        if (![self _initBasicMetalObject:device])
        {
            return nil;
        }
    }
    return self;
}

- (void)beginShow {
    // 加载要执行的GPU数据
    [self _prepareData];
    
    [self _sendComputeCommand];
}

#pragma mark - Init
- (BOOL)_initBasicMetalObject:(id<MTLDevice>)device
{
    _mDevice = device;
    
    // 引用（自定义的）Metal函数
    id<MTLLibrary> defaultLibrary = [_mDevice newDefaultLibrary];
    if (defaultLibrary == nil)
    {
        NSLog(@"Failed to find the default library.");
        return NO;
    }
    
    id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"my_add_arrays"];
    if (addFunction == nil)
    {
        NSLog(@"Failed to find the adder function.");
        return NO;
    }
    
    // addFunction只是真正MSL函数的代理，不是可执行代码。
    // 通过创建管道将函数转换为可执行代码
    NSError *error = nil;
    _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction:addFunction error:&error];
    if (_mAddFunctionPSO == nil)
    {
        NSLog(@"Failed to created pipeline state object, error %@.", error);
        return NO;
    }
    
    // Metal使用命令队列来调度命令
    _mCommanQueue = [_mDevice newCommandQueue];
    if (_mCommanQueue == nil)
    {
        NSLog(@"Failed to find the command queue.");
        return NO;
    }
    return YES;
}

#pragma mark - Data

- (void)_prepareData
{
    // MTLResourceStorageModeShared 可供CPU和GPU使用
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    
    [self _generateRandomFloatData:_mBufferA];
    [self _generateRandomFloatData:_mBufferB];
    [self _generateRandomResultData];
}

- (void)_generateRandomFloatData:(id<MTLBuffer>)buffer
{
    float *dataPtr = buffer.contents;
    
    for (unsigned long index = 0; index < arrayLength; index++)
    {
        dataPtr[index] = (float)rand()/(float)(RAND_MAX);
        printf("index:%lu value:%g\n", index, dataPtr[index]);
    }
}

/// 发现使用模拟器进行调试时结果不符合预期，加了该函数对比确认了.metal函数没有正常调用。只能真机
- (void)_generateRandomResultData
{
    float *dataPtr = _mBufferResult.contents;
    
    for (unsigned long index = 0; index < arrayLength; index++) {
        dataPtr[index] = 0.11111;
    }
}

#pragma mark - Compute Pass

- (void)_sendComputeCommand
{
    // 创建 commandBuffer 保存 命令
    id<MTLCommandBuffer> commandBuffer = [_mCommanQueue commandBuffer];
    assert(commandBuffer != nil);
    
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull cb) {
        NSLog(@"ccc");
    }];
    
    // 开始计算过程
    // 每个 Compute Command 都会使 GPU 创建一个线程网格
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    assert(computeEncoder != nil);
    
    [self _encodeAddCommand:computeEncoder];
    
    // 结束计算过程
    [computeEncoder endEncoding];
    
    // 执行命令 将缓冲区提交到队列
    [commandBuffer commit];
    
    
    [commandBuffer waitUntilCompleted];
    
    [self _verifyResults];
}

// 为管道发送到MSL函数的参数设置数据
- (void)_encodeAddCommand:(id<MTLComputeCommandEncoder>)computerEncoder
{
    [computerEncoder setComputePipelineState:_mAddFunctionPSO];
    // 偏移量用在一个缓冲区存储了多个参数时
    [computerEncoder setBuffer:_mBufferA offset:0 atIndex:0];
    [computerEncoder setBuffer:_mBufferB offset:0 atIndex:1];
    [computerEncoder setBuffer:_mBufferResult offset:0 atIndex:2];
    
    /* 真机 特有, 模拟不支持*/
    // 指定线程数 以及 以一维的方式组织线程
    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
    
    // Threadgroup是更小的网格，每个线程组单独计算，加快处理速度
    NSUInteger threadGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
    if (threadGroupSize > arrayLength)
    {
        // 收缩最大线程组
        threadGroupSize = arrayLength;
    }
    MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
    
    // 分派线程网格
    [computerEncoder dispatchThreads:gridSize threadsPerThreadgroup:threadgroupSize];
}

- (void)_verifyResults
{
    float *a = _mBufferA.contents;
    float *b = _mBufferB.contents;
    float *result = _mBufferResult.contents;
    
    for (unsigned long index = 0; index < arrayLength; index++)
    {
        if (result[index] != (a[index] + b[index])) {
            printf("Compute ERROR: index:%lu result:%g vs %g=a+b\n", index, result[index], a[index]+b[index]);
            assert(result[index] == (a[index] + b[index]));
        }
    }
    
    printf("Compute results as expected.\n");
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"Good luck!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertC addAction:action];
    
    NSArray<UIWindow *> *windows = [UIApplication sharedApplication].windows;
    UIViewController *rootVC = windows.firstObject.rootViewController;
    [rootVC presentViewController:alertC animated:NO completion:nil];
}

@end
