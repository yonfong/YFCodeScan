//
//  YFScanPreviewViewConfiguration.h
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import <Foundation/Foundation.h>
#import "YFScanningAnimationProtocol.h"

typedef NS_ENUM(NSInteger,YFScanningAnimationStyle)
{
    YFScanningAnimationStyleNone,
    YFScanningAnimationStyleLine,
};

typedef NS_ENUM(NSInteger, YFScanCropAngleStyle) {
    YFScanCropAngleStyleOuter,
    YFScanCropAngleStyleInner,
    YFScanCropAngleStyleOn
};


@interface YFScanPreviewViewConfiguration : NSObject

@property (nonatomic, assign) BOOL showScanCropBorder;

@property (nonatomic, assign) CGFloat scanCropXMargin;

@property (nonatomic, assign) CGFloat scanCropAspectRatio;

@property (nonatomic, assign) CGFloat scanCropCenterYOffset;

@property (nonatomic, strong) UIColor * _Nullable scanCropBorderColor;

@property (nonatomic, assign) YFScanCropAngleStyle scanCropAngleStyle;

@property (nonatomic, assign) YFScanningAnimationStyle scanningAnimationStyle;

@property (nonatomic, strong) id <YFScanningAnimationProtocol> _Nullable scanningAnimationItem;

@property (nonatomic, strong) UIColor * _Nullable scanCropAngleLineColor;

@property (nonatomic, assign) CGFloat scanCropAngleLineWidth;

@property (nonatomic, assign) CGFloat scanCropAngleLineHeight;

@property (nonatomic, strong) UIColor * _Nullable scanCropOuterFillColor;



@end
