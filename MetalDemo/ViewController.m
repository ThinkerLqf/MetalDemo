//
//  ViewController.m
//  MetalDemo
//
//  Created by LiQunfei on 2020/8/3.
//  Copyright © 2020 LiQunfei. All rights reserved.
//

#import "ViewController.h"
#import "HorseRaceLampVC.h"
#import "TriangleViewController.h"
#import "Demo3Adder.h"
#import "DVCViewController.h"
#import <MetalKit/MetalKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat scrollY = 200;
    CGFloat scrollBottom = 100;
    CGRect scrollRect = CGRectMake(0, scrollY, screenSize.width, screenSize.height - scrollY - scrollBottom);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
    scrollView.backgroundColor = [UIColor colorWithRed:1 green:0.776 blue:0.286 alpha:0.1];
    [self.view addSubview:scrollView];
    
    CGFloat contentHeight = 0.f;
    
    CGFloat x = 0.f;
    CGFloat y1 = 20.f;
    CGFloat w = screenSize.width;
    CGFloat h = 44.f;
    CGRect rect1 = CGRectMake(x, y1, w, h);
    
    // btn1
    UIButton *btn1 = [self _qfButtonWithTitle:@"渐变LED灯"
                                      frame:rect1
                                     action:@selector(_qfHorseRaceLamp)];
    [scrollView addSubview:btn1];
    
    contentHeight += h;
    
    // btn2
    CGFloat vGap = 0.f;
    CGFloat y2 = y1 + h + vGap;
    CGRect rect2 = CGRectMake(x, y2, w, h);
    
    UIButton *btn2 = [self _qfButtonWithTitle:@"三角形(错误示范)"
                                      frame:rect2
                                     action:@selector(_qfTriangle)];
    [btn2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [btn2 setEnabled:NO];
    [scrollView addSubview:btn2];
    
    contentHeight += (vGap + h);
    
    // btn3
    CGFloat y3 = y2 + vGap + h;
    CGRect rect3 = CGRectMake(x, y3, w, h);
    
    UIButton *btn3 = [self _qfButtonWithTitle:@" 官1:Performing Calculations on a GPU.\n备注:只能真机"
                                      frame:rect3
                                     action:@selector(_qfPerformingCalculationsOnAGPU)];
    [btn3.titleLabel setNumberOfLines:2];
    [scrollView addSubview:btn3];
    
    contentHeight += (vGap + h);
    
    // btn4
    CGFloat y4 = y3 + vGap + h;
    CGRect rect4 = CGRectMake(x, y4, w, h);
    UIButton *btn4 = [self _qfButtonWithTitle:@"官2:Using Metal to Draw a View’s Contents"
                                        frame:rect4
                                       action:@selector(_qfUsingMetalToDrawAViewContents)];
    [scrollView addSubview:btn4];
    
    contentHeight += (vGap + h);
    
    [scrollView setContentSize:CGSizeMake(screenSize.width, MAX(contentHeight, scrollRect.size.height))];
}

#pragma mark - Action

#pragma mark - 官方demo 2

- (void)_qfUsingMetalToDrawAViewContents {
    DVCViewController *vc = [[DVCViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 官方demo 1
// C形式本尊 本例用Metal实现
void add_arrays(const float* inA,
                const float* inB,
                float* result,
                int length) {
    for (int index = 0; index < length; index++) {
        result[index] = inA[index] + inB[index];
    }
}

- (void)_qfPerformingCalculationsOnAGPU {
    
    id <MTLDevice> device = MTLCreateSystemDefaultDevice();
    
    Demo3Adder *adder = [[Demo3Adder alloc] initWithDevice:device];
    
    [adder beginShow];
    
}

#pragma mark TriangleView
- (void)_qfTriangle {
    TriangleViewController *triangleVC = [[TriangleViewController alloc] init];
    [self.navigationController pushViewController:triangleVC animated:YES];
}

#pragma mark HorseRaceLamp
- (void)_qfHorseRaceLamp {
    HorseRaceLampVC *vc = [[HorseRaceLampVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Button

- (UIButton *)_qfButtonWithTitle:(NSString *)title frame:(CGRect)frame action:(SEL)sel {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setFrame:frame];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIColor *titleColor = [UIColor colorWithRed:0.125 green:0.667 blue:0.886 alpha:1];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    return btn;
}

@end
