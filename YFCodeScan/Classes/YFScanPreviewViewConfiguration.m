//
//  YFScanPreviewViewConfiguration.m
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import "YFScanPreviewViewConfiguration.h"
#import "YFScanningLineAnimation.h"

@implementation YFScanPreviewViewConfiguration

- (instancetype)init
{
    if (self =  [super init]) {
        _showScanCropBorder = YES;
        _scanCropXMargin = 60;
        _scanCropCenterYOffset = 0;
        _scanCropAspectRatio = 1.0;
        
        _scanCropBorderWidth = 0.5;
        _scanCropAngleLineWidth = 2.0;
        _scanCropAngleLineHeight = 20;
        _scanCropAngleStyle = YFScanCropAngleStyleInner;
        _scanningAnimationItem = [[YFScanningLineAnimation alloc] init];
        
        _scanCropBorderColor = [UIColor whiteColor];
        _scanCropAngleLineColor = [UIColor greenColor];
        _scanCropOuterFillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    }
    return self;
}

+ (instancetype)defaultConfiguration
{
    return [[self alloc] init];
}

@end
