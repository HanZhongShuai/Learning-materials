//
//  RC_TabBarController.h
//  iOSGetFollow
//
//  Created by TCH on 15/6/18.
//  Copyright (c) 2015年 com.rcplatform. All rights reserved.
//

#import "ScrollTabBarController.h"

@interface RC_TabBarController : ScrollTabBarController

@property (nonatomic, strong) UIButton *chatBtn;
@property (nonatomic, strong) UIButton *meBtn;
@property (nonatomic, strong) UIButton *exploreBtn;
@property (nonatomic, strong) UIButton *beautyBtn;

-(void)selectIndex:(NSInteger)index;

@end
