//
//  HSPopoverView.m
//  iOSLivU
//
//  Created by HS on 2020/9/8.
//  Copyright © 2020 RC. All rights reserved.
//

#import "HSPopoverView.h"
#import "QMUICommonDefines.h"

@interface HSPopoverView ()
{
    CALayer         *_arrowImageLayer;
    CGFloat         _arrowMinX;
    CGFloat         _arrowMinY;
}

@property(nonatomic, assign) CGFloat borderWidth;
@property(nonatomic, assign) CGFloat cornerRadius;

@property(nonatomic, strong) UIView *contentView;
/// 圆角矩形气泡内的padding（不包括三角箭头），默认是(8, 8, 8, 8)
@property(nonatomic, assign) UIEdgeInsets contentEdgeInsets;

@end

@implementation HSPopoverView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithSourceView:(UIView*)sourceView contentSize:(CGSize)size
{
    self = [super init];
    if (self) {
        self.contentSize = size;
        self.sourceView = sourceView;
        self.sourceRect = sourceView.bounds;
        self.frame = CGRectMake(0, 0, self.contentSize.width+[self arrowSpacingInHorizontal]+self.contentEdgeInsets.left+self.contentEdgeInsets.right, self.contentSize.height+[self arrowSpacingInHorizontal]+self.contentEdgeInsets.top+self.contentEdgeInsets.bottom);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.borderWidth = 0;
        self.cornerRadius = 8;
        self.contentEdgeInsets = [[self class] contentViewInsets];
        self.backgroundColor = [UIColor clearColor];
        
        if ([self.layer isKindOfClass:[CAShapeLayer class]]) {
            [(CAShapeLayer *)self.layer setFillColor:[UIColor whiteColor].CGColor];
        }
        _contentView = [[UIView alloc] init];
        self.contentView.clipsToBounds = YES;
        [self addSubview:self.contentView];
    }
    return self;
}

- (BOOL)isHorizontalLayoutDirection {
    return ((self.arrowDirection == UIPopoverArrowDirectionLeft) || (self.arrowDirection == UIPopoverArrowDirectionRight));
}

- (BOOL)isVerticalLayoutDirection {
    return ((self.arrowDirection == UIPopoverArrowDirectionUp) || (self.arrowDirection == UIPopoverArrowDirectionDown));
}

// self.arrowSize 规定的是上下箭头的宽高，如果 tip 布局在左右的话，arrowSize 的宽高则调转
- (CGSize)arrowSizeAuto {
    return self.isHorizontalLayoutDirection ? CGSizeMake([[self class] arrowHeight], [[self class] arrowBase]) : CGSizeMake([[self class] arrowBase], [[self class] arrowHeight]);
}

- (CGFloat)arrowSpacingInHorizontal {
    return self.isHorizontalLayoutDirection ? self.arrowSizeAuto.width : 0;
}

- (CGFloat)arrowSpacingInVertical {
    return self.isVerticalLayoutDirection ? self.arrowSizeAuto.height : 0;
}

- (UIEdgeInsets)safetyMarginsAvoidSafeAreaInsets {
    UIEdgeInsets result = UIEdgeInsetsMake(10, 10, 10, 10);
    UIEdgeInsets superSafeAreaInsets = UIEdgeInsetsZero;
    if (self.superview) {
        if (@available(iOS 11.0, *))
            superSafeAreaInsets = self.safeAreaInsets;
    }
    
    if (self.isHorizontalLayoutDirection) {
        result.left += superSafeAreaInsets.left;
        result.right += superSafeAreaInsets.right;
    } else {
        result.top += superSafeAreaInsets.top;
        result.bottom += superSafeAreaInsets.bottom;
    }
    return result;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    BOOL isUsingArrowImage = _arrowImageLayer && !_arrowImageLayer.hidden;
    CGAffineTransform arrowImageTransform = CGAffineTransformIdentity;
    CGPoint arrowImagePosition = CGPointZero;
    
    CGSize arrowSize = self.arrowSizeAuto;
    CGRect roundedRect = CGRectMake(self.borderWidth / 2.0 + ((self.arrowDirection == UIPopoverArrowDirectionLeft) ? arrowSize.width : 0),
                                    self.borderWidth / 2.0 + ((self.arrowDirection == UIPopoverArrowDirectionUp) ? arrowSize.height : 0),
                                    CGRectGetWidth(self.bounds) - self.borderWidth - self.arrowSpacingInHorizontal,
                                    CGRectGetHeight(self.bounds) - self.borderWidth - self.arrowSpacingInVertical);
    CGFloat cornerRadius = self.cornerRadius;
    
    CGPoint leftTopArcCenter = CGPointMake(CGRectGetMinX(roundedRect) + cornerRadius, CGRectGetMinY(roundedRect) + cornerRadius);
    CGPoint leftBottomArcCenter = CGPointMake(leftTopArcCenter.x, CGRectGetMaxY(roundedRect) - cornerRadius);
    CGPoint rightTopArcCenter = CGPointMake(CGRectGetMaxX(roundedRect) - cornerRadius, leftTopArcCenter.y);
    CGPoint rightBottomArcCenter = CGPointMake(rightTopArcCenter.x, leftBottomArcCenter.y);
    
    // 从左上角逆时针绘制
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(leftTopArcCenter.x, CGRectGetMinY(roundedRect))];
    [path addArcWithCenter:leftTopArcCenter radius:cornerRadius startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];
    
    if (self.arrowDirection == UIPopoverArrowDirectionLeft) {
        // 箭头向左
        if (isUsingArrowImage) {
            arrowImageTransform = CGAffineTransformMakeRotation(AngleWithDegrees(90));
            arrowImagePosition = CGPointMake(arrowSize.width / 2, _arrowMinY + arrowSize.height / 2);
        } else {
            [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), _arrowMinY)];
            [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect) - arrowSize.width, _arrowMinY + arrowSize.height / 2)];
            [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), _arrowMinY + arrowSize.height)];
        }
    }
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), leftBottomArcCenter.y)];
    [path addArcWithCenter:leftBottomArcCenter radius:cornerRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
    
    if (self.arrowDirection == UIPopoverArrowDirectionDown) {
        // 箭头向下
        if (isUsingArrowImage) {
            arrowImagePosition = CGPointMake(_arrowMinX + arrowSize.width / 2, CGRectGetHeight(self.bounds) - arrowSize.height / 2);
        } else {
            [path addLineToPoint:CGPointMake(_arrowMinX, CGRectGetMaxY(roundedRect))];
            [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width / 2, CGRectGetMaxY(roundedRect) + arrowSize.height)];
            [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width, CGRectGetMaxY(roundedRect))];
        }
    }
    
    [path addLineToPoint:CGPointMake(rightBottomArcCenter.x, CGRectGetMaxY(roundedRect))];
    [path addArcWithCenter:rightBottomArcCenter radius:cornerRadius startAngle:M_PI * 0.5 endAngle:0.0 clockwise:NO];
    
    if (self.arrowDirection == UIPopoverArrowDirectionRight) {
        // 箭头向右
        if (isUsingArrowImage) {
            arrowImageTransform = CGAffineTransformMakeRotation(AngleWithDegrees(-90));
            arrowImagePosition = CGPointMake(CGRectGetWidth(self.bounds) - arrowSize.width / 2, _arrowMinY + arrowSize.height / 2);
        } else {
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), _arrowMinY + arrowSize.height)];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect) + arrowSize.width, _arrowMinY + arrowSize.height / 2)];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), _arrowMinY)];
        }
    }
    
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), rightTopArcCenter.y)];
    [path addArcWithCenter:rightTopArcCenter radius:cornerRadius startAngle:0.0 endAngle:M_PI * 1.5 clockwise:NO];
    
    if (self.arrowDirection == UIPopoverArrowDirectionUp) {
        // 箭头向上
        if (isUsingArrowImage) {
            arrowImageTransform = CGAffineTransformMakeRotation(AngleWithDegrees(-180));
            arrowImagePosition = CGPointMake(_arrowMinX + arrowSize.width / 2, arrowSize.height / 2);
        } else {
            [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width, CGRectGetMinY(roundedRect))];
            [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width / 2, CGRectGetMinY(roundedRect) - arrowSize.height)];
            [path addLineToPoint:CGPointMake(_arrowMinX, CGRectGetMinY(roundedRect))];
        }
    }
    [path closePath];
    
    if ([self.layer isKindOfClass:[CAShapeLayer class]]) {
        [(CAShapeLayer *)self.layer setPath:path.CGPath];
    }
    self.layer.shadowPath = path.CGPath;
    
    if (isUsingArrowImage) {
        _arrowImageLayer.affineTransform = arrowImageTransform;
        _arrowImageLayer.position = arrowImagePosition;
    }
    
    [self layoutDefaultSubviews];
}

- (void)layoutDefaultSubviews {
    self.contentView.frame = CGRectMake(
                                        self.borderWidth + self.contentEdgeInsets.left + (self.arrowDirection == UIPopoverArrowDirectionLeft ? self.arrowSizeAuto.width : 0),
                                        self.borderWidth + self.contentEdgeInsets.top + (self.arrowDirection == UIPopoverArrowDirectionUp ? self.arrowSizeAuto.height : 0),
                                        CGRectGetWidth(self.bounds) - self.borderWidth * 2 - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) - self.arrowSpacingInHorizontal,
                                        CGRectGetHeight(self.bounds) - self.borderWidth * 2 - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) - self.arrowSpacingInVertical);
    // contentView的圆角取一个比整个path的圆角小的最大值（极限情况下如果self.contentEdgeInsets.left比self.cornerRadius还大，那就意味着contentView不需要圆角了）
    // 这么做是为了尽量去掉contentView对内容不必要的裁剪，以免有些东西被裁剪了看不到
    CGFloat contentViewCornerRadius = fabs(MIN(CGRectGetMinX(self.contentView.frame) - self.cornerRadius, 0));
    self.contentView.layer.cornerRadius = contentViewCornerRadius;
    
    self.layer.cornerRadius = contentViewCornerRadius;
    self.layer.shadowOpacity = 0.2;// 阴影透明度
    self.layer.shadowColor = [[UIColor blackColor] CGColor];// 阴影的颜色
    self.layer.shadowRadius = 5;// 阴影扩散的范围控制
    self.layer.shadowOffset  = CGSizeMake(0, 0);// 阴影的范围
}

// 参数 targetRect 在 window 模式下是 window 的坐标系内的，如果是 subview 模式下则是 superview 坐标系内的
- (void)layoutWithSuperview:(UIView *)superview {
    if (!superview) {
        return;
    }
    CGFloat distanceBetweenSource = 5;
    CGRect targetRect = self.sourceRect;
    UIPopoverArrowDirection currentLayoutDirection = self.arrowDirection;
    targetRect = [self.sourceView convertRect:targetRect toView:superview];
    CGRect containerRect = superview.bounds;
    
    CGSize (^sizeToFitBlock)(void) = ^CGSize(void) {
        CGSize result = CGSizeZero;
        if (self.isVerticalLayoutDirection) {
            result.width = CGRectGetWidth(containerRect) - UIEdgeInsetsGetHorizontalValue(self.safetyMarginsAvoidSafeAreaInsets);
        } else if (currentLayoutDirection == UIPopoverArrowDirectionRight) {
            result.width = CGRectGetMinX(targetRect) - distanceBetweenSource - self.safetyMarginsAvoidSafeAreaInsets.left;
        } else if (currentLayoutDirection == UIPopoverArrowDirectionLeft) {
            result.width = CGRectGetWidth(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right - distanceBetweenSource - CGRectGetMaxX(targetRect);
        }
        if (self.isHorizontalLayoutDirection) {
            result.height = CGRectGetHeight(containerRect) - UIEdgeInsetsGetVerticalValue(self.safetyMarginsAvoidSafeAreaInsets);
        } else if (currentLayoutDirection == UIPopoverArrowDirectionDown) {
            result.height = CGRectGetMinY(targetRect) - distanceBetweenSource - self.safetyMarginsAvoidSafeAreaInsets.top;
        } else if (currentLayoutDirection == UIPopoverArrowDirectionUp) {
            result.height = CGRectGetHeight(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom - distanceBetweenSource - CGRectGetMaxY(targetRect);
        }
        result = CGSizeMake(MIN(self.contentSize.width, result.width), MIN(self.contentSize.height, result.height));
        return result;
    };
    
    
    CGSize tipSize = [self sizeThatFits:sizeToFitBlock()];
    CGFloat preferredTipWidth = tipSize.width;
    CGFloat preferredTipHeight = tipSize.height;
    CGFloat tipMinX = 0;
    CGFloat tipMinY = 0;
    
    if (self.isVerticalLayoutDirection) {
        // 保护tips最往左只能到达self.safetyMarginsAvoidSafeAreaInsets.left
        CGFloat a = CGRectGetMidX(targetRect) - tipSize.width / 2;
        tipMinX = MAX(CGRectGetMinX(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.left, a);
        
        CGFloat tipMaxX = tipMinX + tipSize.width;
        if (tipMaxX + self.safetyMarginsAvoidSafeAreaInsets.right > CGRectGetMaxX(containerRect)) {
            // 右边超出了
            // 先尝试把右边超出的部分往左边挪，看是否会令左边到达临界点
            CGFloat distanceCanMoveToLeft = tipMaxX - (CGRectGetMaxX(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right);
            if (tipMinX - distanceCanMoveToLeft >= CGRectGetMinX(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.left) {
                // 可以往左边挪
                tipMinX -= distanceCanMoveToLeft;
            } else {
                // 不可以往左边挪，那么让左边靠到临界点，然后再把宽度减小，以让右边处于临界点以内
                tipMinX = CGRectGetMinX(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.left;
                tipMaxX = CGRectGetMaxX(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right;
                tipSize.width = MIN(tipSize.width, tipMaxX - tipMinX);
            }
        }
        
        // 经过上面一番调整，可能tipSize.width发生变化，一旦宽度变化，高度要重新计算，所以重新调用一次sizeThatFits
        BOOL tipWidthChanged = tipSize.width != preferredTipWidth;
        if (tipWidthChanged) {
            tipSize = [self sizeThatFits:tipSize];
        }
        
        // 检查当前的最大高度是否超过任一方向的剩余空间，如果是，则强制减小最大高度，避免后面计算布局选择方向时死循环
        BOOL canShowAtAbove = [self canTipShowAtSpecifiedLayoutDirect:UIPopoverArrowDirectionDown targetRect:targetRect tipSize:tipSize];
        BOOL canShowAtBelow = [self canTipShowAtSpecifiedLayoutDirect:UIPopoverArrowDirectionUp targetRect:targetRect tipSize:tipSize];
        
        if (!canShowAtAbove && !canShowAtBelow) {
            // 上下都没有足够的空间，所以要调整maximumHeight
            CGFloat maximumHeightAbove = CGRectGetMinY(targetRect) - CGRectGetMinY(containerRect) - distanceBetweenSource - self.safetyMarginsAvoidSafeAreaInsets.top;
            CGFloat maximumHeightBelow = CGRectGetMaxY(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom - distanceBetweenSource - CGRectGetMaxY(targetRect);
            tipSize.height = MAX(self.contentSize.height, MAX(maximumHeightAbove, maximumHeightBelow));
            currentLayoutDirection = maximumHeightAbove > maximumHeightBelow ? UIPopoverArrowDirectionDown : UIPopoverArrowDirectionUp;
        } else if (currentLayoutDirection == UIPopoverArrowDirectionDown && !canShowAtAbove) {
            currentLayoutDirection = UIPopoverArrowDirectionUp;
            tipSize.height = [self sizeThatFits:CGSizeMake(tipSize.width, sizeToFitBlock().height)].height;
        } else if (currentLayoutDirection == UIPopoverArrowDirectionUp && !canShowAtBelow) {
            currentLayoutDirection = UIPopoverArrowDirectionDown;
            tipSize.height = [self sizeThatFits:CGSizeMake(tipSize.width, sizeToFitBlock().height)].height;
        }
        
        tipMinY = [self tipOriginWithTargetRect:targetRect tipSize:tipSize preferLayoutDirection:currentLayoutDirection].y;
        
        // 当上下的剩余空间都比最小高度要小的时候，tip会靠在safetyMargins范围内的上（下）边缘
        if (currentLayoutDirection == UIPopoverArrowDirectionDown) {
            CGFloat tipMinYIfAlignSafetyMarginTop = CGRectGetMinY(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.top;
            tipMinY = MAX(tipMinY, tipMinYIfAlignSafetyMarginTop);
        } else if (currentLayoutDirection == UIPopoverArrowDirectionUp) {
            CGFloat tipMinYIfAlignSafetyMarginBottom = CGRectGetMaxY(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom - tipSize.height;
            tipMinY = MIN(tipMinY, tipMinYIfAlignSafetyMarginBottom);
        }
        
        self.frame = CGRectFlatMake(tipMinX, tipMinY, tipSize.width, tipSize.height);
        
        // 调整浮层里的箭头的位置
        CGPoint targetRectCenter = CGPointGetCenterWithRect(targetRect);
        CGFloat selfMidX = targetRectCenter.x - CGRectGetMinX(self.frame);
        _arrowMinX = selfMidX - self.arrowSizeAuto.width / 2;
    } else {
        // 保护tips最往上只能到达self.safetyMarginsAvoidSafeAreaInsets.top
        CGFloat a = CGRectGetMidY(targetRect) - tipSize.height / 2;
        tipMinY = MAX(CGRectGetMinY(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.top, a);
        
        CGFloat tipMaxY = tipMinY + tipSize.height;
        if (tipMaxY + self.safetyMarginsAvoidSafeAreaInsets.bottom > CGRectGetMaxY(containerRect)) {
            // 下面超出了
            // 先尝试把下面超出的部分往上面挪，看是否会令上面到达临界点
            CGFloat distanceCanMoveToTop = tipMaxY - (CGRectGetMaxY(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom);
            if (tipMinY - distanceCanMoveToTop >= CGRectGetMinY(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.top) {
                // 可以往上面挪
                tipMinY -= distanceCanMoveToTop;
            } else {
                // 不可以往上面挪，那么让上面靠到临界点，然后再把高度减小，以让下面处于临界点以内
                tipMinY = CGRectGetMinY(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.top;
                tipMaxY = CGRectGetMaxY(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom;
                tipSize.height = MIN(tipSize.height, tipMaxY - tipMinY);
            }
        }
        
        // 经过上面一番调整，可能tipSize.height发生变化，一旦高度变化，高度要重新计算，所以重新调用一次sizeThatFits
        BOOL tipHeightChanged = tipSize.height != preferredTipHeight;
        if (tipHeightChanged) {
            tipSize = [self sizeThatFits:tipSize];
        }
        
        // 检查当前的最大宽度是否超过任一方向的剩余空间，如果是，则强制减小最大宽度，避免后面计算布局选择方向时死循环
        BOOL canShowAtLeft = [self canTipShowAtSpecifiedLayoutDirect:UIPopoverArrowDirectionRight targetRect:targetRect tipSize:tipSize];
        BOOL canShowAtRight = [self canTipShowAtSpecifiedLayoutDirect:UIPopoverArrowDirectionLeft targetRect:targetRect tipSize:tipSize];
        
        if (!canShowAtLeft && !canShowAtRight) {
            // 左右都没有足够的空间，所以要调整maximumWidth
            CGFloat maximumWidthLeft = CGRectGetMinX(targetRect) - CGRectGetMinX(containerRect) - distanceBetweenSource - self.safetyMarginsAvoidSafeAreaInsets.left;
            CGFloat maximumWidthRight = CGRectGetMaxX(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right - distanceBetweenSource - CGRectGetMaxX(targetRect);
            tipSize.width = MAX(self.contentSize.width, MAX(maximumWidthLeft, maximumWidthRight));
            currentLayoutDirection = maximumWidthLeft > maximumWidthRight ? UIPopoverArrowDirectionRight : UIPopoverArrowDirectionLeft;
        } else if (currentLayoutDirection == UIPopoverArrowDirectionRight && !canShowAtLeft) {
            currentLayoutDirection = UIPopoverArrowDirectionRight;
            tipSize.width = [self sizeThatFits:CGSizeMake(sizeToFitBlock().width, tipSize.height)].width;
        } else if (currentLayoutDirection == UIPopoverArrowDirectionUp && !canShowAtRight) {
            currentLayoutDirection = UIPopoverArrowDirectionLeft;
            tipSize.width = [self sizeThatFits:CGSizeMake(sizeToFitBlock().width, tipSize.height)].width;
        }
        
        tipMinX = [self tipOriginWithTargetRect:targetRect tipSize:tipSize preferLayoutDirection:currentLayoutDirection].x;
        
        // 当左右的剩余空间都比最小宽度要小的时候，tip会靠在safetyMargins范围内的左（右）边缘
        if (currentLayoutDirection == UIPopoverArrowDirectionRight) {
            CGFloat tipMinXIfAlignSafetyMarginLeft = CGRectGetMinX(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.left;
            tipMinX = MAX(tipMinX, tipMinXIfAlignSafetyMarginLeft);
        } else if (currentLayoutDirection == UIPopoverArrowDirectionLeft) {
            CGFloat tipMinXIfAlignSafetyMarginRight = CGRectGetMaxX(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right - tipSize.width;
            tipMinX = MIN(tipMinX, tipMinXIfAlignSafetyMarginRight);
        }
        
        self.frame = CGRectFlatMake(tipMinX, tipMinY, tipSize.width, tipSize.height);
        
        // 调整浮层里的箭头的位置
        CGPoint targetRectCenter = CGPointGetCenterWithRect(targetRect);
        CGFloat selfMidY = targetRectCenter.y - CGRectGetMinY(self.frame);
        _arrowMinY = selfMidY - self.arrowSizeAuto.height / 2;
    }
    
    [self setNeedsLayout];
}

- (BOOL)canTipShowAtSpecifiedLayoutDirect:(UIPopoverArrowDirection)direction targetRect:(CGRect)itemRect tipSize:(CGSize)tipSize {
    BOOL canShow = NO;
    if (self.isVerticalLayoutDirection) {
        CGFloat tipMinY = [self tipOriginWithTargetRect:itemRect tipSize:tipSize preferLayoutDirection:direction].y;
        if (direction == UIPopoverArrowDirectionDown) {
            canShow = tipMinY >= self.safetyMarginsAvoidSafeAreaInsets.top;
        } else if (direction == UIPopoverArrowDirectionUp) {
            canShow = tipMinY + tipSize.height + self.safetyMarginsAvoidSafeAreaInsets.bottom <= CGRectGetHeight(self.superview.bounds);
        }
    } else {
        CGFloat tipMinX = [self tipOriginWithTargetRect:itemRect tipSize:tipSize preferLayoutDirection:direction].x;
        if (direction == UIPopoverArrowDirectionRight) {
            canShow = tipMinX >= self.safetyMarginsAvoidSafeAreaInsets.left;
        } else if (direction == UIPopoverArrowDirectionLeft) {
            canShow = tipMinX + tipSize.width + self.safetyMarginsAvoidSafeAreaInsets.right <= CGRectGetWidth(self.superview.bounds);
        }
    }
    
    return canShow;
}

- (CGPoint)tipOriginWithTargetRect:(CGRect)itemRect tipSize:(CGSize)tipSize preferLayoutDirection:(UIPopoverArrowDirection)direction {
    CGPoint tipOrigin = CGPointZero;
    CGFloat distanceBetweenSource = 5;
    switch (direction) {
        case UIPopoverArrowDirectionDown:
            tipOrigin.y = CGRectGetMinY(itemRect) - tipSize.height - distanceBetweenSource;
            break;
        case UIPopoverArrowDirectionUp:
            tipOrigin.y = CGRectGetMaxY(itemRect) + distanceBetweenSource;
            break;
        case UIPopoverArrowDirectionRight:
            tipOrigin.x = CGRectGetMinX(itemRect) - tipSize.width - distanceBetweenSource;
            break;
        case UIPopoverArrowDirectionLeft:
            tipOrigin.x = CGRectGetMaxX(itemRect) + distanceBetweenSource;
            break;
        default:
            break;
    }
    return tipOrigin;
}

- (void)showPopoverViewInView:(UIView *)view
{
    if (!view) {
        return;
    }
    [self layoutWithSuperview:view];
    
    [view addSubview:self];
}

#pragma mark - setter getter

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    if ([self isHorizontalLayoutDirection]) {
        _arrowMinY = self.bounds.size.height/2.0+_arrowOffset;
    }
    else {
        _arrowMinX = self.bounds.size.width/2.0+_arrowOffset;
    }
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
    if ([self isHorizontalLayoutDirection]) {
        _arrowMinY = self.bounds.size.height/2.0+arrowOffset;
    }
    else {
        _arrowMinX = self.bounds.size.width/2.0+arrowOffset;
    }
}

+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}

#pragma mark - UIPopoverBackgroundViewMethods

/* Represents the the length of the base of the arrow's triangle in points.
 */
+ (CGFloat)arrowBase
{
    return 16;
}

/* Describes the distance between each edge of the background view and the corresponding edge of its content view (i.e. if it were strictly a rectangle).
 */
+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

+ (CGFloat)arrowHeight
{
    return 8;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
