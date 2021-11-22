//
//  RCActionSheet.h
//  iOSLivU
//
//  Created by HS on 2019/4/12.
//  Copyright © 2019 RC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCActionSheetDelegate;

NS_CLASS_AVAILABLE_IOS(8_0) @interface RCActionSheet : UIAlertController

+ (instancetype)initWithTitle:(nullable NSString *)title delegate:(nullable id<RCActionSheetDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@property(nullable,nonatomic,weak) id <RCActionSheetDelegate> delegate;

@property(nonatomic,readonly) NSInteger numberOfButtons;
@property(nonatomic,readonly) NSInteger cancelButtonIndex;      // if the delegate does not implement -alertViewCancel:, we pretend this button was clicked on. default is -1

@property(nonatomic,readonly) NSInteger firstOtherButtonIndex;    // -1 if no otherButtonTitles or initWithTitle:... not used
@property(nonatomic,readonly) NSInteger destructiveButtonIndex;        // sets destructive (red) button. -1 means none set. default is -1. ignored if only one button

@property(nonatomic)                                 NSInteger tag;                // default is 0

// shows popup alert animated.
- (void)show;
- (void)showInController:(UIViewController *)controller;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end

@protocol RCActionSheetDelegate <NSObject>

@optional
- (void)actionSheet:(RCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

NS_ASSUME_NONNULL_END
