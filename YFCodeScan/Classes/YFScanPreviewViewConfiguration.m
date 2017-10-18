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
        _angleLineWidth = 2.0;
        _angleLineHeight = 20;
        _angleAttachment = YFScanCropAngleAttachmentInner;
        _scanningAnimationItem = [[YFScanningLineAnimation alloc] init];
        
        _scanCropBorderColor = [UIColor whiteColor];
        _angleLineColor = [UIColor greenColor];
        _maskFillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        _tipText = @"将二维码/条形码放入取景框即可自动扫描";
    }
    return self;
}

+ (instancetype)defaultConfiguration
{
    return [[self alloc] init];
}

@end
