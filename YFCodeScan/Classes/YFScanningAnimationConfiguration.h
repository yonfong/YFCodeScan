//
//  YFScanningAnimationConfiguration.h
//  Pods
//
//  Created by sky on 2017/10/15.
//

#import <Foundation/Foundation.h>

@interface YFScanningAnimationConfiguration : NSObject

- (void)startAnimationInView:(UIView*)preview animationRect:(CGRect)animationRect animationView:(UIView *)animationView;

- (void)stopAnimation;

@end
