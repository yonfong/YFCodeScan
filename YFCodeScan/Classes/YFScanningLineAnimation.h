//
//  YFScanningAnimationConfiguration.h
//  Pods
//
//  Created by sky on 2017/10/15.
//

#import "YFScanningAnimationProtocol.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YFLineAnimationType) { YFLineAnimationTypeUpToDown, YFLineAnimationTypeUpToDownThenReverse };

@interface YFScanningLineAnimation : NSObject <YFScanningAnimationProtocol>

@property (nonatomic, strong) __kindof UIView *lineView;

@property (nonatomic, assign) YFLineAnimationType lineAnimationType;

@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;

@property (nonatomic, assign) CGFloat speed;

+ (instancetype)defaultScanningLineAnimation;

@end
