//
//  YFScanPreviewViewConfiguration.h
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import <Foundation/Foundation.h>
#import "YFScanningAnimationProtocol.h"

typedef NS_ENUM(NSInteger, YFScanCropAngleAttachment) {
    YFScanCropAngleAttachmentOuter,
    YFScanCropAngleAttachmentInner,
    YFScanCropAngleAttachmentOn
};


@interface YFScanPreviewViewConfiguration : NSObject

@property (nonatomic, assign) BOOL showScanCropBorder;

@property (nonatomic, assign) CGFloat scanCropXMargin;

@property (nonatomic, assign) CGFloat scanCropAspectRatio;

@property (nonatomic, assign) CGFloat scanCropCenterYOffset;

@property (nonatomic, strong) UIColor * _Nullable scanCropBorderColor;

@property (nonatomic, assign) CGFloat scanCropBorderWidth;

@property (nonatomic, assign) YFScanCropAngleAttachment angleAttachment;

@property (nonatomic, strong) id <YFScanningAnimationProtocol> _Nullable scanningAnimationItem;

@property (nonatomic, strong) UIColor * _Nullable angleLineColor;

@property (nonatomic, assign) CGFloat angleLineWidth;

@property (nonatomic, assign) CGFloat angleLineHeight;

@property (nonatomic, strong) UIColor * _Nullable maskFillColor;

@property (nonatomic, copy) NSString * _Nullable tipText;

+ (instancetype _Nullable )defaultConfiguration;

@end
