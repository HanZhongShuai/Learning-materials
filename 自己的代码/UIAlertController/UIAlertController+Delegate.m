//
//  UIAlertController+Delegate.m
//  iOSLivU
//
//  Created by HS on 2019/4/11.
//  Copyright © 2019 RC. All rights reserved.
//

#import "UIAlertController+Delegate.h"
#import <objc/runtime.h>

static char UIAlertControllerDelegateObject;
static char UIAlertControllerTag;

@implementation UIAlertController (Delegate)

+ (instancetype)alertControllerWithType:(UIAlertControllerStyle)type title:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id <UIAlertControllerDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:type];
    
    NSMutableArray *actionTitleArr = [[NSMutableArray alloc] init];
    
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
    {
        //do something with nsstring
        if (arg && [arg isKindOfClass:[NSString class]]) {
            [actionTitleArr addObject:arg];
        }
    }
    va_end(args);
    
    [alert setDelegate:delegate];
    
    __weak typeof(alert)weakAlert = alert;
    if (cancelButtonTitle && cancelButtonTitle.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (weakAlert) {
                [weakAlert clickedButtonWithAction:action];
            }
        }];
        [alert addAction:cancelAction];
    }
    
    for (NSInteger i = 0; i < actionTitleArr.count; i++) {
        NSString *title = actionTitleArr[i];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (weakAlert) {
                [weakAlert clickedButtonWithAction:action];
            }
        }];
        [alert addAction:otherAction];
    }
    
    return alert;
}

+ (instancetype)alertControllerWithType:(UIAlertControllerStyle)type title:(nullable NSString *)title delegate:(nullable id<UIAlertControllerDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:type];
    
    NSMutableArray *actionTitleArr = [[NSMutableArray alloc] init];
    
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
    {
        //do something with nsstring
        if (arg && [arg isKindOfClass:[NSString class]]) {
            [actionTitleArr addObject:arg];
        }
    }
    va_end(args);
    
    [alert setDelegate:delegate];
    
    __weak typeof(alert)weakAlert = alert;
    if (cancelButtonTitle && cancelButtonTitle.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (weakAlert) {
                [weakAlert clickedButtonWithAction:action];
            }
        }];
        [alert addAction:cancelAction];
    }
    
    if (destructiveButtonTitle && destructiveButtonTitle.length > 0) {
        UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            if (weakAlert) {
                [weakAlert clickedButtonWithAction:action];
            }
        }];
        [alert addAction:destructiveAction];
    }
    
    for (NSInteger i = 0; i < actionTitleArr.count; i++) {
        NSString *title = actionTitleArr[i];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (weakAlert) {
                [weakAlert clickedButtonWithAction:action];
            }
        }];
        [alert addAction:otherAction];
    }
    
    return alert;
}

- (void)clickedButtonWithAction:(UIAlertAction *)action
{
    if (self.delegate) {
        NSInteger index = [self.actions indexOfObject:action];
        [self.delegate alertController:self clickedButtonAtIndex:index];
    }
}

#pragma mark - setter  getter

- (void)setDelegate:(id<UIAlertControllerDelegate>)delegate
{
    if (delegate && [delegate respondsToSelector:@selector(alertController:clickedButtonAtIndex:)]) {
        objc_setAssociatedObject(self, &UIAlertControllerDelegateObject,
                                 delegate, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (id<UIAlertControllerDelegate>)delegate
{
    id<UIAlertControllerDelegate> del = objc_getAssociatedObject(self, &UIAlertControllerDelegateObject);
    return del;
}

- (void)setTag:(NSInteger)tag
{
    NSNumber *tagNum = [NSNumber numberWithInteger:tag];
    objc_setAssociatedObject(self, &UIAlertControllerTag,
                             tagNum, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tag
{
    NSNumber *tagNum = objc_getAssociatedObject(self, &UIAlertControllerTag);
    if (tagNum) {
        return tagNum.integerValue;
    }
    return 0;
}

- (NSInteger)numberOfButtons
{
    return self.actions.count;
}

- (NSInteger)cancelButtonIndex
{
    NSInteger index = -1;
    for (NSInteger i = 0; i < self.actions.count; i++) {
        UIAlertAction *action = self.actions[i];
        if (action.style == UIAlertActionStyleCancel) {
            index = i;
            break;
        }
    }
    return index;
}

- (NSInteger)firstOtherButtonIndex
{
    NSInteger index = -1;
    for (NSInteger i = 0; i < self.actions.count; i++) {
        UIAlertAction *action = self.actions[i];
        if (action.style == UIAlertActionStyleDefault) {
            index = i;
            break;
        }
    }
    return index;
}

- (NSInteger)destructiveButtonIndex
{
    NSInteger index = -1;
    for (NSInteger i = 0; i < self.actions.count; i++) {
        UIAlertAction *action = self.actions[i];
        if (action.style == UIAlertActionStyleDestructive) {
            index = i;
            break;
        }
    }
    return index;
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window && window.rootViewController) {
        UIViewController *presentVC = window.rootViewController;
        while (presentVC.presentedViewController) {
            presentVC = presentVC.presentedViewController;
        }
        [presentVC presentViewController:self animated:YES completion:nil];
    }
}

- (void)showInController:(UIViewController *)controller
{
    if (controller) {
        [controller presentViewController:self animated:YES completion:nil];
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (self.delegate) {
        [self.delegate alertController:self clickedButtonAtIndex:buttonIndex];
    }
    [self dismissViewControllerAnimated:animated completion:nil];
}

@end
