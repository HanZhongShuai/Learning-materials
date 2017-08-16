//
//  StretchLabel.m
//  labeltest
//
//  Created by RC on 2017/5/5.
//  Copyright © 2017年 RC. All rights reserved.
//

#import "StretchLabel.h"
#import <CoreText/CoreText.h>
typedef enum : NSUInteger {
    StretchLabelState_New,
    StretchLabelState_NeedRefreshFrame,
    StretchLabelState_ShowLimit,
    StretchLabelState_ShowAll,
} StretchLabelState;
@interface StretchLabel ()
{
    NSInteger limitLine;
    NSString *stretchMessage;
    
    NSString *showLimeStr;
}

@property (nonatomic, strong) NSArray *linStrArr;

@property (nonatomic, assign) StretchLabelState state;

@end

@implementation StretchLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        limitLine = 4;
        stretchMessage = @"more";
        self.state = StretchLabelState_New;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setStretchText:(NSString *)stretchText
{
    if (_stretchText == nil || ![_stretchText isEqualToString:stretchText])
    {
        _stretchText = stretchText;
        self.font = [UIFont systemFontOfSize:17];
        
        if (self.state == StretchLabelState_ShowAll) {
            self.state = StretchLabelState_NeedRefreshFrame;
            self.attributedText = nil;
            self.text = stretchText;
        }
        else {
            self.state = StretchLabelState_New;
        }
        
        self.userInteractionEnabled = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.state == StretchLabelState_NeedRefreshFrame) {
        self.state = StretchLabelState_ShowAll;
        self.linStrArr = [self getSeparatedLines];
        if (_linStrArr) {
            CGSize size = [self getStringRect:@"rc"].size;
            if ([self.delegate respondsToSelector:@selector(stretchLabelHeightWillChange:)]) {
                [self.delegate stretchLabelHeightWillChange:size.height*_linStrArr.count];
            }
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size.height*_linStrArr.count);
        }
    }
    else if (self.state == StretchLabelState_New) {
        self.linStrArr = [self getSeparatedLines];
        [self showText];
    }
}

- (void)showText
{
    limitLine = 4;
    stretchMessage = @"more";
    
    if (self.state == StretchLabelState_New && _linStrArr && _linStrArr.count > limitLine) {
        NSString *replaceStr = [NSString stringWithFormat:@"... %@",stretchMessage];
        CGSize replaceStrSize = [self getStringRect:replaceStr].size;
        CGSize limitLineSize = [self getStringRect:[_linStrArr objectAtIndex:limitLine-1]].size;
        
        NSMutableString *resultStr = [[NSMutableString alloc] init];
        for (NSInteger i = 0; i < limitLine; i++) {
            NSString *lineStr = [_linStrArr objectAtIndex:i];
            [resultStr appendString:lineStr];
            if (i == limitLine-1) {
                showLimeStr = [NSString stringWithString:lineStr];
            }
        }
        if (limitLineSize.width + replaceStrSize.width > self.frame.size.width) {
            [resultStr replaceCharactersInRange:NSMakeRange(resultStr.length - replaceStr.length, replaceStr.length) withString:replaceStr];
            showLimeStr = [showLimeStr stringByReplacingCharactersInRange:NSMakeRange(showLimeStr.length - replaceStr.length, replaceStr.length) withString:replaceStr];
        }
        else {
            [resultStr appendString:replaceStr];
            showLimeStr = [showLimeStr stringByAppendingString:replaceStr];
        }
        
        NSMutableAttributedString*attribute = [[NSMutableAttributedString alloc] initWithString: resultStr];
        if (stretchMessage && stretchMessage.length > 0) {
            NSRange range = [resultStr rangeOfString:stretchMessage];
            if (range.location != NSNotFound) {
                [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
            }
        }
        self.state = StretchLabelState_ShowLimit;
        self.text = nil;
        self.attributedText = attribute;
        if (self.frame.size.height - replaceStrSize.height*limitLine > 1 || self.frame.size.height - replaceStrSize.height*limitLine < -1)
        {
            if ([self.delegate respondsToSelector:@selector(stretchLabelHeightWillChange:)]) {
                [self.delegate stretchLabelHeightWillChange:replaceStrSize.height*limitLine];
            }
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, replaceStrSize.height*limitLine);
        }
    }
    else {
        self.state = StretchLabelState_ShowAll;
        self.attributedText = nil;
        self.text = _stretchText;
    }
}

- (CGRect)getStringRect:(NSString *)str
{
    CGRect rect = [str boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
    return rect;
}

-(NSArray *)getSeparatedLines
{
    if (_stretchText == nil) {
        return nil;
    }
    NSString *text = _stretchText;
    UIFont   *font = [self font];
    CGRect    rect = [self frame];
    
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    return (NSArray *)linesArray;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.state == StretchLabelState_ShowLimit) {
        UITouch *touch=[touches anyObject];
        CGPoint point=[touch locationInView:self];
        CGSize stretchMessageSize = [self getStringRect:stretchMessage].size;
        CGSize showLimeStrSize = [self getStringRect:showLimeStr].size;
        CGRect stretchMessageRect = CGRectMake(showLimeStrSize.width - stretchMessageSize.width, stretchMessageSize.height*(limitLine-1), stretchMessageSize.width, stretchMessageSize.height);
        if (CGRectContainsPoint(stretchMessageRect, point)) {
            if (_linStrArr && _linStrArr.count > limitLine) {
                
                self.state = StretchLabelState_ShowAll;
                if ([self.delegate respondsToSelector:@selector(stretchLabelHeightWillChange:)]) {
                    [self.delegate stretchLabelHeightWillChange:stretchMessageSize.height*_linStrArr.count];
                }
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, stretchMessageSize.height*_linStrArr.count);
                self.attributedText = nil;
                self.text = _stretchText;
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
