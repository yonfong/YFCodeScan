//
//  YFScanningAnimationConfiguration.m
//  Pods
//
//  Created by sky on 2017/10/15.
//

#import "YFScanningAnimationConfiguration.h"

@interface YFScanningAnimationConfiguration()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) CGRect animationRect;

@property (nonatomic, weak) UIView *animationView;

@end

@implementation YFScanningAnimationConfiguration

- (void)startAnimationInView:(UIView *)preview animationRect:(CGRect)animationRect animationView:(UIView *)animationView
{
    if (!animationView) {
        return;
    }
    
    animationView.hidden = YES;
    [preview addSubview:animationView];
    CGFloat height = CGRectGetHeight(animationView.bounds);
    animationView.frame = CGRectMake(animationRect.origin.x, animationRect.origin.y, CGRectGetWidth(animationRect), height);
    animationView.hidden = NO;
    
    self.animationView = animationView;
    
    self.displayLink.paused = NO;
}

- (void)stopAnimation
{
    self.displayLink.paused = YES;
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    CABasicAnimation *anim = [CABasicAnimation animation];;

    anim.keyPath = @"anchorPoint";
    //    包装成对象
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];;
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 1)];
    anim.duration = 2.0;
    anim.repeatCount = 
    //    让图层保持动画执行完毕后的状态
    //    执行完毕以后不要删除动画
    anim.removedOnCompletion = NO;
    //    保持最新的状态
    anim.fillMode = kCAFillModeForwards;
    
    [self.animationView.layer addAnimation:anim forKey:@"anchorPoint"];
}

#pragma mark - getters

- (CADisplayLink *)displayLink {
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        _displayLink.frameInterval = 60;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    
    return _displayLink;
}
@end
