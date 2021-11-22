//
//  RC_TabBarController.h
//  iOSGetFollow
//
//  Created by TCH on 15/6/18.
//  Copyright (c) 2015年 com.rcplatform. All rights reserved.
//

#import "ScrollTabBarController.h"

@interface RC_TabBarController : UITabBarController

@property (nonatomic, assign) BOOL isLayoutDirectionRightToLeft;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

//默认无动画
-(void)selectIndex:(NSInteger)index;

-(void)mePageDotTipsHidden:(BOOL)hidden;

@end
