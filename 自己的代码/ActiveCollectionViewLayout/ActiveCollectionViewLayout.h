//
//  ActiveCollectionViewLayout.h
//  iOSVideoChat
//
//  Created by RC on 2017/4/25.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveCollectionViewLayout : UICollectionViewLayout

/** 保存当前section的边距 */
@property (nonatomic,assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) CGFloat lineSpace;

@end
