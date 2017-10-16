//
//  YFScanner.h
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

@interface YFScanner : NSObject

@property(nonatomic, copy, null_resettable) NSArray<AVMetadataObjectType> *metadataObjectTypes;

- (instancetype _Nullable )initWithScanSuccess:(void(^_Nullable)(NSString * _Nonnull scannedResult))success;

- (instancetype _Nullable )initWithScanCrop:(CGRect)scanCrop scanSuccess:(void (^_Nullable)(NSString *_Nonnull scannedResult))success;

- (void)startScanning;

- (void)stopScanning;

- (void)setTorchMode:(AVCaptureTorchMode)torchMode;

- (AVCaptureVideoPreviewLayer *_Nullable)previewLayer;

@end
