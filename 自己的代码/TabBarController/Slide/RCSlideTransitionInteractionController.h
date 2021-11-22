/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The interaction controller for the Slide demo.
 */

@import UIKit;

@interface RCSlideTransitionInteractionController : UIPercentDrivenInteractiveTransition

//! The value for this property determines which direction the view controllers
//! slide during the transition.  This must be one of UIRectEdgeLeft or
//! UIRectEdgeRight.
@property (nonatomic, readwrite) UIRectEdge targetEdge;

- (instancetype)initWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end
