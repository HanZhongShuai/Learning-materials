//
//  RC_WaterWave.h
//  iOSLivU
//
//  Created by RC on 2017/6/30.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RC_WaterWave : UIView

@property (assign, nonatomic) CGFloat angularSpeed;
@property (assign, nonatomic) CGFloat waveSpeed;
@property (assign, nonatomic) NSTimeInterval waveTime;
@property (strong, nonatomic) UIColor *waveColor;

+ (instancetype)addToView:(UIView *)view withFrame:(CGRect)frame;

- (BOOL)wave;
- (void)stop;

@end
