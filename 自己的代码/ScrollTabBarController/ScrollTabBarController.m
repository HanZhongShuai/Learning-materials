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
    BOOL startedScroll;
    BOOL beginDecelerating;
}

@property (nonatomic, assign) ScrollTabBarControllerDirection direction;

@property (nonatomic, copy) NSArray<__kindof UIViewController *> *backingViewControllers;
@property (nonatomic, assign) NSUInteger backingSelectedIndex;
@property (nonatomic, strong) RC_ScrollView *scrollView;

@end

@implementation ScrollTabBarController

- (void)dealloc
{
    [self.tabBar removeObserver:self forKeyPath:@"hidden"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backingSelectedIndex = 0;
    clickSet = nil;
    if (!self.scrollView) {
        self.scrollView = [[RC_ScrollView alloc] initWithFrame:self.view.bounds];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:self.scrollView belowSubview:self.tabBar];
    }
    
    [self reload];
    
    [self.tabBar addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hidden"]) {
        NSNumber *newNum = [change objectForKey:@"new"];
        NSNumber *oldNum = [change objectForKey:@"old"];
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
    if (self.scrollView) {
        UIViewController *viewController = self.selectedViewController;
        if (viewController) {
            [viewController viewWillAppear:animated];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.scrollView) {
        self.scrollView.delegate = self;
        self.scrollView.scrollEnabled = YES;
        UIViewController *viewController = self.selectedViewController;
        if (viewController) {
            [viewController viewDidAppear:animated];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.scrollView) {
        UIViewController *viewController = self.selectedViewController;
        if (viewController) {
            [viewController viewWillDisappear:animated];
        }
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.scrollView) {
        self.scrollView.delegate = nil;
        self.scrollView.scrollEnabled = NO;
        UIViewController *viewController = self.selectedViewController;
        if (viewController) {
            [viewController viewDidDisappear:animated];
        }
    }
    
    [super viewDidDisappear:animated];
}

- (void)reload
{
    if ([self.backingViewControllers count] == 0) return;
    
    visibleSet = [NSSet setWithObject:@(self.selectedIndex)];
    transitioningSet = nil;
    clickSet = nil;
    startedScroll = NO;
    beginDecelerating = NO;
    self.direction = ScrollTabBarController_None;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self.backingViewControllers count], self.scrollView.frame.size.height);
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
    
    [allSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
        UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
        if (![vc isViewLoaded])
        {
            if (vcNumber.intValue != 1) {
                [[vc view] setFrame:CGRectMake([vcNumber intValue]*self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
                [self.scrollView addSubview:vc.view];
            }
            else {
                [[vc view] setFrame:self.view.bounds];
                [self.view addSubview:vc.view];
                [self.view insertSubview:vc.view belowSubview:self.scrollView];
            }
        }
        else if (vcNumber.intValue == 1 && vc.view.superview == self.scrollView) {
            [[vc view] setFrame:self.view.bounds];
            [self.view addSubview:vc.view];
            [self.view insertSubview:vc.view belowSubview:self.scrollView];
        }
    }];
    
    if (![allSet intersectsSet:[NSSet setWithObject:@1]]) {
        UIViewController *vc = self.backingViewControllers[1];
        if (vc.view.superview == self.scrollView) {
            [[vc view] setFrame:self.view.bounds];
            [self.view addSubview:vc.view];
            [self.view insertSubview:vc.view belowSubview:self.scrollView];
        }
    }
    
    if (clickSet) {
        if (!startedScroll) {
            NSMutableSet *addedSet = [allSet mutableCopy];
            [addedSet minusSet:visibleSet];
            
            // addedSet viewWillAppear
            [addedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc viewWillAppear:YES];
            }];
            
            [visibleSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc viewWillDisappear:YES];
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
            [vc viewWillAppear:YES];
        }];
        
        // removedSet viewDidDisappear
        [transitioningSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc viewWillDisappear:YES];
        }];
    }
    else if (startedScroll == NO && transitioningSet) {
        
        // addedSet viewDidAppear
        [visibleSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc viewDidAppear:YES];
        }];
        
        // removedSet viewDidDisappear
        [transitioningSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc viewDidDisappear:YES];
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
            [vc viewWillAppear:YES];
        }];
        
        if (visibleSet) {
            [visibleSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc viewWillDisappear:YES];
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
                [vc viewWillDisappear:YES];
            }];
            [visibleSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc viewWillAppear:YES];
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
                [vc viewDidAppear:YES];
            }];
            
            // removedSet viewDidDisappear
            [removedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
                UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
                [vc viewDidDisappear:YES];
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
        UIViewController *vc = [self viewControllerWithIndex:1];
        if (vc) {
            [[vc view] setFrame:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
            [self.scrollView addSubview:vc.view];
        }
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
            [vc viewDidAppear:YES];
        }];
        
        // removedSet viewDidDisappear
        [removedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc viewDidDisappear:YES];
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
    UIViewController *vc = [self viewControllerWithIndex:1];
    if (vc) {
        [[vc view] setFrame:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [self.scrollView addSubview:vc.view];
    }
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
            [vc viewDidAppear:YES];
        }];
        
        // removedSet viewDidDisappear
        [removedSet enumerateObjectsUsingBlock:^(NSNumber* vcNumber, BOOL *stop) {
            UIViewController *vc = self.backingViewControllers[[vcNumber intValue]];
            [vc viewDidDisappear:YES];
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
    UIViewController *vc = [self viewControllerWithIndex:1];
    if (vc) {
        [[vc view] setFrame:CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [self.scrollView addSubview:vc.view];
    }
}

- (void)scrollAnimationStartAnimation
{
    if ([self.scrollDelegate respondsToSelector:@selector(tabBarControllerScrollAnimationStartFromIndex:toIndex:)]) {
        NSNumber *visible = [visibleSet anyObject];
        NSNumber *transitioning = [transitioningSet anyObject];
        [self.scrollDelegate tabBarControllerScrollAnimationStartFromIndex:visible.integerValue toIndex:transitioning.integerValue];
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

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    self.backingViewControllers = viewControllers;
    [self reload];
}

- (UIViewController *)selectedViewController {
    return self.backingViewControllers[self.backingSelectedIndex];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    self.selectedIndex = [self.backingViewControllers indexOfObject:selectedViewController];
}

- (NSUInteger)selectedIndex {
    return self.backingSelectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (_backingSelectedIndex == selectedIndex || startedScroll) {
        return;
    }
    if (self.scrollView) {
        if (self.scrollView.delegate) {
            if (selectedIndex < _backingSelectedIndex) {
                clickSet = [NSSet setWithObjects:@(selectedIndex), @(_backingSelectedIndex), nil];
            }
            else {
                clickSet = [NSSet setWithObjects:@(_backingSelectedIndex), @(selectedIndex), nil];
            }
            CGRect rectToVisible = CGRectMake(CGRectGetWidth(self.scrollView.frame) * selectedIndex, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
            [self.scrollView scrollRectToVisible:rectToVisible animated:YES];
        }
        else {
            UIViewController *vc = [_backingViewControllers objectAtIndex:selectedIndex];
            [vc viewWillAppear:NO];
            _backingSelectedIndex = selectedIndex;
            CGRect rectToVisible = CGRectMake(CGRectGetWidth(self.scrollView.frame) * selectedIndex, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
            [self.scrollView scrollRectToVisible:rectToVisible animated:NO];
            visibleSet = [NSSet setWithObject:@(selectedIndex)];
            [vc viewDidAppear:NO];
            [self scrollAnimationFinished];
        }
    }
    else {
        UIViewController *vc = [_backingViewControllers objectAtIndex:selectedIndex];
        [vc viewWillAppear:NO];
        _backingSelectedIndex = selectedIndex;
        visibleSet = [NSSet setWithObject:@(selectedIndex)];
        [vc viewDidAppear:NO];
    }
}

- (void)setBackingViewControllers:(NSArray *)backingViewControllers {
    _backingViewControllers = backingViewControllers;
    
    [backingViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:viewController];
        viewController.view.frame = CGRectMake(CGRectGetWidth(self.scrollView.frame) * idx, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        [self.scrollView addSubview:viewController.view];
    }];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * backingViewControllers.count, CGRectGetHeight(self.scrollView.frame));
}

- (void)selectIndexNoAnimation:(NSInteger)index
{
    if (_backingSelectedIndex == index || _backingViewControllers.count <= index) {
        return;
    }
    if (self.scrollView) {
        UIViewController *vc = [_backingViewControllers objectAtIndex:index];
        [vc viewWillAppear:NO];
        _backingSelectedIndex = index;
        CGRect rectToVisible = CGRectMake(CGRectGetWidth(self.scrollView.frame) * index, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        [self.scrollView scrollRectToVisible:rectToVisible animated:NO];
        visibleSet = [NSSet setWithObject:@(index)];
        [vc viewDidAppear:NO];
        [self scrollAnimationFinished];
    }
    else {
        UIViewController *vc = [_backingViewControllers objectAtIndex:index];
        [vc viewWillAppear:NO];
        _backingSelectedIndex = index;
        visibleSet = [NSSet setWithObject:@(index)];
        [vc viewDidAppear:NO];
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
