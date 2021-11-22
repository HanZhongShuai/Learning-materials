//
//  UITabBar+RCTabBar.m
//  iOSLivU
//
//  Created by HS on 2019/11/22.
//  Copyright © 2019 RC. All rights reserved.
//

#import "UITabBar+RCTabBar.h"
#import <objc/runtime.h>

@implementation UITabBar (RCTabBar)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGFloat area = self.clickArea;
    if (area > 0) {
        CGRect bounds = self.bounds;
        bounds.origin.y = -area;
        bounds.size.height = bounds.size.height+area;
        //点击的点在新的bounds 中 就会返回YES
        return CGRectContainsPoint(bounds, point);
    }
    else {
        return [super pointInside:point withEvent:event];
    }
    return NO;
}

- (void)setClickArea:(CGFloat)clickArea
{
    objc_setAssociatedObject(self, @selector(clickArea), [NSNumber numberWithDouble:clickArea], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)clickArea
{
    CGFloat area = 0;
    NSNumber *num = objc_getAssociatedObject(self, @selector(clickArea));
    if (num) {
        area = [num doubleValue];
    }
    return area;
}

@end
