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

- (void)startAnimationInView:(UIView*)preview limitRect:(CGRect)limitRect
{
    if (!self.lineView) {
        return;
    }

    self.lineView.hidden = YES;
    if (self.lineView.superview) {
        [self.lineView removeFromSuperview];
    }
    [preview addSubview:self.lineView];
    CGFloat height = CGRectGetHeight(self.lineView.bounds);
    CGFloat width = MIN(CGRectGetWidth(limitRect), CGRectGetWidth(self.lineView.bounds));
    self.lineView.frame = CGRectMake(limitRect.origin.x, limitRect.origin.y, width, height);
    self.lineView.hidden = NO;
    
    CGRect centerTop = CGRectOffset(self.lineView.frame, (CGRectGetWidth(limitRect) - CGRectGetWidth(self.lineView.bounds))/2, 0);
    self.lineView.frame = centerTop;
    
    CAKeyframeAnimation *animation = [self upDownAnimationForLineRect:centerTop limitRect:limitRect];
    [self.lineView.layer addAnimation:animation forKey:kScanPostionKeyframeValueAnimation];
}


- (CAKeyframeAnimation *)upDownAnimationForLineRect:(CGRect)lineRect limitRect:(CGRect)limitRect {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 4.0;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y)];
    NSValue *value2=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect) / 2)];
    NSValue *value3=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect))];
    NSValue *value4=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y + CGRectGetHeight(limitRect) / 2)];
    NSValue *value5=[NSValue valueWithCGPoint:CGPointMake(lineRect.origin.x + CGRectGetWidth(lineRect) / 2, lineRect.origin.y)];
    animation.values = @[value1, value2, value3, value4, value5];
    return animation;
}


- (void)stopAnimation
{
    [self.lineView.layer removeAnimationForKey:kScanPostionKeyframeValueAnimation];
    self.lineView.hidden = YES;
    [self.lineView removeFromSuperview];
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 1)];
        _lineView.backgroundColor = [UIColor yellowColor];
    }
    return _lineView;
}

@end
