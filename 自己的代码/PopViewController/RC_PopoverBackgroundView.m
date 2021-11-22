//
//  RC_PopoverBackgroundView.m
//  iOSLivU
//
//  Created by HS on 2020/9/7.
//  Copyright © 2020 RC. All rights reserved.
//

#import "RC_PopoverBackgroundView.h"
#import "QMUICommonDefines.h"

@interface RC_PopoverBackgroundView ()
{
    CALayer         *_arrowImageLayer;
    CGFloat         _arrowMinX;
    CGFloat         _arrowMinY;
}

@property(nonatomic, assign) CGFloat borderWidth;
@property(nonatomic, assign) CGFloat cornerRadius;

@end

@implementation RC_PopoverBackgroundView
//以下两个属性需要被覆盖
@synthesize arrowDirection = _arrowDirection;//箭头位置
@synthesize arrowOffset = _arrowOffset;//箭头偏移

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.borderWidth = 0;
        self.cornerRadius = 8;
        
        if ([self.layer isKindOfClass:[CAShapeLayer class]]) {
            [(CAShapeLayer *)self.layer setFillColor:[UIColor whiteColor].CGColor];
        }
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
    // contentView的圆角取一个比整个path的圆角小的最大值（极限情况下如果self.contentEdgeInsets.left比self.cornerRadius还大，那就意味着contentView不需要圆角了）
    // 这么做是为了尽量去掉contentView对内容不必要的裁剪，以免有些东西被裁剪了看不到
    CGFloat contentViewCornerRadius = fabs(MIN(CGRectGetMinX(self.frame) - self.cornerRadius, 0));
    self.layer.cornerRadius = contentViewCornerRadius;
    self.layer.shadowOpacity = 0.2;// 阴影透明度
    self.layer.shadowColor = [[UIColor blackColor] CGColor];// 阴影的颜色
    self.layer.shadowRadius = 5;// 阴影扩散的范围控制
    self.layer.shadowOffset  = CGSizeMake(0, 0);// 阴影的范围
}

#pragma mark - Private Tools

- (BOOL)isSubviewShowing:(UIView *)subview {
    return subview && !subview.hidden && subview.superview;
}

#pragma mark - setter getter

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
}

- (UIPopoverArrowDirection)arrowDirection
{
    return _arrowDirection;
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

- (CGFloat)arrowOffset
{
    return _arrowOffset;
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
