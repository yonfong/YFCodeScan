//
//  YFScanner.h
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

typedef NS_ENUM(NSInteger,YFSessionStatus) {
    YFSessionStatusUnSetup,
    YFSessionStatusPemissionDenied,
    YFSessionStatusSetupFailed,
    YFSessionStatusSetupSucceed,
    YFSessionStatusRunning,
    YFSessionStatusStop
};

NS_ASSUME_NONNULL_BEGIN

@interface YFScanner : NSObject

@property (nonatomic, assign, readonly) YFSessionStatus status;

@property (nonatomic, copy, null_resettable) NSArray<NSString *> *metadataObjectTypes;

@property (nonatomic,copy)void (^ _Nullable scanSuccessResult)(NSString * _Nullable scannedResult);

@property (nonatomic, assign) CGRect rectOfInterest;

- (instancetype _Nullable )initWithScanSuccess:(void(^_Nullable)(NSString * _Nonnull scannedResult))success;

- (void)startScanning;

- (void)stopScanning;

- (void)setTorchMode:(AVCaptureTorchMode)torchMode;

- (AVCaptureVideoPreviewLayer *)previewLayer;

@end

NS_ASSUME_NONNULL_END
