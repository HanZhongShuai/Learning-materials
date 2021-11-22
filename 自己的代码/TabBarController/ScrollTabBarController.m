//
//  ScrollTabBarController.m
//  iOSLivU
//
//  Created by RC on 2017/8/9.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import "ScrollTabBarController.h"

typedef enum : NSUInteger {
    ScrollTabBarController_None,
    ScrollTabBarController_Left,
    ScrollTabBarController_Right,
} ScrollTabBarControllerDirection;

@interface ScrollTabBarController ()
{
    NSSet *visibleSet;
    NSSet *transitioningSet;
    NSSet *clickSet;
    BOOL willScrollVisible;
    BOOL startedScroll;
    BOOL beginDecelerating;
}

@property (nonatomic, assign) ScrollTabBarControllerDirection direction;

@property (nonatomic, copy) NSArray<__kindof UIViewController *> *backingViewControllers;
@property (nonatomic, assign) NSUInteger backingSelectedIndex;
@property (nonatomic, strong) RC_ScrollView *scrollView;

@property (weak, nonatomic) UIViewController *appearViewController;
@property (weak, nonatomic) UIViewController *disappearViewController;
@end

@implementation ScrollTabBarController

- (void)dealloc
{
    [self.tabBar removeObserver:self forKeyPath:@"hidden"];
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    UIViewController *selectVc = self.selectedViewController;
    if (selectVc && [selectVc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)selectVc topViewController];
    }
    else {
        return self.selectedViewController;
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    UIViewController *selectVc = self.selectedViewController;
    if (selectVc && [selectVc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)selectVc topViewController];
    }
    else {
        return self.selectedViewController;
    }
}

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    clickSet = nil;
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.scrollView) {
        self.scrollView = [[RC_ScrollView alloc] initWithFrame:self.view.bounds];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        self.scrollView.scrollEnabled = NO;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.panGestureRecognizer.maximumNumberOfTouches = 1;
        [self.view insertSubview:self.scrollView belowSubview:self.tabBar];
    }
    [self addCurrentChildViewControllers];
    
    [self reload];
    
    [self.tabBar addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hidden"]) {
        NSNumber *newNum = [change objectForKey:NSKeyValueChangeNewKey];
        NSNumber *oldNum = [change objectForKey:NSKeyValueChangeOldKey];
        if (newNum && oldNum && newNum.boolValue != oldNum.boolValue) {
            if (self.scrollView) {
                self.scrollView.scrollEnabled = !newNum.boolValue;
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reload];
    [self addCurrentView];
    UIViewController *vc = self.selectedViewController;
    self.appearViewController = nil;
    if (vc) {
        self.appearViewController = vc;
        [vc beginAppearanceTransition:YES animated:animated];
    }
    if (self.scrollView) {
        self.scrollView.delegate = self;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIViewController *vc = self.selectedViewController;
    if (vc && vc == self.appearViewController) {
        [vc endAppearanceTransition];
    }
    self.appearViewController = nil;
    
    [self performSelector:@selector(viewDidAppearDelayedForScroll) withObject:nil afterDelay:1.0];
}

- (void)viewDidAppearDelayedForScroll
{
    if (self.scrollView) {
        self.scrollView.delegate = self;
        self.scrollView.scrollEnabled = !self.tabBar.hidden;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIViewController *vc = self.selectedViewController;
    self.disappearViewController = nil;
    if (vc) {
        self.disappearViewController = vc;
        [vc beginAppearanceTransition:NO animated:animated];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.scrollView) {
        self.scrollView.delegate = nil;
        self.scrollView.scrollEnabled = NO;
    }
    UIViewController *vc = self.selectedViewController;
    if (vc && vc == self.disappearViewController) {
        [vc endAppearanceTransition];
    }
    self.disappearViewController = nil;
    
    [super viewDidDisappear:animated];
}

#pragma mark - function

- (void)reload
{
    if ([self.backingViewControllers count] == 0) return;
    
    visibleSet = [NSSet setWithObject:@(self.backingSelectedIndex)];
    transitioningSet = nil;
    clickSet = nil;
    startedScroll = NO;
    beginDecelerating = NO;
    self.direction = ScrollTabBarController_None;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self.backingViewControllers count], self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame) * self.backingSelectedIndex, 0);
}

- (void)addCurrentChildViewControllers
{
    if (!_backingViewControllers || _backingViewControllers.count == 0) {
        return;
    }
    
    [_backingViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }];
}

- (void)addCurrentView
{
    UIViewController *viewController = self.selectedViewController;
    if (viewController) {
        [self addSubViewsWithIndex:self.backingSelectedIndex isScroll:NO];
    }
}

- (void)updateMiddleViewControllerLocation:(BOOL)scrollFinish
{
    UIViewController *vc = [self viewControllerWithIndex:1];
    if (!scrollFinish) {
        if (vc.view.superview == self.scrollView) {
            [[vc view] setFrame:self.view.bounds];
            [self.view addSubview:vc.view];
            [self.view insertSubview:vc.view belowSubview:self.scrollView];
        }
    }
    else {
        if (vc && [vc isKindOfClass:[UINavigationController class]]) {
            if (vc.childViewControllers.firstObject && [vc.childViewControllers.firstObject isViewLoaded]) {
                [self addSubViewsWithIndex:1 isScroll:NO];
            }
        }
        else if (vc && [vc isViewLoaded]) {
            [self addSubViewsWithIndex:1 isScroll:NO];
        }
    }
}

- (void)addSubViewsWithIndex:(NSInteger)index isScroll:(BOOL)isScroll
{
    if (index < 0 || index >= self.backingViewControllers.count) {
        return;
    }
    UIViewController *vc = self.backingViewControllers[index];
    if (index != 1 || !isScroll) {
        [[vc view] setFrame:CGRectMake(index*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [self.scrollView addSubview:vc.view];
    }
    else {
        [[vc view] setFrame:self.view.bounds];
        [self.view addSubview:vc.view];
        [self.view insertSubview:vc.view belowSubview:self.scrollView];
    }
}

- (NSSet*)visibleViewControllersForContentOffset:(float)offset
{
    float floorValue = floorf(offset / self.scrollView.frame.size.width);
    float ceilValue  = ceilf(offset / self.scrollView.frame.size.width);
    if (floorValue < 0) floorValue = 0;
    if (ceilValue > [self.backingViewControllers count]-1) ceilValue = [self.backingViewControllers count]-1;
    if (clickSet && floorValue != ceilValue) {
        return clickSet;
    }
    NSSet *set = [NSSet setWithObjects:@(floorValue),@(ceilValue), nil];
    return set;
}

#pragma mark -
#pragma mark Scrollview delegate method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    [self adjustSubviewsAlphaForTitleScrollView];
    NSSet *allSet = [self visibleViewControllersForContentOffset:scrollView.contentOffset.x];
    
    if (allSet.count != 2) {
        return;
    }
    
    if (willScrollVisible) {
        willScrollVisible = NO;
    }
    
    if (!startedScroll) {
        [self updateMiddleViewControllerLocation:NO];
    }
    
    if (clickSet) {
        if (!startedScroll) {
            NSMutableSet *addedSet = [allSet mutableCopy];
            [addedSet minusSet:visibleSet];
            
            // addedSet viewWillAppear
            [addedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [self addSubViewsWithIndex:[vcNumber intValue] isScroll:YES];
                [vc beginAppearanceTransition:YES animated:YES];
            }];
            
            [visibleSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc beginAppearanceTransition:NO animated:YES];
            }];
            
            transitioningSet = addedSet;
            startedScroll = YES;
            if (self.direction == ScrollTabBarController_None) {
                NSNumber *visible = [visibleSet anyObject];
                NSNumber *transitioning = [transitioningSet anyObject];
                if (visible && transitioning) {
                    if (visible.integerValue > transitioning.integerValue)
                    {
                        self.direction = ScrollTabBarController_Left;
                    }
                    else if (visible.integerValue < transitioning.integerValue)
                    {
                        self.direction = ScrollTabBarController_Right;
                    }
                    else {
                        self.direction = ScrollTabBarController_None;
                    }
                }
            }
            [self scrollAnimationStartAnimation];
        }
        else if (self.direction != ScrollTabBarController_None)
        {
            NSNumber *visible = [visibleSet anyObject];
            NSNumber *transitioning = [transitioningSet anyObject];
            CGFloat beishu = fabsf(transitioning.floatValue-visible.floatValue);
            CGFloat mod = fmod(scrollView.contentOffset.x, CGRectGetWidth(scrollView.frame)*beishu);
            CGFloat deltaAlpha = mod * (1.0 / CGRectGetWidth(scrollView.frame)*beishu);
            if (!(deltaAlpha >= 1.0 || deltaAlpha <= 0.0)) {
                if (self.direction == ScrollTabBarController_Left) {
                    [self scrollAnimationProgress:(1.0-deltaAlpha)];
                }
                else if (self.direction == ScrollTabBarController_Right) {
                    [self scrollAnimationProgress:deltaAlpha];
                }
            }
        }
        return;
    }
    
    if (beginDecelerating && startedScroll) {
        NSInteger toIndex = [[transitioningSet anyObject] integerValue];
        if (self.direction == ScrollTabBarController_Left) {
            CGFloat currentContentOffset = scrollView.contentOffset.x>(CGRectGetWidth(scrollView.frame)*toIndex)?scrollView.contentOffset.x:(CGRectGetWidth(scrollView.frame)*toIndex);
            CGFloat mod = fmod(currentContentOffset, CGRectGetWidth(scrollView.frame));
            CGFloat deltaAlpha = mod * (1.0 / CGRectGetWidth(scrollView.frame));
            if (!(deltaAlpha >= 1.0 || deltaAlpha <= 0.0)) {
                [self scrollAnimationProgress:(1.0-deltaAlpha)];
            }
        }
        else if (self.direction == ScrollTabBarController_Right) {
            CGFloat currentContentOffset = scrollView.contentOffset.x<(CGRectGetWidth(scrollView.frame)*toIndex)?scrollView.contentOffset.x:(CGRectGetWidth(scrollView.frame)*toIndex);
            CGFloat mod = fmod(currentContentOffset, CGRectGetWidth(scrollView.frame));
            CGFloat deltaAlpha = mod * (1.0 / CGRectGetWidth(scrollView.frame));
            if (!(deltaAlpha >= 1.0 || deltaAlpha <= 0.0)) {
                [self scrollAnimationProgress:deltaAlpha];
            }
        }
//        CGFloat mod = fmod(scrollView.contentOffset.x, CGRectGetWidth(scrollView.frame));
//        CGFloat deltaAlpha = mod * (1.0 / CGRectGetWidth(scrollView.frame));
//        if (!(deltaAlpha >= 1.0 || deltaAlpha <= 0.0)) {
//            if (self.direction == ScrollTabBarController_Left) {
//                [self scrollAnimationProgress:(1.0-deltaAlpha)];
//            }
//            else if (self.direction == ScrollTabBarController_Right) {
//                [self scrollAnimationProgress:deltaAlpha];
//            }
//        }
    }
    else if (allSet && transitioningSet && startedScroll && ![allSet intersectsSet:transitioningSet]) {
        startedScroll = NO;
        // addedSet viewDidAppear
        [visibleSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [self addSubViewsWithIndex:[vcNumber intValue] isScroll:YES];
            [vc beginAppearanceTransition:YES animated:YES];
        }];
        
        // removedSet viewDidDisappear
        [transitioningSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc beginAppearanceTransition:NO animated:YES];
        }];
    }
    else if (startedScroll == NO && transitioningSet) {
        
        // addedSet viewDidAppear
        [visibleSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc endAppearanceTransition];//[vc viewDidAppear:YES];
        }];
        
        // removedSet viewDidDisappear
        [transitioningSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc.view removeFromSuperview];
            [vc endAppearanceTransition];//[vc viewDidDisappear:YES];
        }];
        
        transitioningSet = nil;
        [self scrollAnimationCancel];
    }
    else if (!startedScroll) {
        NSMutableSet *addedSet = [allSet mutableCopy];
        [addedSet minusSet:visibleSet];
        
        // addedSet viewWillAppear
        [addedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [self addSubViewsWithIndex:[vcNumber intValue] isScroll:YES];
            [vc beginAppearanceTransition:YES animated:YES];
        }];
        
        if (visibleSet) {
            [visibleSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc beginAppearanceTransition:NO animated:YES];
            }];
        }
        
        transitioningSet = addedSet;
        startedScroll = YES;
        if (self.direction == ScrollTabBarController_None) {
            NSNumber *visible = [visibleSet anyObject];
            NSNumber *transitioning = [transitioningSet anyObject];
            if (visible && transitioning) {
                if (visible.integerValue > transitioning.integerValue)
                {
                    self.direction = ScrollTabBarController_Left;
                }
                else if (visible.integerValue < transitioning.integerValue)
                {
                    self.direction = ScrollTabBarController_Right;
                }
                else {
                    self.direction = ScrollTabBarController_None;
                }
            }
        }
        [self scrollAnimationStartAnimation];
    }
    else if (self.direction != ScrollTabBarController_None)
    {
        CGFloat mod = fmod(scrollView.contentOffset.x, CGRectGetWidth(scrollView.frame));
        CGFloat deltaAlpha = mod * (1.0 / CGRectGetWidth(scrollView.frame));
        if (!(deltaAlpha >= 1.0 || deltaAlpha <= 0.0)) {
            if (self.direction == ScrollTabBarController_Left) {
                [self scrollAnimationProgress:(1.0-deltaAlpha)];
            }
            else if (self.direction == ScrollTabBarController_Right) {
                [self scrollAnimationProgress:deltaAlpha];
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (transitioningSet) {
        NSSet *newSet = [self visibleViewControllersForContentOffset:targetContentOffset->x];
        NSMutableSet *removedSet = [transitioningSet mutableCopy];
        [removedSet unionSet:visibleSet];
        [removedSet minusSet:newSet];
        
        if (![removedSet isSubsetOfSet:visibleSet]) {
            // removedSet viewWillDisappear
            [removedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc beginAppearanceTransition:NO animated:YES];
            }];
            [visibleSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [self addSubViewsWithIndex:[vcNumber intValue] isScroll:YES];
                [vc beginAppearanceTransition:YES animated:YES];
            }];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        beginDecelerating = NO;
        if (transitioningSet) {
            startedScroll = NO;
            NSSet *newSet = [self visibleViewControllersForContentOffset:scrollView.contentOffset.x];
            NSMutableSet *removedSet = [transitioningSet mutableCopy];
            [removedSet unionSet:visibleSet];
            [removedSet minusSet:newSet];
            NSMutableSet *addedSet = [newSet mutableCopy];
            //        [addedSet minusSet:visibleSet];
            
            // addedSet viewDidAppear
            [addedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc endAppearanceTransition];//[vc viewDidAppear:YES];
            }];
            
            // removedSet viewDidDisappear
            [removedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc.view removeFromSuperview];
                [vc endAppearanceTransition];//[vc viewDidDisappear:YES];
            }];
            
            BOOL finish = YES;
            if ([visibleSet isEqualToSet:newSet]) {
                finish = NO;
            }
            visibleSet = newSet;
            transitioningSet = nil;
            
            _backingSelectedIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
            if (finish) {
                [self scrollAnimationFinished];
            }
            else {
                [self scrollAnimationCancel];
            }
        }
        [self updateMiddleViewControllerLocation:YES];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    beginDecelerating = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    beginDecelerating = NO;
    if (transitioningSet) {
        startedScroll = NO;
        NSSet *newSet = [self visibleViewControllersForContentOffset:scrollView.contentOffset.x];
        NSMutableSet *removedSet = [transitioningSet mutableCopy];
        [removedSet unionSet:visibleSet];
        [removedSet minusSet:newSet];
        NSMutableSet *addedSet = [newSet mutableCopy];
        //        [addedSet minusSet:visibleSet];
        
        // addedSet viewDidAppear
        [addedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc endAppearanceTransition];//[vc viewDidAppear:YES];
        }];
        
        // removedSet viewDidDisappear
        [removedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc.view removeFromSuperview];
            [vc endAppearanceTransition];//[vc viewDidDisappear:YES];
        }];
        
        BOOL finish = YES;
        if ([visibleSet isEqualToSet:newSet]) {
            finish = NO;
        }
        visibleSet = newSet;
        transitioningSet = nil;
        
        _backingSelectedIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
        if (finish) {
            [self scrollAnimationFinished];
        }
        else {
            [self scrollAnimationCancel];
        }
    }
    [self updateMiddleViewControllerLocation:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    beginDecelerating = NO;
    if (transitioningSet) {
        startedScroll = NO;
        NSSet *newSet = [self visibleViewControllersForContentOffset:scrollView.contentOffset.x];
        NSMutableSet *removedSet = [transitioningSet mutableCopy];
        [removedSet unionSet:visibleSet];
        [removedSet minusSet:newSet];
        NSMutableSet *addedSet = [newSet mutableCopy];
        //        [addedSet minusSet:visibleSet];
        
        // addedSet viewDidAppear
        [addedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc endAppearanceTransition];//[vc viewDidAppear:YES];
        }];
        
        // removedSet viewDidDisappear
        [removedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc.view removeFromSuperview];
            [vc endAppearanceTransition];//[vc viewDidDisappear:YES];
        }];
        
        BOOL finish = YES;
        if ([visibleSet isEqualToSet:newSet]) {
            finish = NO;
        }
        visibleSet = newSet;
        transitioningSet = nil;
        
        _backingSelectedIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
        if (finish) {
            [self scrollAnimationFinished];
        }
        else {
            [self scrollAnimationCancel];
        }
    }
    [self updateMiddleViewControllerLocation:YES];
}

- (void)scrollAnimationStartAnimation
{
    if ([self.scrollDelegate respondsToSelector:@selector(tabBarControllerScrollAnimationStartFromIndex:toIndex:)]) {
        NSNumber *visible = [visibleSet anyObject];
        NSNumber *transitioning = [transitioningSet anyObject];
        if (self.isLayoutDirectionRightToLeft) {
            [self.scrollDelegate tabBarControllerScrollAnimationStartFromIndex:self.backingViewControllers.count-1-visible.integerValue toIndex:self.backingViewControllers.count-1-transitioning.integerValue];
        }
        else {
            [self.scrollDelegate tabBarControllerScrollAnimationStartFromIndex:visible.integerValue toIndex:transitioning.integerValue];
        }
    }
}

- (void)scrollAnimationProgress:(CGFloat)progress
{
    if ([self.scrollDelegate respondsToSelector:@selector(tabBarControllerScrollAnimationProgress:)]) {
        [self.scrollDelegate tabBarControllerScrollAnimationProgress:progress];
    }
}

- (void)scrollAnimationCancel
{
    if (clickSet) {
        clickSet = nil;
    }
    self.direction = ScrollTabBarController_None;
    if ([self.scrollDelegate respondsToSelector:@selector(tabBarControllerScrollAnimationProgress:)]) {
        [self.scrollDelegate tabBarControllerScrollAnimationProgress:0.0];
    }
    if ([self.scrollDelegate respondsToSelector:@selector(tabBarControllerScrollAnimationCancel)]) {
        [self.scrollDelegate tabBarControllerScrollAnimationCancel];
    }
}

- (void)scrollAnimationFinished
{
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (clickSet) {
        clickSet = nil;
    }
    self.direction = ScrollTabBarController_None;
    if ([self.scrollDelegate respondsToSelector:@selector(tabBarControllerScrollAnimationProgress:)]) {
        [self.scrollDelegate tabBarControllerScrollAnimationProgress:1.0];
    }
    if ([self.scrollDelegate respondsToSelector:@selector(tabBarControllerScrollAnimationFinished)]) {
        [self.scrollDelegate tabBarControllerScrollAnimationFinished];
    }
}

#pragma mark -
#pragma mark - Getters and Setters

- (NSArray *)viewControllers {
    return nil;
}

- (UIViewController *)viewControllerWithIndex:(NSInteger)index
{
    if (self.backingViewControllers && self.backingViewControllers.count > index) {
        return self.backingViewControllers[index];
    }
    return nil;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    if (self.isLayoutDirectionRightToLeft) {
        self.backingViewControllers = [[viewControllers reverseObjectEnumerator] allObjects];
    }
    else {
        self.backingViewControllers = viewControllers;
    }
}

- (UIViewController *)selectedViewController {
    return [self viewControllerWithIndex:self.backingSelectedIndex];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    NSInteger index = [self.backingViewControllers indexOfObject:selectedViewController];
    if (index < 0 || index >= self.backingViewControllers.count) {
        return;
    }
    if (self.isLayoutDirectionRightToLeft) {
        index =  self.backingViewControllers.count-1-index;
    }
    self.selectedIndex = index;
}

- (NSUInteger)selectedIndex {
    if (self.isLayoutDirectionRightToLeft) {
        return self.backingViewControllers.count-1-self.backingSelectedIndex;
    }
    else {
        return self.backingSelectedIndex;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:YES];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if (startedScroll || willScrollVisible) {
        return;
    }
    if (selectedIndex < 0 || selectedIndex >= self.backingViewControllers.count) {
        return;
    }
    if (self.isLayoutDirectionRightToLeft) {
        selectedIndex =  self.backingViewControllers.count-1-selectedIndex;
    }
    if (_backingSelectedIndex == selectedIndex || startedScroll) {
        return;
    }
    if (self.scrollView.delegate && animated && self.scrollView.scrollEnabled) {
        willScrollVisible = YES;
        if (selectedIndex < _backingSelectedIndex) {
            clickSet = [NSSet setWithObjects:@(selectedIndex), @(_backingSelectedIndex), nil];
        }
        else {
            clickSet = [NSSet setWithObjects:@(_backingSelectedIndex), @(selectedIndex), nil];
        }
        CGRect rectToVisible = CGRectMake(CGRectGetWidth(self.scrollView.frame) * selectedIndex, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        [self.scrollView scrollRectToVisible:rectToVisible animated:YES];
    }
    else if (self.scrollView.delegate) {
        UIViewController *lastVc = [self selectedViewController];
        [lastVc beginAppearanceTransition:NO animated:NO];
        UIViewController *vc = [_backingViewControllers objectAtIndex:selectedIndex];
        [self addSubViewsWithIndex:selectedIndex isScroll:NO];
        [vc beginAppearanceTransition:YES animated:NO];
        _backingSelectedIndex = selectedIndex;
        CGRect rectToVisible = CGRectMake(CGRectGetWidth(self.scrollView.frame) * selectedIndex, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        [self.scrollView scrollRectToVisible:rectToVisible animated:NO];
        visibleSet = [NSSet setWithObject:@(selectedIndex)];
        [lastVc.view removeFromSuperview];
        [lastVc endAppearanceTransition];
        [vc endAppearanceTransition];//[vc viewDidAppear:NO];
        [self scrollAnimationFinished];
    }
    else {
        _backingSelectedIndex = selectedIndex;
        visibleSet = [NSSet setWithObject:@(selectedIndex)];
    }
}

- (void)setBackingViewControllers:(NSArray *)backingViewControllers {
    _backingViewControllers = backingViewControllers;
    
    if ([self isViewLoaded]) {
        [self addCurrentChildViewControllers];
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * backingViewControllers.count, CGRectGetHeight(self.scrollView.frame));
}

#pragma mark - ZFPlayer 导致谷歌广告展示完之后视图上移解决

- (NSInteger)zf_selectedIndex {
    NSInteger index = 0;
    if (self.isLayoutDirectionRightToLeft) {
        index = self.backingViewControllers.count-1-self.backingSelectedIndex;
    }
    else {
        index = self.backingSelectedIndex;
    }
    if (index > self.backingViewControllers.count) return 0;
    return index;
}

/**
 * If the root view of the window is a UINavigationController, you call this Category first, and then UIViewController called.
 * All you need to do is revisit the following three methods on a page that supports directions other than portrait.
 */

// Whether automatic screen rotation is supported.
- (BOOL)shouldAutorotate {
    UIViewController *vc = self.backingViewControllers[self.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController shouldAutorotate];
    } else {
        return [vc shouldAutorotate];
    }
}

// Which screen directions are supported.
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.backingViewControllers[self.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController supportedInterfaceOrientations];
    } else {
        return [vc supportedInterfaceOrientations];
    }
}

// The default screen direction (the current ViewController must be represented by a modal UIViewController (which is not valid with modal navigation) to call this method).
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.backingViewControllers[self.selectedIndex];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.topViewController preferredInterfaceOrientationForPresentation];
    } else {
        return [vc preferredInterfaceOrientationForPresentation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
