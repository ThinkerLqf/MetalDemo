//
//  HorseRaceLampRenderer.h
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/3.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HorseRaceLampRenderer : NSObject <MTKViewDelegate>

- (instancetype)initWithMTKView:(MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
