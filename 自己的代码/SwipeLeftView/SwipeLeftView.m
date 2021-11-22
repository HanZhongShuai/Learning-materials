//
//  SwipeLeftView.m
//  iOSLivU
//
//  Created by Blues on 2017/11/24.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import "SwipeLeftView.h"


@interface SwipeLeftView ()

@property (nonatomic, assign) BOOL isBuildUI;


@end

@implementation SwipeLeftView



- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_isBuildUI) {
        [self buildUI];
        _isBuildUI = YES;
    }
}


- (void)buildUI
{
    UILabel *swipeLbl = [[UILabel alloc] init];
    [swipeLbl setFont:[UIFont fontWithName:FontNameMedium size:15.f]];
    [swipeLbl setTextColor:[UIColor whiteColor]];
    [swipeLbl setTextAlignment:NSTextAlignmentNatural];
    swipeLbl.numberOfLines = 0;
    [self addSubview:swipeLbl];
    
    
    UIImageView *swipeImgView = [[UIImageView alloc] init];
    [swipeImgView setImage:[UIImage imageNamed:@"pic_video_switch"]];
    swipeImgView.contentMode = UIViewContentModeCenter;
    [self addSubview:swipeImgView];
    
    
    NSString *swipeContent = NSLocalizedString(@"tabExplore_swipeNext", nil);
    
    CGSize contentSize = getTextLabelRectWithContentAndFont(swipeContent, [UIFont fontWithName:FontNameMedium size:15.f]);
    
    contentSize = getTextLabelRect(swipeContent, [UIFont fontWithName:FontNameMedium size:15.f], ScreenWidth-60, CGFLOAT_MAX);
    
    [swipeLbl setText:swipeContent];

        
    [swipeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-18.8f);
        make.top.equalTo(self);
        make.width.height.mas_equalTo(38.5f);
    }];

    [swipeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(contentSize.height);
        make.width.mas_equalTo(contentSize.width+10);
        make.right.equalTo(swipeImgView.mas_left);
        make.centerY.equalTo(swipeImgView.mas_centerY);
    }];
    
    [swipeLbl sizeToFit];
    
}


- (void)showAnimate{
    CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animate.toValue = @0;
    animate.repeatCount = HUGE_VALF;
    animate.duration = 0.8f;
    animate.autoreverses=YES;
    animate.removedOnCompletion=NO;
    
    [self.layer addAnimation:animate forKey:@"animate"];
}

- (void)stopAnimate{
    [self.layer removeAnimationForKey:@"animate"];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
