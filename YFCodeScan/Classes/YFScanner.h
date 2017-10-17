//
//  YFScanner.h
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

typedef NS_ENUM(NSInteger,YFSessionSetupResult) {
    YFSessionSetupResultNotAuthorized,
    YFSessionSetupResultFailed,
    YFSessionSetupResultSuccess
};

@interface YFScanner : NSObject

@property (nonatomic, strong, readonly) dispatch_queue_t _Nullable sessionQueue;

@property (nonatomic, assign) YFSessionSetupResult sessionSetupResult;

@property (nonatomic, copy, null_resettable) NSArray<AVMetadataObjectType> *metadataObjectTypes;

@property (nonatomic,copy)void (^ _Nullable scanSuccessResult)(NSString * _Nullable scannedResult);

@property (nonatomic, assign) CGRect rectOfInterest;

- (instancetype _Nullable )initWithScanSuccess:(void(^_Nullable)(NSString * _Nonnull scannedResult))success;

- (void)setupCaptureSession;

- (void)startScanning;

- (void)stopScanning;

- (void)setTorchMode:(AVCaptureTorchMode)torchMode;

- (AVCaptureVideoPreviewLayer *_Nullable)previewLayer;

@end
