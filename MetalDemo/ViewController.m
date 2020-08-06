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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn1 setTitle:@"渐变LED灯" forState:UIControlStateNormal];
    [btn1 setFrame:CGRectMake(50, 200, 200, 44)];
    [btn1 addTarget:self action:@selector(_horseRaceLamp) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setTitleColor:[UIColor colorWithRed:32/255.0 green:170/255.0 blue:226/255.0 alpha:1] forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn2 setTitle:@"三角形" forState:UIControlStateNormal];
    [btn2 setFrame:CGRectMake(50, 300, 200, 44)];
    [btn2 addTarget:self action:@selector(_triangle) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitleColor:[UIColor colorWithRed:32/255.0 green:170/255.0 blue:226/255.0 alpha:1] forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    
}

- (void)_triangle {
    TriangleViewController *triangleVC = [[TriangleViewController alloc] init];
    [self.navigationController pushViewController:triangleVC animated:YES];
}

- (void)_horseRaceLamp {
    HorseRaceLampVC *vc = [[HorseRaceLampVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
