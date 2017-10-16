//
//  YFScanningAnimationConfiguration.h
//  Pods
//
//  Created by sky on 2017/10/15.
//

#import <Foundation/Foundation.h>
#import "YFScanningAnimationProtocol.h"

@interface YFScanningLineAnimation : NSObject <YFScanningAnimationProtocol>

@property (nonatomic, strong) __kindof UIView *lineView;

@end
