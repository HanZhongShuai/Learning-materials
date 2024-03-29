//
//  RC_WaterWave.m
//  iOSLivU
//
//  Created by RC on 2017/6/30.
//  Copyright © 2017年 TCH. All rights reserved.
//

#import "RC_WaterWave.h"

@interface RC_WaterWave ()

@property (assign, nonatomic) CGFloat offsetX;
@property (strong, nonatomic) CADisplayLink *waveDisplayLink;
@property (strong, nonatomic) CAShapeLayer *waveShapeLayer;

@end

@implementation RC_WaterWave

- (void)dealloc {
    [self.waveDisplayLink invalidate];
    self.waveDisplayLink = nil;
}

+ (instancetype)addToView:(UIView *)view withFrame:(CGRect)frame {
    RC_WaterWave *waveView = [[self alloc] initWithFrame:frame];
    [view addSubview:waveView];
    return waveView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self basicSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ([super initWithCoder:aDecoder]) {
        [self basicSetup];
    }
    return self;
}

- (void)basicSetup {
    _angularSpeed = 2.f;
    _waveSpeed = 9.f;
    _waveTime = 1.5f;
    _waveTime = 0.f;
    _waveColor = [UIColor whiteColor];
}

- (BOOL)wave {
    if (self.waveShapeLayer.path) {
        return NO;
    }
    self.waveShapeLayer = [CAShapeLayer layer];
    self.waveShapeLayer.fillColor = self.waveColor.CGColor;
    
    [self.layer addSublayer:self.waveShapeLayer];
    
    self.waveDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(currentWave)];
    [self.waveDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    if (self.waveTime > 0.f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.waveTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stop];
        });
    }
    return YES;
}

- (void)currentWave {
    self.offsetX -= (self.waveSpeed * self.superview.frame.size.width / 320);
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, height / 2);
    
    CGFloat y = 0.f;
    for (CGFloat x = 0.f; x <= width ; x++) {
        y = height * sin(0.01 * (self.angularSpeed * x + self.offsetX));
        CGPathAddLineToPoint(path, NULL, x, y);
    }
    CGPathAddLineToPoint(path, NULL, width, height);
    CGPathAddLineToPoint(path, NULL, 0, height);
    CGPathCloseSubpath(path);
    
    self.waveShapeLayer.path = path;
    CGPathRelease(path);
}

- (void)stop {
    [UIView animateWithDuration:1.f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.waveDisplayLink invalidate];
        self.waveDisplayLink = nil;
        self.waveShapeLayer.path = nil;
        self.alpha = 1.f;
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
