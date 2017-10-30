//
//  YFScanPreviewView.h
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import "YFScanPreviewViewConfiguration.h"
#import <UIKit/UIKit.h>

@interface YFScanPreviewView : UIView

@property (nonatomic, strong) YFScanPreviewViewConfiguration *configuration;

- (instancetype)initWithFrame:(CGRect)frame configuration:(YFScanPreviewViewConfiguration *)configuration;

+ (instancetype)defaultPreview;

- (void)startScanningAnimation;

- (void)stopScanningAnimation;

- (CGRect)getScanCropRect;

- (CGRect)getRectOfInterest;

@end
