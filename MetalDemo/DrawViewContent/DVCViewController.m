//
//  DVCViewController.m
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/13.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import "DVCViewController.h"
#import "DVCRenderer.h"

@interface DVCViewController ()
{
    // vc是基于xib文件，且在xib中修改了view的class指向类才可以
    MTKView *_mtkView;
    DVCRenderer *_renderer;
}

@end

@implementation DVCViewController

- (void)viewDidLoad {
    /*
     怎样可以设置大括号另起一行，跟Apple官方文档中的格式一样。
     查到一个方法，需要搞一个插件https://github.com/travisjeffery/ClangFormat-Xcode
     有时间了试一下
     */
    
    [super viewDidLoad];
    
    _mtkView = (MTKView *)self.view;
    
    // 仅在需要更新内容时才绘制
    _mtkView.enableSetNeedsDisplay = YES;
    
    _mtkView.device = MTLCreateSystemDefaultDevice();
    
    _mtkView.clearColor = MTLClearColorMake(0.125, 0.667, 0.886, 1);
    
    _renderer = [[DVCRenderer alloc] initWithMTKView:_mtkView];
    
    if (_renderer == nil) {
        NSLog(@"Renderer initialization failed.");
        return;
    }
    
    /*
     还不太清楚该行代码的具体作用。注释掉之后仍会触发一次渲染。
     */
    //[_renderer mtkView:_mtkView drawableSizeWillChange:_mtkView.drawableSize];
    
    _mtkView.delegate = _renderer;
    
}
@end
