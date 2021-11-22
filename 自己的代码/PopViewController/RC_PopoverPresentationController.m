//
//  RC_PopoverPresentationController.m
//  iOSLivU
//
//  Created by HS on 2020/9/7.
//  Copyright © 2020 RC. All rights reserved.
//

#import "RC_PopoverPresentationController.h"
#import "RC_PopoverBackgroundView.h"

@interface RC_PopoverPresentationController () <UIPopoverPresentationControllerDelegate>

@end

@implementation RC_PopoverPresentationController

- (instancetype)initWithSourceView:(UIView*)sourceView contentSize:(CGSize)size
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.preferredContentSize = size;
        self.popoverPresentationController.sourceView = sourceView;
        self.popoverPresentationController.sourceRect = sourceView.bounds;
//        self.tableViewSize = size;
        self.popoverPresentationController.canOverlapSourceViewRect = YES;
        self.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        self.popoverPresentationController.backgroundColor = [UIColor redColor];
        self.popoverPresentationController.popoverBackgroundViewClass = [RC_PopoverBackgroundView class];
        self.popoverPresentationController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.popoverPresentationController.backgroundColor = [UIColor redColor];    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.popoverPresentationController.backgroundColor = [UIColor redColor];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (self.presentingViewController || self.presentedViewController) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
    else {
        [super dismissViewControllerAnimated:flag completion:completion];
        [self.view removeFromSuperview];
    }
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
