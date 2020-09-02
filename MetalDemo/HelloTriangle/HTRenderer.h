//
//  HTRenderer.h
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/28.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTRenderer : NSObject <MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
