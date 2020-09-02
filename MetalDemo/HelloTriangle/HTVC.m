//
//  HTVC.m
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/28.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import "HTVC.h"
#import "HTRenderer.h"

@implementation HTVC {
    MTKView *_view;
    HTRenderer *_renderer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _view = (MTKView *)self.view;
    _view.device = MTLCreateSystemDefaultDevice();
    _view.enableSetNeedsDisplay = YES;
    _view.clearColor = MTLClearColorMake(255, 255, 255, 1);
    NSAssert(_view.device, @"Metal is not supported on this device.");
    
    _renderer = [[HTRenderer alloc] initWithMetalKitView:_view];
    NSAssert(_renderer, @"Renderer failed initialization.");
    
    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
    _view.delegate = _renderer;
    
}


@end
