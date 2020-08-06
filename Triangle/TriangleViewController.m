//
//  TriangleViewController.m
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/4.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import "TriangleViewController.h"
#import "TriangleRenderer.h"
#import <MetalKit/MetalKit.h>

@interface TriangleViewController ()

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) TriangleRenderer *renderer;

@end

@implementation TriangleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _initMTKView];
}

- (void)_initMTKView {
    
    [self.view addSubview:self.mtkView];
    
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    if (!self.mtkView.device) {
        NSLog(@"Metal is not supported on this device.");
        return;
    }
    
    if (self.renderer) {
        self.mtkView.delegate = self.renderer;
    }
    else {
        NSLog(@"MTKView delegate failed init.");
        return;
    }
    
}

- (TriangleRenderer *)renderer {
    if (!_renderer) {
        _renderer = [[TriangleRenderer alloc] initWithMTKView:self.mtkView];
    }
    return _renderer;
}

- (MTKView *)mtkView {
    if (!_mtkView) {
        _mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
        _mtkView.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
        _mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        _mtkView.sampleCount = 1;
    }
    return _mtkView;
}

@end
