//
//  RCAlertView.m
//  iOSLivU
//
//  Created by HS on 2019/4/12.
//  Copyright © 2019 RC. All rights reserved.
//

#import "RCAlertView.h"

@interface RCAlertView ()

@property(nonatomic) NSInteger cancelButtonIndex;

@property(nonatomic) NSInteger firstOtherButtonIndex;

@end

@implementation RCAlertView

+ (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<RCAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
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
    
    RCAlertView *alertView = [RCAlertView alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    alertView.delegate = delegate;
    alertView.cancelButtonIndex = -2;
    alertView.firstOtherButtonIndex = -2;
    [alertView configActionWithCancelButtonTitle:cancelButtonTitle otherButtonTitles:actionTitleArr];
    return alertView;
}

- (void)configActionWithCancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray <NSString *>*)otherButtonTitles
{
    __weak typeof(self)weakSelf = self;
    if (cancelButtonTitle && cancelButtonTitle.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (weakSelf) {
                [weakSelf clickedButtonWithAction:action];
            }
        }];
        [self addAction:cancelAction];
    }
    
    for (NSInteger i = 0; i < otherButtonTitles.count; i++) {
        NSString *title = otherButtonTitles[i];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (weakSelf) {
                [weakSelf clickedButtonWithAction:action];
            }
        }];
        [self addAction:otherAction];
    }
    
    _cancelButtonIndex = -1;
    _firstOtherButtonIndex = -1;
    
    for (NSInteger i = 0; i < self.actions.count; i++) {
        UIAlertAction *action = self.actions[i];
        if (action.style == UIAlertActionStyleCancel) {
            if (_cancelButtonIndex == -1) {
                _cancelButtonIndex = i;
            }
        }
        else if (action.style == UIAlertActionStyleDefault) {
            if (_firstOtherButtonIndex == -1) {
                _firstOtherButtonIndex = i;
            }
        }
    }
}

- (void)clickedButtonWithAction:(UIAlertAction *)action
{
    if (self.delegate) {
        NSInteger index = [self.actions indexOfObject:action];
        [self.delegate alertView:self clickedButtonAtIndex:index];
    }
}

#pragma mark - setter  getter

- (void)setDelegate:(id)delegate
{
    if (delegate && [delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        _delegate = delegate;
    }
}

- (NSInteger)numberOfButtons
{
    return self.actions.count;
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
        [self.delegate alertView:self clickedButtonAtIndex:buttonIndex];
    }
    [self dismissViewControllerAnimated:animated completion:nil];
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
