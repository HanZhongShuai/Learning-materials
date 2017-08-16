//
//  RC_TagsListView.m
//  iOSLivU
//
//  Created by RC on 2017/8/16.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import "RC_TagsListView.h"

@interface RC_TagsListView ()

@property (nonatomic, assign) BOOL isBuildUI;

@property (nonatomic, strong) NSMutableArray<NSString *> *tagsList;

@property (nonatomic, strong) NSMutableArray<UILabel *> *tagsLabelList;

@property (nonatomic , assign) CGFloat tagsListWidth;

@property (nonatomic , assign) CGFloat tagsListHeight;

@end

@implementation RC_TagsListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self config];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config
{
    if (!self.tagColor) {
        self.tagColor = [UIColor colorWithRed:157/255.0 green:163/255.0 blue:168/255.0 alpha:1/1.0];
    }
    if (!self.tagBackgroundColor) {
        self.tagBackgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1/1.0];
    }
    if (!self.tagFont) {
        self.tagFont = [UIFont systemFontOfSize:14];
    }
    if (!self.borderColor) {
        self.borderColor = [UIColor clearColor];
    }
    
    if (self.tagMargin < 0) {
        self.tagMargin = 0;
    }
    if (self.tagMarginHorizontal <= 0) {
        self.tagMarginHorizontal = 17;
    }
    
    if (self.tagMarginVertical <= 0) {
        self.tagMarginVertical = 16;
    }
    if (self.tagHight <= 0) {
        self.tagHight = 20;
    }
    if (self.tagCornerRadius <= 0) {
        self.tagCornerRadius = 20/2.0;
    }
    if (self.borderWidth < 0) {
        self.borderWidth = 0.0;
    }
    if (self.tagContentMargin <= 0) {
        self.tagContentMargin = 15;
    }
    
    if (self.tagsListStr == nil || self.tagsListStr.length == 0) {
        self.tagsListHeight = self.tagMargin*2.0;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (([[UIScreen mainScreen] bounds].size.height == 480)) {
        self.tagFont = [UIFont systemFontOfSize:12];
        self.tagMarginHorizontal = 12;
        self.tagMarginVertical = 12;
        self.tagHight = 16;
        self.tagCornerRadius = 16/2.0;
        self.tagContentMargin = 10;
        if (self.tagsListStr == nil || self.tagsListStr.length == 0) {
            self.tagsListHeight = self.tagMargin*2.0;
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.isBuildUI) {
        self.isBuildUI = YES;
        self.tagsListWidth = self.frame.size.width;
        [self refreshTagsListView];
    }
    else if (self.tagsListWidth != self.frame.size.width) {
        self.tagsListWidth = self.frame.size.width;
        [self refreshTagsListView];
    }
}

#pragma mark - ContentSize

- (void)setTagsListHeight:(CGFloat)tagsListHeight
{
    if (self) {
        _tagsListHeight = tagsListHeight;
        [self invalidateIntrinsicContentSize];
        [self setNeedsDisplay];
    }
}

//通过覆盖intrinsicContentSize函数修改View的Intrinsic的大小

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.tagsListStr == nil || self.tagsListStr.length == 0) {
        return CGSizeZero;
    }
    
    CGFloat height = _tagsListHeight;
    if (height <= 0) {
        height = self.tagMargin*2.0;
    }
    return CGSizeMake([super sizeThatFits:size].width, height);
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:[super intrinsicContentSize]];
}

#pragma mark - setter  getter

- (void)setTagColor:(UIColor *)tagColor
{
    _tagColor = tagColor;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setTagBackgroundColor:(UIColor *)tagBackgroundColor
{
    _tagBackgroundColor = tagBackgroundColor;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setTagFont:(UIFont *)tagFont
{
    _tagFont = tagFont;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setTagMargin:(CGFloat)tagMargin
{
    if (tagMargin < 0) {
        tagMargin = 0;
    }
    
    _tagMargin = tagMargin;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setTagMarginHorizontal:(CGFloat)tagMarginHorizontal
{
    if (tagMarginHorizontal <= 0) {
        tagMarginHorizontal = 1;
    }
    
    _tagMarginHorizontal = tagMarginHorizontal;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setTagMarginVertical:(CGFloat)tagMarginVertical
{
    if (tagMarginVertical <= 0) {
        tagMarginVertical = 1;
    }
    _tagMarginVertical = tagMarginVertical;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setTagHight:(CGFloat)tagHight
{
    if (tagHight <= 0) {
        tagHight = 1;
    }
    _tagHight = tagHight;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setTagCornerRadius:(CGFloat)tagCornerRadius
{
    if (tagCornerRadius < 0) {
        tagCornerRadius = 0;
    }
    
    _tagCornerRadius = tagCornerRadius;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setBorderWidth:(CGFloat)borderWidth
{
    if (borderWidth < 0) {
        borderWidth = 0.0;
    }
    
    _borderWidth = borderWidth;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}
- (void)setTagContentMargin:(CGFloat)tagContentMargin
{
    if (tagContentMargin < 0) {
        tagContentMargin = 0;
    }
    
    _tagContentMargin = tagContentMargin;
    if (self.tagsListStr && self.tagsListStr.length > 0) {
        [self refreshTagsListView];
    }
}


- (void)setTagsListStr:(NSString *)tagsListStr
{
    if (tagsListStr == nil || tagsListStr.length == 0) {
        return;
    }
    NSArray *tags = [tagsListStr componentsSeparatedByString:@","];
    if (tags && tags.count > 0) {
        [self.tagsList removeAllObjects];
        for (NSString *tag in tags) {
            if (tag && tag.length > 0) {
                [self.tagsList addObject:tag];
            }
        }
        _tagsListStr = [self.tagsList componentsJoinedByString:@","];
        [self refreshTagsListView];
    }
}

- (NSMutableArray<NSString *> *)tagsList
{
    if (_tagsList == nil) {
        _tagsList = [[NSMutableArray alloc] init];
        if (_tagsListStr) {
            [_tagsList addObjectsFromArray:[_tagsListStr componentsSeparatedByString:@","]];
        }
    }
    return _tagsList;
}

- (NSMutableArray<UILabel *> *)tagsLabelList
{
    if (_tagsLabelList == nil) {
        _tagsLabelList = [[NSMutableArray alloc] init];
    }
    return _tagsLabelList;
}

#pragma mark - 添加tag

/**
 *  添加标签
 *
 *  @param tagStr 标签文字
 */
- (void)addTag:(NSString *)tagStr
{
    [self.tagsList removeAllObjects];
    [self.tagsList addObject:tagStr];
    _tagsListStr = tagStr;
    [self refreshTagsListView];
}

/**
 *  添加多个标签
 *
 *  @param tagStrs 标签数组，数组存放（NSString *）
 */
- (void)addTags:(NSArray<NSString *> *)tagStrs
{
    [self.tagsList removeAllObjects];
    [self.tagsList addObjectsFromArray:tagStrs];
    _tagsListStr = [self.tagsList componentsJoinedByString:@","];
    [self refreshTagsListView];
}

- (void)refreshTagsListView
{
    if (!self.isBuildUI) {
        return;
    }
    if (self.tagsList.count == 0) {
        if (self.tagsLabelList && self.tagsLabelList.count > 0) {
            for (NSInteger i = 0; i < self.tagsLabelList.count; i++) {
                UILabel *tagLabel = self.tagsLabelList[i];
                [tagLabel removeFromSuperview];
            }
        }
        return;
    }
    CGRect lastRect = CGRectMake(self.tagMargin, self.tagMargin, 0, self.tagHight);
    if (self.tagsLabelList.count > self.tagsList.count) {
        for (NSInteger i = 0; i < self.tagsLabelList.count; i++) {
            UILabel *tagLabel = self.tagsLabelList[i];
            if (i < self.tagsList.count) {
                NSString *tagStr = self.tagsList[i];
                CGFloat tagWidth = getTagLabelSizeWithTag(tagStr, self.tagFont)+(self.tagContentMargin*2.0);
                
                if (i != 0 && lastRect.origin.x+lastRect.size.width+tagWidth+self.tagMargin>self.frame.size.width) {
                    tagLabel.frame = CGRectMake(self.tagMargin, lastRect.origin.y+lastRect.size.height+self.tagMarginVertical, tagWidth, lastRect.size.height);
                }
                else if (i == 0) {
                    tagLabel.frame = CGRectMake(lastRect.origin.x, lastRect.origin.y, tagWidth, lastRect.size.height);
                }
                else {
                    tagLabel.frame = CGRectMake(lastRect.origin.x+lastRect.size.width+self.tagMarginHorizontal, lastRect.origin.y, tagWidth, lastRect.size.height);
                }
                
                tagLabel.text = tagStr;
                [self addSubview:tagLabel];
                
                lastRect = tagLabel.frame;
            }
            else {
                [tagLabel removeFromSuperview];
            }
        }
    }
    else {
        for (NSInteger i = 0; i < self.tagsList.count; i++) {
            NSString *tagStr = self.tagsList[i];
            UILabel *tagLabel = nil;
            if (i < self.tagsLabelList.count) {
                tagLabel = self.tagsLabelList[i];
            }
            else {
                tagLabel = [[UILabel alloc] init];
                tagLabel.textAlignment = NSTextAlignmentCenter;
                tagLabel.textColor = self.tagColor;
                tagLabel.backgroundColor = self.tagBackgroundColor;
                tagLabel.font = self.tagFont;
                tagLabel.layer.cornerRadius = self.tagCornerRadius;
                tagLabel.layer.borderWidth = self.borderWidth;
                tagLabel.layer.borderColor = self.borderColor.CGColor;
                tagLabel.layer.masksToBounds = YES;
                [self.tagsLabelList addObject:tagLabel];
            }
            
            CGFloat tagWidth = getTagLabelSizeWithTag(tagStr, self.tagFont)+(self.tagContentMargin*2.0);
            if (i != 0 && lastRect.origin.x+lastRect.size.width+tagWidth+self.tagMargin>self.frame.size.width) {
                tagLabel.frame = CGRectMake(self.tagMargin, lastRect.origin.y+lastRect.size.height+self.tagMarginVertical, tagWidth, lastRect.size.height);
            }
            else if (i == 0) {
                tagLabel.frame = CGRectMake(lastRect.origin.x, lastRect.origin.y, tagWidth, lastRect.size.height);
            }
            else {
                tagLabel.frame = CGRectMake(lastRect.origin.x+lastRect.size.width+self.tagMarginHorizontal, lastRect.origin.y, tagWidth, lastRect.size.height);
            }
            
            tagLabel.text = tagStr;
            [self addSubview:tagLabel];
            
            lastRect = tagLabel.frame;
        }
    }
    self.tagsListHeight = lastRect.origin.y+lastRect.size.height+self.tagMargin;
}

CGFloat getTagLabelSizeWithTag(NSString *tag ,UIFont *font)
{
    CGSize size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    
    CGRect returnRect = [tag boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil];
    
    return returnRect.size.width;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
