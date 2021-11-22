/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A transition animator that transitions between two view controllers in
  a tab bar controller by sliding both view controllers in a given
  direction.
 */

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@protocol RCSlideTransitionAnimatorDelegate <NSObject>
@optional
- (void)slideTransitionAnimationEnded:(BOOL) transitionCompleted;

@end

@interface RCSlideTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property(nullable, nonatomic,weak) id<RCSlideTransitionAnimatorDelegate> delegate;

- (instancetype)initWithTargetEdge:(UIRectEdge)targetEdge;

//! The value for this property determines which direction the view controllers
//! slide during the transition.  This must be one of UIRectEdgeLeft or
//! UIRectEdgeRight.
@property (nonatomic, readwrite) UIRectEdge targetEdge;

@property (nonatomic, strong) UIImage *screenshotImage;

@end

NS_ASSUME_NONNULL_END
