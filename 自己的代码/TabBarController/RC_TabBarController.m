//
//  RC_TabBarController.m
//  iOSGetFollow
//
//  Created by TCH on 15/6/18.
//  Copyright (c) 2015年 com.rcplatform. All rights reserved.
//

#import "RC_TabBarController.h"
#import "ExploreViewController.h"
#import "MobileAdsManager.h"
#import "FilterSelectView.h"
#import "UITabBar+RCTabBar.h"
#import "RCSlideTransitionAnimator.h"
#import "RCSlideTransitionInteractionController.h"

#define ScrollBgColor_0 [UIColor colorWithHexString:@"#FFC300"]
#define ScrollBgColor_2 [UIColor colorWithHexString:@"#7370F6"]

@interface RC_TabBarController () <UITabBarControllerDelegate,UIGestureRecognizerDelegate,RCSlideTransitionAnimatorDelegate>
{
    NSInteger oldIndex;
}

@property (nonatomic, strong) UIView *btnBgView;
@property (nonatomic, strong) UIImageView *customTabbar;

@property (nonatomic, strong) UIButton *chatBtn;
@property (nonatomic, strong) UIButton *meBtn;
@property (nonatomic, strong) UIButton *exploreBtn;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UIView *meRedDot;

@property (strong, nonatomic) UIImageView *netWorkTipsView;

@property (nonatomic, weak) ExploreViewController *exploreController;
@property (nonatomic, weak) FilterSelectView *btnSelectGender;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, nonatomic) BOOL useAnimator;

@property (nonatomic, assign) NSInteger chatBadgeValue;
@property (nonatomic, assign) BOOL isGotoMatch;

@property (assign, nonatomic) CGRect tabBarRect;

@end

@implementation RC_TabBarController

//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:nil];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger unread = [[ChatListManager shareManager] getCurrentUnreadMessageCount];
    if (unread < 0) {
        unread = 0;
    }
    if ([MobileAdsManager shareManager].canShowAd) {
        unread++;
    }
    self.chatBadgeValue = unread;
    
    self.useAnimator = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    /// 当前编译使用的 Base SDK 版本为 iOS 13.0 及以上
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *tabBarAppearance = [self.tabBar.standardAppearance copy];
        [tabBarAppearance setBackgroundEffect:nil];
        [tabBarAppearance setShadowColor:[UIColor clearColor]];
        [self.tabBar setStandardAppearance:tabBarAppearance];
    }
    #endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewUnreadMessage:) name:kUpdateUnreadNumber object:nil];
    // Do any additional setup after loading the view.
}

- (void)haveNewUnreadMessage:(NSNotification *)note
{
    if (note.object && [note.object isKindOfClass:[NSNumber class]]) {
        NSNumber *unread =(NSNumber *)note.object;
        self.chatBadgeValue = unread.integerValue;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if (!CGRectEqualToRect(self.tabBarRect, self.btnBgView.frame)) {
        self.btnBgView.frame = self.tabBarRect;
    }
//    if ((SafeArea && self.tabBar.frame.size.height <= 49+34) || (self.tabBar.frame.size.height <= 49)) {
//        [self reloadTabBarHtight];
//    }

        
    [self.tabBar bringSubviewToFront:self.btnBgView];
    
    for (UITabBarItem *item in self.tabBar.items) {
        if (item.enabled) {
            item.enabled = NO;
        }
    }
}

- (void)reloadTabBarHtight
{
//    CGRect frame = self.tabBar.frame;
//    if (SafeArea) {
//        frame.size.height = 96;
//    }
//    else {
//        frame.size.height = 75;
//    }
//    
//    frame.origin.y = self.view.frame.size.height - frame.size.height;
//    
//    self.tabBar.frame = frame;
//    self.btnBgView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
{
    [super setViewControllers:viewControllers];
    [self customTabBar];
}

- (void)customTabBar
{
    [MobClick event:@"discover_view" label:nil];
    self.selectedIndex = 1;
    oldIndex = 1;
    
    self.tabBar.backgroundColor = [UIColor clearColor];
    self.tabBar.tintColor = [UIColor clearColor];
    self.tabBar.barTintColor = [UIColor clearColor];
    self.tabBar.backgroundImage = [[UIImage alloc] init];
    self.tabBar.shadowImage = [[UIImage alloc] init];
    
    for (UITabBarItem *item in self.tabBar.items) {
        item.enabled = NO;
    }
    self.tabBarRect = CGRectMake(0, (SafeArea?(83-96):49-75), self.view.frame.size.width, (SafeArea?(96):75));
    self.tabBar.clickArea = -self.tabBarRect.origin.y;
    
    if (!self.btnBgView) {
        self.btnBgView = [[UIView alloc] initWithFrame:self.tabBarRect];
        self.btnBgView.backgroundColor = [UIColor clearColor];
//        self.btnBgView.clipsToBounds = YES;
        [self.tabBar addSubview:self.btnBgView];
    }
    
    if (!self.netWorkTipsView) {
        self.netWorkTipsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"netWorkTipsBgImage"]];
        self.netWorkTipsView.hidden = YES;
        [self.btnBgView addSubview:self.netWorkTipsView];
        UILabel *lblNetWorkTips = [[UILabel alloc]init];
        [lblNetWorkTips setText:NSLocalizedString(@"no_network_connection", nil)];
        
        [lblNetWorkTips setTextColor:[UIColor whiteColor]];
        [lblNetWorkTips setTextAlignment:NSTextAlignmentCenter];
        lblNetWorkTips.numberOfLines = 0;
        lblNetWorkTips.font = [UIFont fontWithName:FontNameMedium size:15];
        [self.netWorkTipsView addSubview:lblNetWorkTips];
        [self.netWorkTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.btnBgView);
            make.bottom.equalTo(self.btnBgView.mas_top).with.offset(20);
            make.height.equalTo(self.netWorkTipsView.mas_width).with.multipliedBy(72.0/375.0);
        }];
        [lblNetWorkTips mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.netWorkTipsView).with.offset(16);
            make.trailing.equalTo(self.netWorkTipsView).with.offset(-16);
            make.top.equalTo(self.netWorkTipsView).with.offset(19);
        }];
    }
    
    if (!self.customTabbar) {
        self.customTabbar = [[UIImageView alloc] init];
        self.customTabbar.userInteractionEnabled = YES;
        self.customTabbar.contentMode = UIViewContentModeScaleAspectFill;
        UIImage *bgImage = [UIImage imageNamed:@"home_downline_bg"];
        if (SafeArea) {
            bgImage = [UIImage imageNamed:@"home_downline_bg_X"];
        }
        self.customTabbar.image = bgImage;
        [self.btnBgView addSubview:self.customTabbar];
        
        [self.customTabbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.bottom.equalTo(self.btnBgView);
            if (SafeArea) {
                make.height.mas_equalTo(96);
            }
            else {
                make.height.mas_equalTo(75);
            }
        }];
    }
    
    CGFloat letftSpace = 10;
    if (!self.chatBtn) {
        self.chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.chatBtn setImage:[UIImage imageNamed:@"icon_home_chat_normal"] forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(goToChatViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.customTabbar addSubview:self.chatBtn];
        
        [self.chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.customTabbar.mas_trailing).with.offset(-letftSpace);
            if (SafeArea) {
                make.top.equalTo(self.customTabbar.mas_top).with.offset(13);
            }
            else {
                make.top.equalTo(self.customTabbar.mas_top).with.offset(22);
            }
            make.width.mas_equalTo(49);
            make.height.mas_equalTo(49);
        }];
    }
    
    if (!self.meBtn) {
        self.meBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.meBtn setImage:[UIImage imageNamed:@"icon_home_me_normal"] forState:UIControlStateNormal];
        [self.meBtn addTarget:self action:@selector(goToMeViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.customTabbar addSubview:self.meBtn];
        
        [self.meBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.customTabbar.mas_leading).with.offset(letftSpace);
            if (SafeArea) {
                make.top.equalTo(self.customTabbar.mas_top).with.offset(13);
            }
            else {
                make.top.equalTo(self.customTabbar.mas_top).with.offset(22);
            }
            make.width.mas_equalTo(49);
            make.height.mas_equalTo(49);
        }];
    }
    
    if (!self.exploreBtn) {
        self.exploreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.exploreBtn setImage:[UIImage imageNamed:@"icon_home_match_normal"] forState:UIControlStateNormal];
        [self.exploreBtn addTarget:self action:@selector(goToExploreViewController) forControlEvents:UIControlEventTouchUpInside];
        self.exploreBtn.contentMode = UIViewContentModeScaleAspectFill;
        [self.customTabbar addSubview:self.exploreBtn];
        
        [self.exploreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.customTabbar.mas_centerX);
            if (SafeArea) {
                make.top.equalTo(self.customTabbar.mas_top).with.offset(4);
            }
            else {
                make.top.equalTo(self.customTabbar.mas_top).with.offset(9);
            }
            make.width.mas_equalTo(56);
            make.height.mas_equalTo(56);
        }];
    }
    
    if (!self.badgeLabel) {
        self.badgeLabel = [[UILabel alloc] init];
        self.badgeLabel.textColor = [UIColor whiteColor];
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeLabel.font = [UIFont systemFontOfSize:9];
        self.badgeLabel.numberOfLines = 1;
        self.badgeLabel.backgroundColor = colorWithHexString(@"#FF5445");
        self.badgeLabel.layer.cornerRadius = 7.5;
        self.badgeLabel.layer.masksToBounds = YES;
        [self.customTabbar addSubview:self.badgeLabel];
        
        [self reloadBadgeLabelText];
        
        [self.badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.chatBtn.mas_top).with.offset(5);
            make.trailing.equalTo(self.customTabbar).with.offset(-10);
            make.width.mas_greaterThanOrEqualTo(15);
            make.height.mas_equalTo(15);
        }];
        [self.badgeLabel sizeToFit];
    }
    
    if (!self.meRedDot) {
        self.meRedDot = [[UILabel alloc] init];
        self.meRedDot.backgroundColor = colorWithHexString(@"#FF5445");
        self.meRedDot.layer.cornerRadius = 4;
        self.meRedDot.layer.masksToBounds = YES;
        self.meRedDot.hidden = YES;
        [self.customTabbar addSubview:self.meRedDot];
        
        [self.meRedDot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.meBtn.mas_top).with.offset(8);
            make.trailing.equalTo(self.meBtn.mas_trailing).with.offset(-8);
            make.width.mas_greaterThanOrEqualTo(8);
            make.height.mas_equalTo(8);
        }];
    }
    
    [self selectedCustonBtn:YES];
    [self reloadTabBarHtight];
    
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    __weak typeof(self.netWorkTipsView)weakNetWorkTipsView = self.netWorkTipsView;
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                CLog(@"未识别的网络");
                if (weakNetWorkTipsView) {
                    weakNetWorkTipsView.hidden = NO;
                }
                break;
            case AFNetworkReachabilityStatusNotReachable:
                CLog(@"不可达的网络(未连接)");
                if (weakNetWorkTipsView) {
                    weakNetWorkTipsView.hidden = NO;
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                CLog(@"2G,3G,4G...的网络");
                if (weakNetWorkTipsView) {
                    weakNetWorkTipsView.hidden = YES;
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                CLog(@"wifi的网络");
                if (weakNetWorkTipsView) {
                    weakNetWorkTipsView.hidden = YES;
                }
                break;
            default:
                break;
        }
    }];
}

- (ExploreViewController *)exploreController
{
    if (!_exploreController && self.viewControllers.count > 1) {
        UIViewController *nav = [self.viewControllers objectAtIndex:1];
        if (nav && [nav isKindOfClass:[UINavigationController class]] && ((UINavigationController *)nav).viewControllers) {
            UIViewController *explore = [((UINavigationController *)nav).viewControllers firstObject];
            if ([explore isKindOfClass:[ExploreViewController class]]) {
                _exploreController = (ExploreViewController *)explore;
            }
        }
    }
    return _exploreController;
}

- (FilterSelectView *)btnSelectGender
{
    if (self.exploreController) {
        return self.exploreController.filterSelectView;
    }
    return nil;
}

- (void)goToChatViewController
{
    if (self.selectedIndex != 2) {
        if (self.transitionCoordinator == nil) {
            self.selectedIndex = 2;
        }
    }
}

- (void)goToExploreViewController
{
    if (self.isGotoMatch) {
        return;
    }
    if (self.selectedIndex != 1) {
        if (self.transitionCoordinator == nil) {
            self.selectedIndex = 1;
        }
        [RC_RequestManager EventId:@"1-2-8-1" remark:@2];
    }
    else {
        if (self.exploreController) {
            self.isGotoMatch = YES;
            [self.exploreController goToMatchUser];
            [self performSelector:@selector(goToMatchUserToSetIsAnimation) withObject:nil afterDelay:1];
        }
        [RC_RequestManager EventId:@"1-2-8-1" remark:@1];
    }
}

- (void)goToMatchUserToSetIsAnimation
{
    self.isGotoMatch = NO;
}

- (void)goToMeViewController
{
    if (self.selectedIndex != 0) {
        if (self.transitionCoordinator == nil) {
            self.selectedIndex = 0;
        }
    }
}

- (void)selectedCustonBtn:(BOOL)selected
{
    if (selected) {
        if (oldIndex == 1 && self.selectedIndex == 2) {
            [MobClick event:@"discover_messengerpage" label:nil];
        }
        else if (oldIndex == 1 && self.selectedIndex == 0) {
            [MobClick event:@"discover_minepage" label:nil];
        }
        oldIndex = self.selectedIndex;
    }
    
    self.view.backgroundColor = [self getBackgroundColorWithIndex:oldIndex];
    if (oldIndex == 0) {
        self.chatBtn.selected = NO;
        self.meBtn.selected = YES;
        self.exploreBtn.selected = NO;
        if (self.btnSelectGender) {
            self.btnSelectGender.frame = CGRectMake(CGRectGetMinX(self.btnSelectGender.frame), -CGRectGetHeight(self.btnSelectGender.frame)*1.5, CGRectGetWidth(self.btnSelectGender.frame), CGRectGetHeight(self.btnSelectGender.frame));
        }
        [self.chatBtn setImage:[UIImage imageNamed:@"icon_me_chat_normal"] forState:UIControlStateNormal];
        [self.meBtn setImage:[UIImage imageNamed:@"icon_me_me_normal"] forState:UIControlStateNormal];
        [self.exploreBtn setImage:[UIImage imageNamed:@"icon_me_match_normal"] forState:UIControlStateNormal];
        [RC_RequestManager EventId:@"3-1-1-1"];
    }
    else if (oldIndex == 1) {
        self.chatBtn.selected = NO;
        self.meBtn.selected = NO;
        self.exploreBtn.selected = YES;
        if (self.btnSelectGender) {
            self.btnSelectGender.frame = CGRectMake(CGRectGetMinX(self.btnSelectGender.frame), 5, CGRectGetWidth(self.btnSelectGender.frame), CGRectGetHeight(self.btnSelectGender.frame));
        }
        [self.chatBtn setImage:[UIImage imageNamed:@"icon_home_chat_normal"] forState:UIControlStateNormal];
        [self.meBtn setImage:[UIImage imageNamed:@"icon_home_me_normal"] forState:UIControlStateNormal];
        [self.exploreBtn setImage:[UIImage imageNamed:@"icon_home_match_normal"] forState:UIControlStateNormal];
    }
    else if (oldIndex == 2) {
        self.chatBtn.selected = YES;
        self.meBtn.selected = NO;
        self.exploreBtn.selected = NO;
        if (self.btnSelectGender) {
            self.btnSelectGender.frame = CGRectMake(CGRectGetMinX(self.btnSelectGender.frame), -CGRectGetHeight(self.btnSelectGender.frame)*1.5, CGRectGetWidth(self.btnSelectGender.frame), CGRectGetHeight(self.btnSelectGender.frame));
        }
        [self.chatBtn setImage:[UIImage imageNamed:@"icon_home_chat_normal"] forState:UIControlStateNormal];
        [self.meBtn setImage:[UIImage imageNamed:@"icon_chat_me_normal"] forState:UIControlStateNormal];
        [self.exploreBtn setImage:[UIImage imageNamed:@"icon_me_match_normal"] forState:UIControlStateNormal];
        [RC_RequestManager EventId:@"8-2-2-1"];
    }
}

- (void)selectIndex:(NSInteger)index
{
    [self setSelectedIndex:index animated:NO];
}

- (void)setChatBadgeValue:(NSInteger)chatBadgeValue
{
    _chatBadgeValue = chatBadgeValue;
    [self performSelectorOnMainThread:@selector(reloadBadgeLabelText) withObject:nil waitUntilDone:NO];
}

- (void)reloadBadgeLabelText
{
    NSInteger chatBadgeNum = _chatBadgeValue;

    if (self.badgeLabel) {
        if (chatBadgeNum > 99) {
            self.badgeLabel.hidden = NO;
            self.badgeLabel.text = @" 99+ ";
        }
        else if (chatBadgeNum > 0) {
            self.badgeLabel.hidden = NO;
            self.badgeLabel.text = [NSString stringWithFormat:@"%ld",chatBadgeNum];
        }
        else {
            self.badgeLabel.hidden = YES;
            self.badgeLabel.text = nil;
        }
    }
}

-(void)mePageDotTipsHidden:(BOOL)hidden
{
    self.meRedDot.hidden = hidden;
}

#pragma mark - tools

- (UIColor *)getBackgroundColorWithIndex:(NSInteger)index
{
    if (index == 0) {
        return ScrollBgColor_0;
    }
    else if (index == 2) {
        return ScrollBgColor_2;
    }
    return [UIColor clearColor];
}

#pragma mark - transition

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    self.useAnimator = animated;
    [self setSelectedIndex:selectedIndex];
    if (!animated) {
        [self selectedCustonBtn:YES];
    }
    self.useAnimator = YES;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    NSInteger oldSelectedIndex = self.selectedIndex;
    NSInteger newSelectedIndex = selectedIndex;
    
    [super setSelectedIndex:selectedIndex];
    
    [self addTransitionAnimateWithOldSelectedIndex:oldSelectedIndex newSelectedIndex:newSelectedIndex];
}

- (UIPanGestureRecognizer*)panGestureRecognizer
{
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerDidPan:)];
        _panGestureRecognizer.maximumNumberOfTouches = 1;
        _panGestureRecognizer.delegate = self;
    }
    
    return _panGestureRecognizer;
}

- (IBAction)panGestureRecognizerDidPan:(UIPanGestureRecognizer*)sender
{
    // Do not attempt to begin an interactive transition if one is already
    // ongoing
    if (self.transitionCoordinator)
        return;
    
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
        [self beginInteractiveTransitionIfPossible:sender];
    
    // Remaining cases are handled by the vended
    // RCSlideTransitionInteractionController.
}


//| ----------------------------------------------------------------------------
//! Begins an interactive transition with the provided gesture recognizer, if
//! there is a view controller to transition to.
//
- (void)beginInteractiveTransitionIfPossible:(UIPanGestureRecognizer *)sender
{
    self.useAnimator = YES;
    CGPoint translation = [sender translationInView:self.view];
    
    NSInteger oldSelectedIndex = self.selectedIndex;
    NSInteger newSelectedIndex = oldSelectedIndex;
    
    if (self.isLayoutDirectionRightToLeft) {
        if (translation.x > 0.f && self.selectedIndex + 1 < self.viewControllers.count) {
            // Panning right, transition to the left view controller.
            self.selectedIndex++;
            newSelectedIndex++;
        } else if (translation.x < 0.f && self.selectedIndex > 0) {
            // Panning left, transition to the right view controller.
            self.selectedIndex--;
            newSelectedIndex--;
        } else {
            // Don't reset the gesture recognizer if we skipped starting the
            // transition because we don't have a translation yet (and thus, could
            // not determine the transition direction).
            if (!CGPointEqualToPoint(translation, CGPointZero)) {
                // There is not a view controller to transition to, force the
                // gesture recognizer to fail.
                sender.enabled = NO;
                sender.enabled = YES;
            }
        }
    }
    else {
        if (translation.x > 0.f && self.selectedIndex > 0) {
            // Panning right, transition to the left view controller.
            self.selectedIndex--;
            newSelectedIndex--;
        } else if (translation.x < 0.f && self.selectedIndex + 1 < self.viewControllers.count) {
            // Panning left, transition to the right view controller.
            self.selectedIndex++;
            newSelectedIndex++;
        } else {
            // Don't reset the gesture recognizer if we skipped starting the
            // transition because we don't have a translation yet (and thus, could
            // not determine the transition direction).
            if (!CGPointEqualToPoint(translation, CGPointZero)) {
                // There is not a view controller to transition to, force the
                // gesture recognizer to fail.
                sender.enabled = NO;
                sender.enabled = YES;
            }
        }
    }
    
    // We must handle the case in which the user begins panning but then
    // reverses direction without lifting their finger.  The transition
    // should seamlessly switch to revealing the correct view controller
    // for the new direction.
    //
    // The approach presented in this demonstration relies on coordination
    // between this object and the RCSlideTransitionInteractionController
    // it vends.  If the RCSlideTransitionInteractionController detects
    // that the current position of the user's touch along the horizontal
    // axis has crossed over the initial position, it cancels the
    // transition.  A completion block is attached to the tab bar
    // controller's transition coordinator.  This block will be called when
    // the transition completes or is cancelled.  If the transition was
    // cancelled but the gesture recgonzier has not transitioned to the
    // ended or failed state, a new transition to the proper view controller
    // is started, and new animation + interaction controllers are created.
    //
    
//    [self.transitionCoordinator animateAlongsideTransition:NULL completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//        if ([context isCancelled] && sender.state == UIGestureRecognizerStateChanged) [self beginInteractiveTransitionIfPossible:sender];
//    }];
}

- (void)addTransitionAnimateWithOldSelectedIndex:(NSInteger)oldSelectedIndex newSelectedIndex:(NSInteger)newSelectedIndex
{
    UIView *tabbarView = self.view;
    
    BOOL showAnimate = NO;
    
    CGRect btnFrame = CGRectZero;
    CGRect btnToFrame = btnFrame;
    if ((oldSelectedIndex == 1 || newSelectedIndex == 1) && self.btnSelectGender) {
        showAnimate = YES;
        btnFrame = self.btnSelectGender.frame;
        btnToFrame = btnFrame;
        if (btnFrame.origin.y >= 0) {
            btnToFrame.origin = CGPointMake(btnFrame.origin.x, btnFrame.origin.y-(btnFrame.size.height*1.5));
        }
        else {
            btnToFrame.origin = CGPointMake(btnFrame.origin.x, btnFrame.origin.y+(btnFrame.size.height*1.5));
        }
    }
    
    [self rc_animateAlongsideTransitionInView:tabbarView animation:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        tabbarView.backgroundColor = [self getBackgroundColorWithIndex:newSelectedIndex];
        if (showAnimate) {
            self.btnSelectGender.frame = btnToFrame;
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (context && [context isCancelled]) {
            tabbarView.backgroundColor = [self getBackgroundColorWithIndex:oldSelectedIndex];
            if (showAnimate) {
                self.btnSelectGender.frame = btnFrame;
            }
            
            if (self.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
                [self beginInteractiveTransitionIfPossible:self.panGestureRecognizer];
            }
        }
    }];
}

- (void)rc_animateAlongsideTransitionInView:(nullable UIView *)view
                                  animation:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))animation
                                 completion:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))completion
{
    if (self.transitionCoordinator) {
        BOOL animationQueuedToRun = [self.transitionCoordinator animateAlongsideTransitionInView:view animation:animation completion:completion];
        // 某些情况下传给 animateAlongsideTransition 的 animation 不会被执行，这时候要自己手动调用一下
        // 但即便如此，completion 也会在动画结束后才被调用，因此这样写不会导致 completion 比 animation block 先调用
        // 某些情况包含：从 B 手势返回 A 的过程中，取消手势，animation 不会被调用
        // https://github.com/Tencent/QMUI_iOS/issues/692
        if (!animationQueuedToRun && animation) {
            animation(nil);
        }
    } else {
        if (animation) animation(nil);
        if (completion) completion(nil);
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.tabBar.hidden || self.transitionCoordinator) {
        return NO;
    }
    UIViewController *selectVc = self.selectedViewController;
    if (selectVc && [selectVc isKindOfClass:[UINavigationController class]]) {
        if ([(UINavigationController *)selectVc viewControllers].count > 1) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
        return NO;
    }
    else if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark UITabBarControllerDelegate

//| ----------------------------------------------------------------------------
//  The tab bar controller tries to invoke this method on its delegate to
//  retrieve an animator object to be used for animating the transition to the
//  incoming view controller.  Your implementation is expected to return an
//  object that conforms to the UIViewControllerAnimatedTransitioning protocol,
//  or nil if the transition should not be animated.
//
- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    NSAssert(tabBarController == self, @"%@ is not the tab bar controller currently associated with %@", tabBarController, self);
    
    if (!self.useAnimator) {
        return nil;
    }
    
    NSArray *viewControllers = tabBarController.viewControllers;
    
    UIRectEdge edge;
    if ([viewControllers indexOfObject:toVC] > [viewControllers indexOfObject:fromVC]) {
        // The incoming view controller succeeds the outgoing view controller,
        // slide towards the left.
        edge = self.isLayoutDirectionRightToLeft?UIRectEdgeRight:UIRectEdgeLeft;
    } else {
        // The incoming view controller precedes the outgoing view controller,
        // slide towards the right.
        edge = self.isLayoutDirectionRightToLeft?UIRectEdgeLeft:UIRectEdgeRight;
    }
    
    RCSlideTransitionAnimator *animator = [[RCSlideTransitionAnimator alloc] initWithTargetEdge:edge];
    animator.delegate = self;
    return animator;
}


//| ----------------------------------------------------------------------------
//  If an id<UIViewControllerAnimatedTransitioning> was returned from
//  -tabBarController:animationControllerForTransitionFromViewController:toViewController:,
//  the tab bar controller tries to invoke this method on its delegate to
//  retrieve an interaction controller for the transition.  Your implementation
//  is expected to return an object that conforms to the
//  UIViewControllerInteractiveTransitioning protocol, or nil if the transition
//  should not be a interactive.
//
- (id<UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    NSAssert(tabBarController == self, @"%@ is not the tab bar controller currently associated with %@", tabBarController, self);
    
    if (self.panGestureRecognizer.state == UIGestureRecognizerStateBegan || self.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        UIRectEdge edge = UIRectEdgeNone;
        if (animationController && [animationController isKindOfClass:[RCSlideTransitionAnimator class]]) {
            edge = [(RCSlideTransitionAnimator *)animationController targetEdge];
        }
        RCSlideTransitionInteractionController *tran = [[RCSlideTransitionInteractionController alloc] initWithGestureRecognizer:self.panGestureRecognizer];
        tran.targetEdge = edge;
        return tran;
    } else {
        // You must not return an interaction controller from this method unless
        // the transition will be interactive.
        return nil;
    }
}

#pragma mark - RCSlideTransitionAnimatorDelegate

- (void)slideTransitionAnimationEnded:(BOOL)transitionCompleted
{
    [self selectedCustonBtn:transitionCompleted];
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

