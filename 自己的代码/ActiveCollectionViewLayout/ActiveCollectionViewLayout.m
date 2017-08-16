//
//  ActiveCollectionViewLayout.m
//  iOSVideoChat
//
//  Created by RC on 2017/4/25.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import "ActiveCollectionViewLayout.h"

static const NSInteger unionSize = 10;

@interface ActiveCollectionViewLayout()

@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// Array to store union rectangles
@property (nonatomic, strong) NSMutableArray *unionRects;

/** 保存attribute */
@property (nonatomic,strong) NSMutableArray * attributes;
/** 保存每列的最大高度 */
@property (nonatomic,strong) NSMutableArray * eachLineHight;

@end

@implementation ActiveCollectionViewLayout

#pragma mark - 懒加载
- (NSMutableArray *)attributes {
    if (_attributes == nil) {
        _attributes = [NSMutableArray new];
    }
    return _attributes;
}

- (NSMutableArray *)unionRects {
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}
- (NSMutableArray *)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

- (NSMutableArray *)eachLineHight {
    if (_eachLineHight == nil) {
        _eachLineHight = [NSMutableArray array];
        for (int i = 0; i < 2; i++) {
            [_eachLineHight addObject:@(self.sectionInset.top)];
        }
    }
    return _eachLineHight;
}

#pragma mark - 系统方法

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.lineSpace = 2.0;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    // 重置每列的高度
    self.eachLineHight = nil;
    [self.attributes removeAllObjects];
    [self.unionRects removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    
    NSInteger section = [self.collectionView numberOfSections];
    for (NSInteger i = 0; i < section; i++) {
        
        NSInteger items = [self.collectionView numberOfItemsInSection:i];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:items];
        if (i == 0) {
            // 计算当前section的每个cell的frame
            for (NSInteger h = 0; h < items; h++) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:h inSection:i];
                UICollectionViewLayoutAttributes * attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                CGFloat W = self.collectionView.frame.size.width;
                CGFloat H = 60.0/375.0*W;
                attribute.frame = CGRectMake(0, h*H, W, H);
                [itemAttributes addObject:attribute];
                [self.allItemAttributes addObject:attribute];
                self.eachLineHight[0] = @(H);
                self.eachLineHight[1] = @(H);
            }
        }
        else {
            // 计算当前section的每个cell的frame
            for (NSInteger j = 0; j < items; j++) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:j inSection:i];
                UICollectionViewLayoutAttributes * attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];;
                attribute.frame = [self getFrameWithIndex:indexPath.item];
                [itemAttributes addObject:attribute];
                [self.allItemAttributes addObject:attribute];
            }
        }
        [self.attributes addObject:itemAttributes];
    }
    
    NSInteger idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    if (path.section >= [self.attributes count]) {
        return nil;
    }
    if (path.item >= [self.attributes[path.section] count]) {
        return nil;
    }
    return (self.attributes[path.section])[path.item];
}

/**
 *  返回特定区域的attribute
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    for (i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}

/**
 *  返回scrollView的contentSize
 */
- (CGSize)collectionViewContentSize {
    
    // 判断最高的一列
    CGFloat longest = 0;
    for (NSInteger i = 0; i < self.eachLineHight.count; i++) {
        CGFloat temp = [self.eachLineHight[i] floatValue];
        if (temp > longest) {
            longest = temp;
        }
    }
    
    return CGSizeMake(self.collectionView.frame.size.width, longest + self.sectionInset.bottom);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}


- (CGRect)getFrameWithIndex:(NSInteger)index
{
    // 计算attribute的frame
    CGFloat X = self.sectionInset.left;
    CGFloat Y = 0;
    CGFloat W = 0;
    
    // 判断最短的一类
    CGFloat shortest = CGFLOAT_MAX;
    for (NSInteger i = 0; i < 2 ; i++) {
        CGFloat temp = [self.eachLineHight[i] floatValue];
        if (temp < shortest) {
            shortest = temp;
        }
    }
    
    if (shortest > self.sectionInset.top + self.lineSpace) {
        shortest = shortest + self.lineSpace;
    }
    
    Y = shortest;
    
    // 根据概率生成cell的高度
    NSInteger type = index%10;
    if (type == 1 || type == 2) {
        X = X + [self getCellWidth:1] + self.lineSpace;
    }
    else if (type == 6) {
        X = X + [self getCellWidth:2] + self.lineSpace;
    }
    else if (type == 4 || type == 9) {
        X = X + [self getCellWidth:0] + self.lineSpace;
    }
    
    if (type == 0 || type == 6) {
        W = [self getCellWidth:1];
    }
    else if (type == 3 || type == 4 || type == 8 || type == 9) {
        W = [self getCellWidth:0];
    }
    else {
        W = [self getCellWidth:2];
    }
    
    if (X > self.sectionInset.left) {
        self.eachLineHight[1] = @(shortest + W);
    }
    else {
        self.eachLineHight[0] = @(shortest + W);
    }
    return CGRectMake(X, Y, W, W);
}

- (CGFloat)getCellWidth:(NSInteger)widthType
{
    //0 等分宽度  1 不等分宽度中大的  2 不等分宽度中小的
    CGFloat collectionWidth = self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right;
    CGFloat resultWidth = collectionWidth/2.0;
    if (widthType == 1) {
        resultWidth = collectionWidth/3.0*2.0-(self.lineSpace/3.0);
    }
    else if (widthType == 2) {
        resultWidth = (collectionWidth - (self.lineSpace*2.0))/3.0;
    }
    return resultWidth;
}

@end
