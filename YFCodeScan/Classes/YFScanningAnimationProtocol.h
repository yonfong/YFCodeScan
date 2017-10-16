//
//  YFScanningAnimationProtocol.h
//  Pods
//
//  Created by yongfeng on 2017/10/16.
//

#ifndef YFScanningAnimationProtocol_h
#define YFScanningAnimationProtocol_h

@protocol YFScanningAnimationProtocol <NSObject>

- (void)startAnimationInView:(UIView*)preview limitRect:(CGRect)limitRect;

- (void)stopAnimation;

@end

#endif /* YFScanningAnimationProtocol_h */
