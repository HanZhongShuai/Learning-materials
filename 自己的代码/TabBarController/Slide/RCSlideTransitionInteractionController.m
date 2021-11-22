/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The interaction controller for the Slide demo.
 */

#import "RCSlideTransitionInteractionController.h"

#define kFinishPercent 0.5f
#define kFinishVelocity 300.0f

@interface RCSlideTransitionInteractionController ()
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *gestureRecognizer;
@property (nonatomic, readwrite) CGPoint initialTranslationInContainerView;

//是否调用了startInteractiveTransition
//手势滑动，机器卡顿时，可能出现还有没有start，手势就结束的情况
//复现步骤：
//第一种、在UITabBarControllerDelegate中的返回过渡动画出添加断点
//第二种、在开始过渡动画之前线程被阻塞（猜测）
@property (assign, nonatomic) BOOL start;
@property (assign, nonatomic) BOOL alreadyCancel;
@property (assign, nonatomic) BOOL alreadyFinish;

@end


@implementation RCSlideTransitionInteractionController

//| ----------------------------------------------------------------------------
- (instancetype)initWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    self = [super init];
    if (self)
    {
        _gestureRecognizer = gestureRecognizer;
        _start = NO;
        _alreadyCancel = NO;
        _alreadyFinish = NO;
        _initialTranslationInContainerView = [gestureRecognizer translationInView:gestureRecognizer.view];
        // Add self as an observer of the gesture recognizer so that this
        // object receives updates as the user moves their finger.
        [_gestureRecognizer addTarget:self action:@selector(gestureRecognizeDidUpdate:)];
        self.completionCurve = UIViewAnimationCurveEaseInOut;
    }
    return self;
}


//| ----------------------------------------------------------------------------
- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithGestureRecognizer:" userInfo:nil];
}


//| ----------------------------------------------------------------------------
- (void)dealloc
{
    [self.gestureRecognizer removeTarget:self action:@selector(gestureRecognizeDidUpdate:)];
}


//| ----------------------------------------------------------------------------
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // Save the transitionContext, initial location, and the translation within
    // the containing view.
    self.transitionContext = transitionContext;
    self.initialTranslationInContainerView = [self.gestureRecognizer translationInView:transitionContext.containerView];
    
    [super startInteractiveTransition:transitionContext];
    
    self.start = YES;
    if (self.alreadyCancel) {
        self.alreadyCancel = NO;
        [self performSelector:@selector(cancelInteractiveTransition) withObject:nil afterDelay:0.1];
    }
    else if (self.alreadyFinish) {
        self.alreadyFinish = NO;
        [self performSelector:@selector(finishInteractiveTransition) withObject:nil afterDelay:0.1];
    }
}

//| ----------------------------------------------------------------------------
//! Returns the offset of the pan gesture recognizer from its initial location
//! as a percentage of the transition container view's width.  This is
//! the percent completed for the interactive transition.
//
- (CGFloat)percentForGesture:(UIPanGestureRecognizer *)gesture
{
    UIView *transitionContainerView = self.transitionContext.containerView;
    if (!transitionContainerView) {
        transitionContainerView = gesture.view;
    }
    
    CGPoint translationInContainerView = [gesture translationInView:transitionContainerView];
    
    // If the direction of the current touch along the horizontal axis does not
    // match the initial direction, then the current touch position along
    // the horizontal axis has crossed over the initial position.  See the
    // comment in the -beginInteractiveTransitionIfPossible: method of
    // RCSlideTransitionDelegate.
    if ((translationInContainerView.x > 0.f && self.initialTranslationInContainerView.x < 0.f) ||
        (translationInContainerView.x < 0.f && self.initialTranslationInContainerView.x > 0.f))
        return -1.f;
    
    // Figure out what percentage we've traveled.
    return fabs(translationInContainerView.x) / CGRectGetWidth(transitionContainerView.bounds);
}

- (CGFloat)velocityForGesture:(UIPanGestureRecognizer *)gesture
{
    UIView *transitionContainerView = self.transitionContext.containerView;
    if (!transitionContainerView) {
        transitionContainerView = gesture.view;
    }
    
    CGPoint velocityInContainerView = [gesture velocityInView:transitionContainerView];
    return velocityInContainerView.x;
}

//| ----------------------------------------------------------------------------
//! Action method for the gestureRecognizer.
//
- (IBAction)gestureRecognizeDidUpdate:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            // The Began state is handled by RCSlideTransitionDelegate.  In
            // response to the gesture recognizer transitioning to this state,
            // it will trigger the transition.
            break;
        case UIGestureRecognizerStateChanged:
            // -percentForGesture returns -1.f if the current position of the
            // touch along the horizontal axis has crossed over the initial
            // position.  See the comment in the
            // -beginInteractiveTransitionIfPossible: method of
            // RCSlideTransitionDelegate for details.
            if ([self percentForGesture:gestureRecognizer] < 0.f) {
                [self cancelInteractiveTransition];
                // Need to remove our action from the gesture recognizer to
                // ensure it will not be called again before deallocation.
                [self.gestureRecognizer removeTarget:self action:@selector(gestureRecognizeDidUpdate:)];
            } else {
                // We have been dragging! Update the transition context
                // accordingly.
                [self updateInteractiveTransition:[self percentForGesture:gestureRecognizer]];
            }
            break;
        case UIGestureRecognizerStateEnded:
        {
            // Dragging has finished.
            // Complete or cancel, depending on how far we've dragged.
            BOOL finish = ([self percentForGesture:gestureRecognizer] >= kFinishPercent);
            if (!finish) {
                CGFloat velocity = [self velocityForGesture:gestureRecognizer];
                if (self.targetEdge == UIRectEdgeLeft && velocity <= -kFinishVelocity) {
                    finish = YES;
                } else if (self.targetEdge == UIRectEdgeRight && velocity >= kFinishVelocity) {
                    finish = YES;
                } else if (self.targetEdge != UIRectEdgeLeft && self.targetEdge != UIRectEdgeRight && (velocity <= -kFinishVelocity || velocity >= kFinishVelocity)) {
                    finish = YES;
                }
            }
            if (finish) {
                [self finishInteractiveTransition];
            }
            else {
                [self cancelInteractiveTransition];
            }
        }
            break;
        default:
            // Something happened. cancel the transition.
            [self cancelInteractiveTransition];
            break;
    }
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    if (!self.start) {
        return;
    }
    [super updateInteractiveTransition:percentComplete];
}

- (void)cancelInteractiveTransition
{
    // Need to remove our action from the gesture recognizer to
    // ensure it will not be called again before deallocation.
    [self.gestureRecognizer removeTarget:self action:@selector(gestureRecognizeDidUpdate:)];
    
    if (!self.start) {
        self.alreadyCancel = YES;
        return;
    }
    
    self.completionCurve = UIViewAnimationCurveEaseIn;
    [super cancelInteractiveTransition];
}

- (void)finishInteractiveTransition
{
    // Need to remove our action from the gesture recognizer to
    // ensure it will not be called again before deallocation.
    [self.gestureRecognizer removeTarget:self action:@selector(gestureRecognizeDidUpdate:)];
    
    if (!self.start) {
        self.alreadyFinish = YES;
        return;
    }
    
    self.completionCurve = UIViewAnimationCurveEaseInOut;
    [super finishInteractiveTransition];
}

@end
