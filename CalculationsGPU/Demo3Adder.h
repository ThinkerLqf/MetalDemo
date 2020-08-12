//
//  Demo3Adder.h
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/11.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Demo3Adder : NSObject

- (instancetype)initWithDevice:(id<MTLDevice>)device;

- (void)beginShow;

@end

NS_ASSUME_NONNULL_END
