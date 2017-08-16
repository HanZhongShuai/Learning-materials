//
//  ViewController.m
//  RC_RangeSlider
//
//  Created by RC on 2017/5/2.
//  Copyright © 2017年 RC. All rights reserved.
//

#import "ViewController.h"
#import "RC_RangeSlider.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSlider];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)addSlider
{
    RC_RangeSlider *slider = [[RC_RangeSlider alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    slider.title = @"Age";
    slider.maxValue = 65;
    slider.minValue = 0;
    slider.lowerValue = 24;
    slider.upperValue = 24;
    [self.view addSubview:slider];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
