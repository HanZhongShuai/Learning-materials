//
//  StretchLabel.h
//  labeltest
//
//  Created by RC on 2017/5/5.
//  Copyright © 2017年 RC. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@protocol StretchLabelDelegate <NSObject>

- (void)stretchLabelHeightWillChange:(CGFloat)height;

@end

@interface StretchLabel : UILabel

@property (nullable, nonatomic, copy) IBInspectable NSString *stretchText;

@property (nullable, nonatomic, weak) id<StretchLabelDelegate> delegate;

@end
