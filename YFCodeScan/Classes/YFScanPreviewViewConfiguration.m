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
        
        _scanCropAngleLineWidth = 4;
        _scanCropAngleLineHeight = 20;
        _scanCropAngleStyle = YFScanCropAngleStyleInner;
        _scanningAnimationItem = [[YFScanningLineAnimation alloc] init];
        
        _scanCropBorderColor = [UIColor whiteColor];
        _scanCropAngleLineColor = [UIColor colorWithRed:0. green:167./255. blue:231./255. alpha:1.0];
        _scanCropOuterFillColor = [UIColor colorWithRed:0. green:.0 blue:.0 alpha:.5];
    }
    return self;
}

@end
