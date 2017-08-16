//
//  RC_TagsListView.h
//  iOSLivU
//
//  Created by RC on 2017/8/16.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface RC_TagsListView : UIView

/**
 *  和距离左，上间距,默认10
 */
@property (nonatomic, assign) CGFloat tagMargin;

/**
 *  标签间距,水平,默认10
 */
@property (nonatomic, assign) IBInspectable CGFloat tagMarginHorizontal;

/**
 *  标签间距,竖直,默认10
 */
@property (nonatomic, assign) IBInspectable CGFloat tagMarginVertical;

/**
 *  标签颜色，默认灰色
 */
@property (nonatomic, strong) IBInspectable UIColor *tagColor;

/**
 *  标签背景颜色
 */
@property (nonatomic, strong) IBInspectable UIColor *tagBackgroundColor;

/**
 *  标签字体，默认12
 */
@property (nonatomic, assign) IBInspectable UIFont *tagFont;

/**
 *  标签的高度
 */
@property (nonatomic, assign) IBInspectable CGFloat tagHight;

/**
 *  标签圆角半径,默认为5
 */
@property (nonatomic, assign) IBInspectable CGFloat tagCornerRadius;

/**
 *  边框宽度
 */
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

/**
 *  边框颜色
 */
@property (nonatomic, strong) IBInspectable UIColor *borderColor;

/**
 *  标签按钮内容间距，标签内容距离左右间距，默认5
 */
@property (nonatomic, assign) IBInspectable CGFloat tagContentMargin;

/**
 *  所有标签(字符串形式 用 , 分割)
 */
@property (nonatomic, copy) IBInspectable NSString *tagsListStr;

/**
 *  获取所有标签
 */
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *tagsList;

/**
 *  添加标签
 *
 *  @param tagStr 标签文字
 */
- (void)addTag:(NSString *)tagStr;

/**
 *  添加多个标签
 *
 *  @param tagStrs 标签数组，数组存放（NSString *）
 */
- (void)addTags:(NSArray<NSString *> *)tagStrs;

@end
