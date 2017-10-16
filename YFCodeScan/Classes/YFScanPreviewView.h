//
//  YFScanPreviewView.h
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import <UIKit/UIKit.h>
#import "YFScanPreviewViewConfiguration.h"

@interface YFScanPreviewView : UIView

- (instancetype)initWithFrame:(CGRect)frame configuration:(YFScanPreviewViewConfiguration*)configuration;

- (void)startScanningAnimation;

- (void)stopScanningAnimation;

- (CGRect)getScanCropRect;

@end
