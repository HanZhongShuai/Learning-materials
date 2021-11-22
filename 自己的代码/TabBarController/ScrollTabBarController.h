//
//  ScrollTabBarController.h
//  iOSLivU
//
//  Created by RC on 2017/8/9.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RC_ScrollView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ScrollTabBarControllerDelete <NSObject>

@optional
- (void)tabBarControllerScrollAnimationStartFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)tabBarControllerScrollAnimationProgress:(CGFloat)progress;
- (void)tabBarControllerScrollAnimationCancel;
- (void)tabBarControllerScrollAnimationFinished;

@end

@interface ScrollTabBarController : UITabBarController <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) RC_ScrollView *scrollView;
@property(nullable,nonatomic,weak) id<ScrollTabBarControllerDelete>        scrollDelegate;
@property (nonatomic, assign) BOOL isLayoutDirectionRightToLeft;
- (void)reload;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;//默认有动画

- (UIViewController *)viewControllerWithIndex:(NSInteger)index;

@end
NS_ASSUME_NONNULL_END
