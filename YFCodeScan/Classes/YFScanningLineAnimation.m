//
//  YFScanningAnimationConfiguration.m
//  Pods
//
//  Created by sky on 2017/10/15.
//

#import "YFScanningLineAnimation.h"

@interface YFScanningLineAnimation()

@end

static NSString * const kScanPostionKeyframeValueAnimation = @"kScanPostionKeyframeValueAnimation";

@implementation YFScanningLineAnimation

- (instancetype)init
{
    if (self = [super init]) {
        _lineAnimationType = YFLineAnimationTypeUpToDown;
        _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _speed = 1;
    }
    return self;
}

+ (instancetype)defaultScanningLineAnimation
{
    return [[self alloc] init];
}

- (void)startAnimationInView:(UIView*)preview limitRect:(CGRect)limitRect
{
    if (!self.lineView) {
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(limitRect.origin.x, limitRect.origin.y + 1, CGRectGetWidth(limitRect) - 4, 1)];
        self.lineView.backgroundColor = [UIColor greenColor];
    }

    self.lineView.hidden = YES;
    if (self.lineView.superview) {
        [self.lineView removeFromSuperview];
    }
    [preview addSubview:self.lineView];
    
    CGFloat lineHeight = CGRectGetHeight(self.lineView.bounds);
    CGFloat lineWidth = MIN(CGRectGetWidth(limitRect), CGRectGetWidth(self.lineView.bounds));
    CGRect frame = CGRectMake(limitRect.origin.x, limitRect.origin.y + 1, lineWidth, lineHeight);
    CGRect initialRect = CGRectOffset(frame, (CGRectGetWidth(limitRect) - lineWidth)/2, 0);
    self.lineView.frame = initialRect;
    self.lineView.hidden = NO;
    
    CAKeyframeAnimation *animation = [self animationForLineRect:initialRect limitRect:limitRect];
    [self.lineView.layer addAnimation:animation forKey:kScanPostionKeyframeValueAnimation];
}

- (CAKeyframeAnimation *)animationForLineRect:(CGRect)lineRect limitRect:(CGRect)limitRect {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 1;
    animation.speed = _speed;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = _timingFunction ? : [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    if (_lineAnimationType == YFLineAnimationTypeUpToDownThenReverse) {
        NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y)];
        NSValue *value2=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect) / 2)];
        NSValue *value3=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect) - 1)];
        NSValue *value4=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect) / 2)];
        NSValue *value5=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y)];
        animation.values = @[value1, value2, value3, value4, value5];
    } else {
        NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y)];
        NSValue *value2=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect) * 1 / 4)];
        NSValue *value3=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect) * 2 / 4)];
        NSValue *value4=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect) * 3 / 4)];
        NSValue *value5=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect) * 4 / 4 - 1) ];
        animation.values = @[value1, value2, value3, value4, value5];
    }
    
    return animation;
}

- (void)stopAnimation
{
    [self.lineView.layer removeAnimationForKey:kScanPostionKeyframeValueAnimation];
    self.lineView.hidden = YES;
    [self.lineView removeFromSuperview];
}

@end
