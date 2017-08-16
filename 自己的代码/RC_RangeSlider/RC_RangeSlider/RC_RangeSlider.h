//
//  RC_RangeSlider.h
//  RC_RangeSlider
//
//  Created by RC on 2017/5/2.
//  Copyright © 2017年 RC. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface RC_RangeSlider : UIControl

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) int minValue;
@property (nonatomic, assign) int maxValue;

@property (nonatomic, assign) int lowerValue;
@property (nonatomic, assign) int upperValue;

@end
