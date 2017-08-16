//
//  RC_RangeSlider.m
//  RC_RangeSlider
//
//  Created by RC on 2017/5/2.
//  Copyright © 2017年 RC. All rights reserved.
//

#import "RC_RangeSlider.h"

@interface RC_RangeSlider ()
{
    CGFloat labelYDistance;
    CGFloat cornerRadius;
    CGFloat lineHeight;
    
    CGFloat rangeWidth;
    
    BOOL _minOn;
    BOOL _maxOn;
}
@property (nonatomic, assign) BOOL isBuildUI;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *minLabel;
@property (strong, nonatomic) UILabel *maxLabel;
@property (strong, nonatomic) UIImageView *bg;
@property (strong, nonatomic) UIImageView *selectView;
@property (strong, nonatomic) UIImageView *min;
@property (strong, nonatomic) UIImageView *max;

@end

@implementation RC_RangeSlider

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_isBuildUI == NO) {
        _isBuildUI = YES;
        labelYDistance = 10.0f;
        cornerRadius = 10.0f;
        lineHeight = 2.0f;
        if (self.maxValue == 0) {
            self.maxValue = 65;
            self.upperValue = self.maxValue;
        }
        if (self.minValue == 0) {
            self.minValue = 0;
        }
        if (self.lowerValue > self.upperValue) {
            int tem = self.upperValue;
            self.upperValue = self.lowerValue;
            self.lowerValue = tem;
        }
        [self setUI];
    }
    else {
        [self refreshUI];
    }
}

- (void)setUI
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height/165.0*135.0, self.frame.size.height)];
    if (self.title && self.title.length > 0) {
        self.titleLabel.text = self.title;
    }
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:(36.0 / 96.0) * 72 * 0.65];
    self.titleLabel.textColor = [UIColor blackColor];
    [self addSubview:self.titleLabel];
    
    _bg = [[UIImageView alloc] initWithFrame:CGRectMake(cornerRadius+self.titleLabel.frame.size.width, self.frame.size.height/2.0 - (lineHeight/2.0), self.frame.size.width - self.titleLabel.frame.size.width - 23.0, lineHeight)];
    _bg.backgroundColor = [UIColor colorWithRed:0.87 green:0.89 blue:0.91 alpha:1.0];
    [self addSubview:_bg];
    
    rangeWidth = _bg.frame.size.width - (cornerRadius*2.0);
    
    
    _min = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cornerRadius*2.0, cornerRadius*2.0)];
    CGFloat minMove = ((CGFloat)(self.lowerValue-self.minValue))/((CGFloat)(self.maxValue-self.minValue))*rangeWidth;
    _min.center = CGPointMake(_bg.frame.origin.x+minMove, _bg.center.y);
    _min.backgroundColor = [UIColor whiteColor];
    _min.layer.cornerRadius = cornerRadius;
    _min.layer.borderWidth = 0.5;
    _min.layer.borderColor = [[UIColor colorWithRed:0.6 green:0.38 blue:0.96 alpha:1.0] CGColor];
    _min.layer.masksToBounds = YES;
    [self addSubview:_min];
    
    _max = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cornerRadius*2.0, cornerRadius*2.0)];
    CGFloat maxMove = ((CGFloat)(self.maxValue-self.upperValue))/((CGFloat)(self.maxValue-self.minValue))*rangeWidth;
    _max.center = CGPointMake(_bg.frame.origin.x+_bg.frame.size.width-maxMove, _bg.center.y);
    _max.backgroundColor = [UIColor whiteColor];
    _max.layer.borderWidth = 0.5;
    _max.layer.borderColor = [[UIColor colorWithRed:0.6 green:0.38 blue:0.96 alpha:1.0] CGColor];
    _max.layer.cornerRadius = cornerRadius;
    _max.layer.masksToBounds = YES;
    [self addSubview:_max];
    
    _selectView = [[UIImageView alloc] initWithFrame:CGRectMake(_min.frame.origin.x+_min.frame.size.width, _bg.frame.origin.y, _max.frame.origin.x - _min.frame.origin.x-_min.frame.size.width, _bg.frame.size.height)];
    _selectView.backgroundColor = [UIColor colorWithRed:0.6 green:0.38 blue:0.96 alpha:1.0];
    [self addSubview:_selectView];
    
    self.minLabel = [[UILabel alloc] init];
    self.minLabel.font = [UIFont systemFontOfSize:12.0f] ;
    self.minLabel.text = [NSString stringWithFormat:@"%d", (int)self.lowerValue] ;
    self.minLabel.textColor = [UIColor colorWithRed:0.6 green:0.38 blue:0.96 alpha:1.0];
    
    self.maxLabel = [[UILabel alloc] init] ;
    self.maxLabel.font = [UIFont systemFontOfSize:12.0f] ;
    self.maxLabel.text = [NSString stringWithFormat:@"%d", (int)self.upperValue] ;
    self.maxLabel.textColor = [UIColor colorWithRed:0.6 green:0.38 blue:0.96 alpha:1.0];
    [self addSubview:self.minLabel];
    [self addSubview:self.maxLabel];
    [self.minLabel sizeToFit] ;
    [self.maxLabel sizeToFit] ;
    self.minLabel.center = CGPointMake(_min.center.x, _min.center.y - cornerRadius - labelYDistance) ;
    self.maxLabel.center = CGPointMake(_max.center.x, _max.center.y - cornerRadius - labelYDistance);
}

- (void)refreshUI
{
    
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    if (self.titleLabel) {
        self.titleLabel.text = _title;
    }
}

#pragma mark - Tracking Part.

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!_minOn && !_maxOn) return NO;
    
    CGPoint touchPoint = [touch locationInView:self];
    if (_minOn && touchPoint.x <= _max.frame.origin.x - cornerRadius && touchPoint.x >= _bg.frame.origin.x) {
        _min.center = CGPointMake(touchPoint.x, _bg.frame.origin.y);
        _selectView.frame = CGRectMake(_min.frame.origin.x+_min.frame.size.width, _bg.frame.origin.y, _max.frame.origin.x - _min.frame.origin.x-_min.frame.size.width, _bg.frame.size.height);
        int lower = (int)((_min.center.x - _bg.frame.origin.x)/rangeWidth*(self.maxValue - self.minValue)*100);
        if (lower%100>=50) {
            self.lowerValue = lower/100+1;
        }
        else {
            self.lowerValue = lower/100;
        }
        self.minLabel.center = CGPointMake(_min.center.x, _min.center.y - cornerRadius - labelYDistance) ;
        self.minLabel.text = [NSString stringWithFormat:@"%d",self.lowerValue];
        [self.minLabel sizeToFit];
    }
    if (_maxOn && touchPoint.x >= _min.center.x + (cornerRadius*2.0) && touchPoint.x <= _bg.frame.origin.x+_bg.frame.size.width) {
        _max.center = CGPointMake(touchPoint.x, _bg.frame.origin.y);
        _selectView.frame = CGRectMake(_min.frame.origin.x+_min.frame.size.width, _bg.frame.origin.y, _max.frame.origin.x - _min.frame.origin.x-_min.frame.size.width, _bg.frame.size.height);
        int upper = (int)((_max.center.x - _bg.frame.origin.x - _max.frame.size.width)/rangeWidth*(self.maxValue - self.minValue)*100);
        if (upper%100>=50) {
            self.upperValue = upper/100+1;
        }
        else {
            self.upperValue = upper/100;
        }
        self.maxLabel.center = CGPointMake(_max.center.x, _max.center.y - cornerRadius - labelYDistance);
        self.maxLabel.text = [NSString stringWithFormat:@"%d",self.upperValue];
        [self.maxLabel sizeToFit] ;
    }
//    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(_min.frame, point)) {
        _minOn = YES;
    }
    if (CGRectContainsPoint(_max.frame, point)) {
        _maxOn = YES;
    }
    if (!_minOn && !_maxOn) return NO;
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _minOn = NO;
    _maxOn = NO;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
