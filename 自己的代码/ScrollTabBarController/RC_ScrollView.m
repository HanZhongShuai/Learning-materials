//
//  RC_ScrollView.m
//  iOSUseHeart
//
//  Created by TCH on 16/5/16.
//  Copyright © 2016年 TCH. All rights reserved.
//

#import "RC_ScrollView.h"

@interface RC_ScrollView ()<UIGestureRecognizerDelegate>

@end

@implementation RC_ScrollView

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (gestureRecognizer.state != 0) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    if (self.tabBar.hidden || (oldIndex != self.selectedIndex)) {
//        return NO;
//    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        return NO;
    }
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
