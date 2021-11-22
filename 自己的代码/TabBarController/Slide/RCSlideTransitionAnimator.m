/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A transition animator that transitions between two view controllers in
  a tab bar controller by sliding both view controllers in a given
  direction.
 */

#import "RCSlideTransitionAnimator.h"

typedef NS_ENUM(NSUInteger, SlideTransitionAnimatorType) {
    kCentreAnimationNone,
    kCentreAnimationShow,
    kCentreAnimationHidden,
};

@interface RCSlideTransitionAnimator ()

@property (strong, nonatomic) UIView *tintView;
@property (strong, nonatomic) UIView *centerView;

@property (assign, nonatomic) BOOL slideEnded;

@end

@implementation RCSlideTransitionAnimator

//| ----------------------------------------------------------------------------
- (instancetype)initWithTargetEdge:(UIRectEdge)targetEdge
{
    self = [self init];
    if (self) {
        _targetEdge = targetEdge;
    }
    return self;
}

- (UIView *)tintView
{
    if (!_tintView) {
        _tintView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _tintView;
}

- (UIColor *)getTintColorWithIndex:(NSInteger)index
{
    if (index == 0) {
        return [UIColor colorWithHexString:@"#FFC300"];
    }
    else if (index == 2) {
        return [UIColor colorWithHexString:@"#7370F6"];
    }
    return [UIColor clearColor];
}


//| ----------------------------------------------------------------------------
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}

//| ----------------------------------------------------------------------------
//  Custom transitions within a UITabBarController follow the same
//  conventions as those used for modal presentations.  Your animator will
//  be given the incoming and outgoing view controllers along with a container
//  view where both view controller's views will reside.  Your animator is
//  tasked with animating the incoming view controller's view into the
//  container view.  The frame of the incoming view controller's view is
//  is expected to match the value returned from calling
//  [transitionContext finalFrameForViewController:toViewController] when
//  the transition is complete.
//
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UITabBarController *tabVc = fromViewController.tabBarController;
    if (!tabVc) {
        tabVc = toViewController.tabBarController;
    }
    if (!tabVc) {
        UIViewController *rootVc = [UIApplication sharedApplication].delegate.window.rootViewController;
        if (rootVc && [rootVc isKindOfClass:[UITabBarController class]]) {
            tabVc = toViewController.tabBarController;
        }
    }
    
    SlideTransitionAnimatorType type = kCentreAnimationNone;
    NSInteger fromIndex = -1;
    NSInteger toIndex = -1;
    if (tabVc && [tabVc.viewControllers containsObject:fromViewController]) {
        fromIndex = [tabVc.viewControllers indexOfObject:fromViewController];
    }
    if (tabVc && [tabVc.viewControllers containsObject:toViewController]) {
        toIndex = [tabVc.viewControllers indexOfObject:toViewController];
    }
    
    if (fromIndex == 1) {
        type = kCentreAnimationHidden;
    }
    else if (toIndex == 1) {
        type = kCentreAnimationShow;
    }
    
    UIView *containerView = transitionContext.containerView;
    UIView *fromView;
    UIView *toView;
    
    // In iOS 8, the viewForKey: method was introduced to get views that the
    // animator manipulates.  This method should be preferred over accessing
    // the view of the fromViewController/toViewController directly.
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect toFrame = [transitionContext finalFrameForViewController:toViewController];
    
    // Based on the configured targetEdge, derive a normalized vector that will
    // be used to offset the frame of the view controllers.
    CGVector offset = CGVectorMake(0.f, 0.f);
    if (self.targetEdge == UIRectEdgeLeft) {
        offset = CGVectorMake(-1.f, 0.f);
    }
    else if (self.targetEdge == UIRectEdgeRight) {
        offset = CGVectorMake(1.f, 0.f);
    }
    else {
        NSAssert(NO, @"targetEdge must be one of UIRectEdgeLeft, or UIRectEdgeRight.");
    }
    
    // The toView starts off-screen and slides in as the fromView slides out.
    fromView.frame = fromFrame;
    if (type == kCentreAnimationShow) {
        toView.frame = toFrame;
    }
    else if (type == kCentreAnimationHidden) {
        toView.frame = CGRectOffset(toFrame, toFrame.size.width * offset.dx * -1,
        toFrame.size.height * offset.dy * -1);
    }
    else {
        toView.frame = CGRectOffset(toFrame, toFrame.size.width * offset.dx * -2,
        toFrame.size.height * offset.dy * -2);
    }
    self.tintView.frame = toFrame;
    self.tintView.backgroundColor = [self getTintColorWithIndex:fromIndex];
    // We are responsible for adding the incoming view to the containerView.
    if (type == kCentreAnimationShow) {
        [containerView addSubview:toView];
        [containerView addSubview:self.tintView];
        [containerView addSubview:fromView];
    }
    else if (type == kCentreAnimationHidden) {
        [containerView addSubview:fromView];
        [containerView addSubview:self.tintView];
        [containerView addSubview:toView];
    }
    else {
        self.centerView = [tabVc.viewControllers[1] view];
        self.centerView.frame = toFrame;
        [containerView addSubview:self.centerView];
        [containerView addSubview:self.tintView];
        [containerView addSubview:fromView];
        [containerView addSubview:toView];
    }
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateKeyframesWithDuration:transitionDuration delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews|UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
            if (type == kCentreAnimationShow) {
                fromView.frame = CGRectOffset(fromFrame, fromFrame.size.width * offset.dx,
                fromFrame.size.height * offset.dy);
            }
            else if (type == kCentreAnimationHidden) {
                fromView.frame = fromFrame;
            }
            else {
                fromView.frame = CGRectOffset(fromFrame, fromFrame.size.width * offset.dx * 2,
                fromFrame.size.height * offset.dy * 2);
            }
            toView.frame = toFrame;
        }];
        if (type == kCentreAnimationNone) {
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                self.tintView.backgroundColor = [UIColor clearColor];
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                self.tintView.backgroundColor = [self getTintColorWithIndex:toIndex];
            }];
        }
        else {
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                self.tintView.backgroundColor = [self getTintColorWithIndex:toIndex];
            }];
        }
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        // When we complete, tell the transition context
        // passing along the BOOL that indicates whether the transition
        // finished or not.
        [transitionContext completeTransition:!wasCancelled];
    }];
}

- (void)animationEnded:(BOOL) transitionCompleted
{
    [self.centerView removeFromSuperview];
    self.centerView = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(slideTransitionAnimationEnded:)]) {
        if (!self.slideEnded) {
            self.slideEnded = YES;
            [self.delegate slideTransitionAnimationEnded:transitionCompleted];
        }
    }
    
    [self.tintView removeFromSuperview];
}

@end
