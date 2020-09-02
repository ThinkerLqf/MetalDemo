//
//  HorseRaceLampVC.m
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/3.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import "HorseRaceLampVC.h"
#import "HorseRaceLampRenderer.h"
#import <MetalKit/MetalKit.h>

@interface HorseRaceLampVC ()

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) HorseRaceLampRenderer *renderer;

@end

@implementation HorseRaceLampVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self _initMtkView];
}

- (void)_initMtkView {
    
    [self.view addSubview:self.mtkView];
    
    // GPU Device
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    if (!(self.mtkView.device)) {
        NSLog(@"Metal is not supported on this device.");
        return;
    }
    
    // Renderer
    if (!self.renderer) {
        NSLog(@"Renderer failed init.");
        return;
    }
    
    // Delegate
    [self.mtkView setDelegate:self.renderer];
    
    // 帧率默认60
    self.mtkView.preferredFramesPerSecond = 30;
}

- (HorseRaceLampRenderer *)renderer {
    if (!_renderer) {
        _renderer = [[HorseRaceLampRenderer alloc] initWithMTKView:self.mtkView];
    }
    return _renderer;
}

- (MTKView *)mtkView {
    if (!_mtkView) {
        _mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    }
    return _mtkView;
}

@end
