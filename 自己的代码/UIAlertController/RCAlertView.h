//
//  RCAlertView.h
//  iOSLivU
//
//  Created by HS on 2019/4/12.
//  Copyright © 2019 RC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCAlertViewDelegate;

NS_CLASS_AVAILABLE_IOS(8_0) @interface RCAlertView : UIAlertController

+ (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id /*<RCAlertViewDelegate>*/)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@property(nullable,nonatomic,weak) id /*<RCAlertViewDelegate>*/ delegate;

@property(nonatomic,readonly) NSInteger numberOfButtons;
@property(nonatomic,readonly) NSInteger cancelButtonIndex;      // if the delegate does not implement -alertViewCancel:, we pretend this button was clicked on. default is -1

@property(nonatomic,readonly) NSInteger firstOtherButtonIndex;    // -1 if no otherButtonTitles or initWithTitle:... not used

@property(nonatomic)                                 NSInteger tag;                // default is 0

// shows popup alert animated.
- (void)show;
- (void)showInController:(UIViewController *)controller;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end

@protocol RCAlertViewDelegate <NSObject>

@optional
- (void)alertView:(RCAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

NS_ASSUME_NONNULL_END
