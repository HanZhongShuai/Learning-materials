//
//  HSPopoverView.h
//  iOSLivU
//
//  Created by HS on 2020/9/8.
//  Copyright © 2020 RC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSPopoverView : UIView <UIPopoverBackgroundViewMethods>

@property (nonatomic) CGSize contentSize;

@property (nullable, nonatomic, strong) UIView *sourceView;

@property (nonatomic, assign) CGRect sourceRect;

@property (nonatomic, assign) CGFloat arrowOffset;

@property (nonatomic, assign) UIPopoverArrowDirection arrowDirection;

- (instancetype)initWithSourceView:(UIView*)sourceView contentSize:(CGSize)size;

- (void)showPopoverViewInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
