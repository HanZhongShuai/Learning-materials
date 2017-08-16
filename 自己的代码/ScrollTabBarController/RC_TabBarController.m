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

#define kTabBarHaveUnreadMessage [NSString stringWithFormat:@"%@%@",@"TabBarHaveUnreadMessage",((UserInfoModel *)[UserInfoModel unarchiverUserInfo]).id]

@interface RC_TabBarController () <ScrollTabBarControllerDelete>
{
    BOOL haveUnread;
    
    NSInteger oldIndex;
    
    BOOL noAnimationChange;
}

@property (nonatomic, strong) UIButton *exploreAnimateBtn;

@end

@implementation RC_TabBarController

//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *unreadNum = [userDefault objectForKey:kTabBarHaveUnreadMessage];
    if ((unreadNum && unreadNum.integerValue > 0) || [MobileAdsManager shareManager].canShowAd) {
        haveUnread = YES;
    }
    else {
        haveUnread = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewUnreadMessage:) name:kNote_ReceiveSystemAndNormalMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewUnreadMessage:) name:kRewardBasedVideoAdValueChange object:nil];
    // Do any additional setup after loading the view.
}

- (void)haveNewUnreadMessage:(NSNotification *)note
{
    if (note && [note isKindOfClass:[NSNotification class]] && [note.name isEqualToString:kRewardBasedVideoAdValueChange]) {
        if ([MobileAdsManager shareManager].canShowAd) {
            if (!self.chatBtn.selected) {
                haveUnread = YES;
                [self performSelectorOnMainThread:@selector(setChatBtnImage) withObject:nil waitUntilDone:NO];
            }
        }
    }
    else {
        if (!self.chatBtn.selected) {
            [userDefault setObject:@1 forKey:kTabBarHaveUnreadMessage];
            [userDefault synchronize];
            haveUnread = YES;
            [self performSelectorOnMainThread:@selector(setChatBtnImage) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.tabBar.frame;
    
    if (frame.size.height <= 49) {
        frame.size.height = 70+78;
        
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        
        self.tabBar.frame = frame;
        self.meBtn.frame = CGRectMake(47, self.tabBar.height-33-32, 32, 32);
        self.chatBtn.frame = CGRectMake(self.tabBar.width - 47 - 32, self.tabBar.height-33-32, 32, 32);
        self.exploreBtn.frame = CGRectMake((self.tabBar.width-78)/2.0, self.tabBar.height-78-70, 78, 78);
        self.beautyBtn.frame = CGRectMake((self.tabBar.width-36)/2.0, self.tabBar.height-36-12, 36, 36);
    }
    [self.tabBar bringSubviewToFront:self.meBtn];
    [self.tabBar bringSubviewToFront:self.chatBtn];
    [self.tabBar bringSubviewToFront:self.exploreBtn];
    [self.tabBar bringSubviewToFront:self.beautyBtn];
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
    
    if (!self.chatBtn) {
        self.chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setChatBtnImage];
        self.chatBtn.frame = CGRectMake(self.tabBar.width - 47 - 32, self.tabBar.height-33-32, 32, 32);
        [self.chatBtn addTarget:self action:@selector(goToChatViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBar addSubview:self.chatBtn];
    }
    
    if (!self.meBtn) {
        self.meBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.meBtn setImage:[UIImage imageNamed:@"icon_home_me_normal"] forState:UIControlStateNormal];
        self.meBtn.frame = CGRectMake(47, self.tabBar.height-33-32, 32, 32);
        [self.meBtn addTarget:self action:@selector(goToMeViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBar addSubview:self.meBtn];
    }
    
    if (!self.exploreBtn) {
        self.exploreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.exploreBtn setBackgroundImage:[UIImage imageNamed:@"icon_home_match_big"] forState:UIControlStateNormal];
        self.exploreBtn.frame = CGRectMake((self.tabBar.width-78)/2.0, self.tabBar.height-78-70, 78, 78);
        [self.exploreBtn addTarget:self action:@selector(goToExploreViewController) forControlEvents:UIControlEventTouchUpInside];
        self.exploreBtn.contentMode = UIViewContentModeScaleAspectFill;
        [self.tabBar addSubview:self.exploreBtn];
        
        self.exploreAnimateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.exploreAnimateBtn.frame = self.exploreBtn.bounds;
        self.exploreAnimateBtn.userInteractionEnabled = NO;
        self.exploreAnimateBtn.hidden = YES;
        [self.exploreAnimateBtn setBackgroundImage:[UIImage imageNamed:@"icon_home_match_big"] forState:UIControlStateNormal];
        [self.exploreBtn addSubview:self.exploreAnimateBtn];
    }
    
    if (!self.beautyBtn) {
        self.beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.beautyBtn setImage:[UIImage imageNamed:@"icon_video_dynamic"] forState:UIControlStateNormal];
//        [self.beautyBtn setImage:[UIImage imageNamed:@"icon_video_dynamic_close"] forState:UIControlStateSelected];
        self.beautyBtn.frame = CGRectMake((self.tabBar.width-36)/2.0, self.tabBar.height-36-12, 36, 36);
        [self.beautyBtn addTarget:self action:@selector(pressBeautyBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBar addSubview:self.beautyBtn];
    }
    
//    self.delegate = self;
    self.scrollDelegate = self;
}

- (void)pressBeautyBtn
{
    [self showOrHiddenBeauty:!self.beautyBtn.selected];
}

- (void)showOrHiddenBeauty:(BOOL)show
{
    if (self.beautyBtn.selected == show) {
        return;
    }
    self.beautyBtn.selected = show;
    self.scrollView.scrollEnabled = !show;
    self.exploreBtn.userInteractionEnabled = !show;
    self.chatBtn.hidden = show;
    self.meBtn.hidden = show;
    if (show) {
        CGRect frame = self.tabBar.frame;
        frame.size.height = 33+32;
        
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        
        self.tabBar.frame = frame;
        self.meBtn.frame = CGRectMake(47, self.tabBar.height-33-32, 32, 32);
        self.chatBtn.frame = CGRectMake(self.tabBar.width - 47 - 32, self.tabBar.height-33-32, 32, 32);
        self.exploreBtn.frame = CGRectMake((self.tabBar.width-78)/2.0, self.tabBar.height-78-70, 78, 78);
        self.beautyBtn.frame = CGRectMake((self.tabBar.width-36)/2.0, self.tabBar.height-36-12, 36, 36);
    }
    else {
        CGRect frame = self.tabBar.frame;
        frame.size.height = 70+78;
        
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        
        self.tabBar.frame = frame;
        self.meBtn.frame = CGRectMake(47, self.tabBar.height-33-32, 32, 32);
        self.chatBtn.frame = CGRectMake(self.tabBar.width - 47 - 32, self.tabBar.height-33-32, 32, 32);
        self.exploreBtn.frame = CGRectMake((self.tabBar.width-78)/2.0, self.tabBar.height-78-70, 78, 78);
        self.beautyBtn.frame = CGRectMake((self.tabBar.width-36)/2.0, self.tabBar.height-36-12, 36, 36);
    }
    
    UIViewController *nav = [self viewControllerWithIndex:1];
    if (nav && [nav isKindOfClass:[UINavigationController class]] && ((UINavigationController *)nav).topViewController) {
        UIViewController *explore = ((UINavigationController *)nav).topViewController;
        if ([explore isKindOfClass:[ExploreViewController class]]) {
            [(ExploreViewController *)explore showOrHiddenBeauty:show];
        }
    }
    
    self.exploreAnimateBtn.frame = self.exploreBtn.bounds;
    self.exploreAnimateBtn.hidden = YES;
    if (self.beautyBtn.selected) {
        [self.exploreBtn setBackgroundImage:[UIImage imageNamed:@"icon_video_dynamic_round_choose"] forState:UIControlStateNormal];
        self.exploreAnimateBtn.hidden = NO;
        self.exploreAnimateBtn.alpha = 1.0;
        [UIView animateWithDuration:0.3 animations:^{
            self.beautyBtn.transform = CGAffineTransformMakeRotation(M_PI/180*179);
            self.exploreAnimateBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.exploreAnimateBtn.alpha = 0.4;
        } completion:^(BOOL finished) {
            self.exploreAnimateBtn.hidden = YES;
            self.beautyBtn.transform = CGAffineTransformMakeRotation(0);
            self.exploreAnimateBtn.transform = CGAffineTransformMakeRotation(0);
            [self.beautyBtn setImage:[UIImage imageNamed:@"icon_video_dynamic_close"] forState:UIControlStateNormal];
        }];
    }
    else {
        [self.beautyBtn setImage:[UIImage imageNamed:@"icon_video_dynamic"] forState:UIControlStateNormal];
        
        self.exploreAnimateBtn.hidden = NO;
        self.exploreAnimateBtn.alpha = 0.4;
        self.beautyBtn.transform = CGAffineTransformMakeRotation(M_PI/180*179);
        self.exploreAnimateBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
        [UIView animateWithDuration:0.3 animations:^{
            self.beautyBtn.transform = CGAffineTransformMakeRotation(0);
            self.exploreAnimateBtn.transform = CGAffineTransformMakeRotation(0);
            self.exploreAnimateBtn.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.exploreAnimateBtn.hidden = YES;
            [self.exploreBtn setBackgroundImage:[UIImage imageNamed:@"icon_home_match_big"] forState:UIControlStateNormal];
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.beautyBtn.selected == YES) {
        [self showOrHiddenBeauty:NO];
    }
}

- (void)goToChatViewController
{
    if (self.beautyBtn.selected) {
        [self showOrHiddenBeauty:NO];
        return;
    }
    if (self.selectedIndex != 2) {
        if (self.transitionCoordinator == nil) {
            self.selectedIndex = 2;
        }
    }
}

- (void)goToExploreViewController
{
    if (self.selectedIndex != 1) {
        if (self.transitionCoordinator == nil) {
            self.selectedIndex = 1;
        }
    }
    else if (self.beautyBtn.selected == NO) {
        UIViewController *nav = [self viewControllerWithIndex:1];
        if (nav && [nav isKindOfClass:[UINavigationController class]] && ((UINavigationController *)nav).topViewController) {
            UIViewController *explore = ((UINavigationController *)nav).topViewController;
            if ([explore isKindOfClass:[ExploreViewController class]]) {
                [MobClick event:@"discover_matchbutton" label:nil];
                [(ExploreViewController *)explore goToMatchUser];
            }
        }
    }
}

- (void)goToMeViewController
{
    if (self.beautyBtn.selected) {
        [self showOrHiddenBeauty:NO];
        return;
    }
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
    
    if (oldIndex == 0) {
        self.chatBtn.selected = NO;
        self.meBtn.selected = YES;
        [self setChatBtnImage];
        [self.exploreBtn setBackgroundImage:[UIImage imageNamed:@"icon_me_match_small"] forState:UIControlStateNormal];
        [self.meBtn setImage:[UIImage imageNamed:@"icon_me_person_pressed"] forState:UIControlStateNormal];
    }
    else if (oldIndex == 1) {
        self.chatBtn.selected = NO;
        self.meBtn.selected = NO;
        [self setChatBtnImage];
        [self.exploreBtn setBackgroundImage:[UIImage imageNamed:@"icon_home_match_big"] forState:UIControlStateNormal];
        [self.meBtn setImage:[UIImage imageNamed:@"icon_home_me_normal"] forState:UIControlStateNormal];
    }
    else if (oldIndex == 2) {
        haveUnread = NO;
        [userDefault setObject:@0 forKey:kTabBarHaveUnreadMessage];
        [userDefault synchronize];
        self.chatBtn.selected = YES;
        self.meBtn.selected = NO;
        [self setChatBtnImage];
        [self.exploreBtn setBackgroundImage:[UIImage imageNamed:@"icon_me_match_small"] forState:UIControlStateNormal];
        [self.meBtn setImage:[UIImage imageNamed:@"icon_message_me_norml"] forState:UIControlStateNormal];
    }
    
    if (oldIndex != 1) {
        CGRect frame = self.tabBar.frame;
        frame.size.height = 33+32;
        
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        
        self.tabBar.frame = frame;
        self.meBtn.frame = CGRectMake(85, self.tabBar.height-25-32, 32, 32);
        self.chatBtn.frame = CGRectMake(self.tabBar.width - 85 - 32, self.tabBar.height-25-32, 32, 32);
        self.exploreBtn.frame = CGRectMake((self.tabBar.width-50)/2.0, self.tabBar.height-50-18, 50, 50);
        self.beautyBtn.frame = CGRectMake((self.tabBar.width-36)/2.0, self.tabBar.height-36-12, 36, 36);
        self.beautyBtn.alpha = 0.0;
    }
    else {
        CGRect frame = self.tabBar.frame;
        frame.size.height = 70+78;
        
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        
        self.tabBar.frame = frame;
        self.meBtn.frame = CGRectMake(47, self.tabBar.height-33-32, 32, 32);
        self.chatBtn.frame = CGRectMake(self.tabBar.width - 47 - 32, self.tabBar.height-33-32, 32, 32);
        self.exploreBtn.frame = CGRectMake((self.tabBar.width-78)/2.0, self.tabBar.height-78-70, 78, 78);
        self.beautyBtn.frame = CGRectMake((self.tabBar.width-36)/2.0, self.tabBar.height-36-12, 36, 36);
        self.beautyBtn.alpha = 1.0;
    }
}

- (void)setChatBtnImage
{
    if (self.chatBtn.selected) {
        [self.chatBtn setImage:[UIImage imageNamed:@"icon_message_chat_pressed"] forState:UIControlStateNormal];
    }
    else {
        if (haveUnread) {
            [self.chatBtn setImage:[UIImage imageNamed:@"icon_home_getmessage"] forState:UIControlStateNormal];
        }
        else {
            if (self.selectedIndex == 0) {
                [self.chatBtn setImage:[UIImage imageNamed:@"icon_me_chat_normal"] forState:UIControlStateNormal];
            }
            else if (self.selectedIndex == 1) {
                [self.chatBtn setImage:[UIImage imageNamed:@"icon_home_chat_normal"] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)selectIndex:(NSInteger)index
{
    noAnimationChange = YES;
    self.selectedIndex = index;
    [self selectedCustonBtn:YES];
}

#pragma mark - ScrollTabBarControllerDelete

- (void)tabBarControllerScrollAnimationStartFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSLog(@"tabBarControllerScrollAnimationStart");
    
    self.chatBtn.layer.timeOffset = 0.0;
    self.meBtn.layer.timeOffset = 0.0;
    self.exploreBtn.layer.timeOffset = 0.0;
    self.beautyBtn.layer.timeOffset = 0.0;
    
    self.chatBtn.layer.speed = 0.0;
    self.meBtn.layer.speed = 0.0;
    self.exploreBtn.layer.speed = 0.0;
    self.beautyBtn.layer.speed = 0.0;
    
    CFTimeInterval duration = 1.0;
    
    [self showOrHiddenBeauty:NO];
    
    if (fromIndex == 1) {
        if (!haveUnread) {
            [self.chatBtn setImage:[UIImage imageNamed:@"icon_me_chat_normal"] forState:UIControlStateNormal];
        }
        [self.meBtn setImage:[UIImage imageNamed:@"icon_message_me_norml"] forState:UIControlStateNormal];
        [self.exploreBtn setBackgroundImage:[UIImage imageNamed:@"icon_me_match_small"] forState:UIControlStateNormal];
    }
    
    CGPoint chatBtnPosition = CGPointZero;
    CGPoint meBtnPosition = CGPointZero;
    CGRect exploreBtnFrame = CGRectZero;
    CGFloat beautyBtnalpha = 1.0;
    CGPoint chatBtnPosition_old = CGPointZero;
    CGPoint meBtnPosition_old = CGPointZero;
    CGRect exploreBtnFrame_old = CGRectZero;
    CGFloat beautyBtnalpha_old = 1.0;
    chatBtnPosition_old = self.chatBtn.layer.position;
    meBtnPosition_old = self.meBtn.layer.position;
    exploreBtnFrame_old = self.exploreBtn.frame;
    beautyBtnalpha_old = self.beautyBtn.alpha;
    
    BOOL showAnimate = NO;
    if (toIndex == 1) {
        showAnimate = YES;
        meBtnPosition = CGPointMake(47+(32/2.0), self.tabBar.height-33-32+(32/2.0));
        chatBtnPosition = CGPointMake(self.tabBar.width - 47 - 32+(32/2.0), self.tabBar.height-33-32+(32/2.0));
        exploreBtnFrame = CGRectMake((self.tabBar.width-78)/2.0, self.tabBar.height-78-70, 78, 78);
        beautyBtnalpha = 1.0;
    }
    else if (fromIndex == 1) {
        showAnimate = YES;
        meBtnPosition = CGPointMake(85+(32/2.0), self.tabBar.height-25-32+(32/2.0));
        chatBtnPosition = CGPointMake(self.tabBar.width - 85 - 32+(32/2.0), self.tabBar.height-25-32+(32/2.0));
        exploreBtnFrame = CGRectMake((self.tabBar.width-50)/2.0, self.tabBar.height-50-18, 50, 50);
        beautyBtnalpha = 0.0;
    }
    
    if (showAnimate) {
        CABasicAnimation * chatAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        chatAnimation.duration = duration;
        chatAnimation.removedOnCompletion = NO;
        chatAnimation.fromValue = [NSValue valueWithCGPoint:chatBtnPosition_old];
        chatAnimation.toValue = [NSValue valueWithCGPoint:chatBtnPosition];
        
        CABasicAnimation * meAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        meAnimation.duration = duration;
        meAnimation.removedOnCompletion = NO;
        meAnimation.fromValue = [NSValue valueWithCGPoint:meBtnPosition_old];
        meAnimation.toValue = [NSValue valueWithCGPoint:meBtnPosition];
        
        CABasicAnimation *exploreAnimation1 = [CABasicAnimation animationWithKeyPath:@"position"];
        exploreAnimation1.fromValue = [NSNumber valueWithCGPoint:CGPointMake(exploreBtnFrame_old.origin.x+(exploreBtnFrame_old.size.width/2.0), exploreBtnFrame_old.origin.y+(exploreBtnFrame_old.size.height/2.0))];
        exploreAnimation1.toValue = [NSNumber valueWithCGPoint:CGPointMake(exploreBtnFrame.origin.x+(exploreBtnFrame.size.width/2.0), exploreBtnFrame.origin.y+(exploreBtnFrame.size.height/2.0))];
        
        CABasicAnimation * exploreAnimation2 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        exploreAnimation2.fromValue = [NSNumber valueWithCGRect:CGRectMake(0, 0, exploreBtnFrame_old.size.width, exploreBtnFrame_old.size.height)];
        exploreAnimation2.toValue = [NSNumber valueWithCGRect:CGRectMake(0, 0, exploreBtnFrame.size.width, exploreBtnFrame.size.height)];
        
        CABasicAnimation *exploreAnimation3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        exploreAnimation3.fromValue = [NSNumber numberWithFloat:1.0];
        exploreAnimation3.toValue = [NSNumber numberWithFloat:exploreBtnFrame.size.width/exploreBtnFrame_old.size.width];
        
        CAAnimationGroup *exploreGroup = [CAAnimationGroup animation];
        exploreGroup.duration = duration;
        exploreGroup.removedOnCompletion = NO;
        exploreGroup.animations = @[exploreAnimation1, exploreAnimation3];
        
        CABasicAnimation * beautyAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        beautyAnimation.duration = duration;
        beautyAnimation.removedOnCompletion = NO;
        beautyAnimation.fromValue = [NSNumber numberWithFloat:beautyBtnalpha_old];
        beautyAnimation.toValue = [NSNumber numberWithFloat:beautyBtnalpha];
        
        [self.chatBtn.layer addAnimation:chatAnimation forKey:@"chatAnimation"];
        [self.meBtn.layer addAnimation:meAnimation forKey:@"meAnimation"];
        [self.exploreBtn.layer addAnimation:exploreGroup forKey:@"exploreGroup"];
        [self.beautyBtn.layer addAnimation:beautyAnimation forKey:@"beautyAnimation"];
    }
}

- (void)tabBarControllerScrollAnimationProgress:(CGFloat)progress
{
    if ([self.chatBtn.layer animationKeys].count > 0) {
        NSLog(@"tabBarControllerScrollAnimationProgress- %f",progress);
        self.chatBtn.layer.timeOffset = progress;
        self.meBtn.layer.timeOffset = progress;
        self.exploreBtn.layer.timeOffset = progress;
        self.beautyBtn.layer.timeOffset = progress;
    }
}

- (void)tabBarControllerScrollAnimationCancel
{
    NSLog(@"tabBarControllerScrollAnimationCancel");
    [self.chatBtn.layer removeAllAnimations];
    [self.meBtn.layer removeAllAnimations];
    [self.exploreBtn.layer removeAllAnimations];
    [self.beautyBtn.layer removeAllAnimations];
    [self selectedCustonBtn:NO];
    self.chatBtn.layer.speed = 1.0;
    self.meBtn.layer.speed = 1.0;
    self.exploreBtn.layer.speed = 1.0;
    self.beautyBtn.layer.speed = 1.0;
}

- (void)tabBarControllerScrollAnimationFinished
{
    NSLog(@"tabBarControllerScrollAnimationFinished");
    [self.chatBtn.layer removeAllAnimations];
    [self.meBtn.layer removeAllAnimations];
    [self.exploreBtn.layer removeAllAnimations];
    [self.beautyBtn.layer removeAllAnimations];
    [self selectedCustonBtn:YES];
    self.chatBtn.layer.speed = 1.0;
    self.meBtn.layer.speed = 1.0;
    self.exploreBtn.layer.speed = 1.0;
    self.beautyBtn.layer.speed = 1.0;
}

#pragma mark - UITabBarControllerDelegate

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
