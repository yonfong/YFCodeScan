//
//  YFScanner.m
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import "YFScanner.h"

// 主线程执行
NS_INLINE void dispatch_main_async(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@interface YFScanner()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong, readwrite) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) dispatch_queue_t metadataObjectsQueue;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@end

@implementation YFScanner

@synthesize metadataObjectTypes = _metadataObjectTypes;

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)init
{
    return [self initWithScanSuccess:nil];
}

- (instancetype)initWithScanSuccess:(void (^)(NSString * _Nonnull))success
{
    if(self = [super init]){
        [self commonInit];
        _scanSuccessResult = success;
        
        [self checkCameraPemission];
        
        [self startSetupCaptureSession];
    }
    return self;
}

- (void)commonInit
{
    _sessionQueue = dispatch_queue_create( "com.bluesky.scanner.session", DISPATCH_QUEUE_SERIAL );
    _metadataObjectsQueue = dispatch_queue_create( "com.bluesky.scanner.metadataObjects", DISPATCH_QUEUE_SERIAL );
    _captureSession = [[AVCaptureSession alloc] init];
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    _status = YFSessionStatusUnSetup;
}


- (void)startScanning
{
    if (_status == YFSessionStatusRunning) {
        return;
    }
    dispatch_async(_sessionQueue, ^{
        [_captureSession startRunning];
        _status = YFSessionStatusRunning;
        if ([self.delegate respondsToSelector:@selector(scannerDidSessionStatusChanged:)]) {
            dispatch_main_async(^{
                [self.delegate scannerDidSessionStatusChanged:self];
            });
        }
    });
}

- (void)stopScanning
{
    if (_status == YFSessionStatusStop) {
        return;
    }
    
    dispatch_async(_sessionQueue, ^{
        [_captureSession stopRunning];
        _status = YFSessionStatusStop;
        if ([self.delegate respondsToSelector:@selector(scannerDidSessionStatusChanged:)]) {
            dispatch_main_async(^{
                [self.delegate scannerDidSessionStatusChanged:self];
            });
        }
    });
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    if (![_captureDeviceInput.device isTorchModeSupported:torchMode]) {
        return;
    }
    
    [_captureDeviceInput.device lockForConfiguration:nil];
    _captureDeviceInput.device.torchMode = torchMode;
    [_captureDeviceInput.device unlockForConfiguration];
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if(!_previewLayer && _captureSession){
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    }
    return _previewLayer;
}

#pragma mark - Capture Session Setup

- (void)startSetupCaptureSession
{
    if ([self.delegate respondsToSelector:@selector(scannerWillStartSetup:)]) {
        [self.delegate scannerWillStartSetup:self];
    }
    dispatch_async(_sessionQueue, ^{
        [self setupCaptureSession];
    });
}

- (void)checkCameraPemission {
    AVAuthorizationStatus permission =
    [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (permission) {
        case AVAuthorizationStatusAuthorized:
            break;
            
        case AVAuthorizationStatusNotDetermined:
        {
            dispatch_suspend(_sessionQueue);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         if (!granted) {
                                             _status = YFSessionStatusPemissionDenied;
                                             if ([self.delegate respondsToSelector:@selector(scannerDidSessionStatusChanged:)]) {
                                                 [self.delegate scannerDidSessionStatusChanged:self];
                                             }
                                         }
                                         dispatch_resume(_sessionQueue);
                                     }];
        }
            break;
            
        default:
        {
            _status = YFSessionStatusPemissionDenied;
            if ([self.delegate respondsToSelector:@selector(scannerDidSessionStatusChanged:)]) {
                [self.delegate scannerDidSessionStatusChanged:self];
            }
        }
            break;
            
    }
}


- (void)setupCaptureSession
{
    if (_status == YFSessionStatusSetupSucceed || _status != YFSessionStatusUnSetup) {
        return ;
    }
    
    [_captureSession beginConfiguration];
    if(![self addDefaultCameraInputToCaptureSession:_captureSession]){
        NSLog(@"failed to add camera input to capture session");
        _status = YFSessionStatusSetupFailed;
        [_captureSession commitConfiguration];
        
        if ([self.delegate respondsToSelector:@selector(scannerDidSessionStatusChanged:)]) {
            dispatch_main_async(^{
                [self.delegate scannerDidSessionStatusChanged:self];
            });
        }
        return;
    } else {
        if ([self.delegate respondsToSelector:@selector(scannerDidAddDeviceInputSucceed:)]) {
            dispatch_main_async(^{
                [self.delegate scannerDidAddDeviceInputSucceed:self];
            });
        }
    }
    
    if (![self addMetadataOutputToCaptureSession:_captureSession]) {
        NSLog(@"failed to add metadata output to capture session");
        _status = YFSessionStatusSetupFailed;
        [_captureSession commitConfiguration];
        if ([self.delegate respondsToSelector:@selector(scannerDidSessionStatusChanged:)]) {
            dispatch_main_async(^{
                [self.delegate scannerDidSessionStatusChanged:self];
            });
        }
        return;
    } else {
        if ([self.delegate respondsToSelector:@selector(scannerDidAddMetadataOutputSucceed:)]) {
            [self.delegate scannerDidAddMetadataOutputSucceed:self];
        }
    }
    
    if (![self addVideoDataOutputToCaptureSession:_captureSession]) {
        NSLog(@"failed to add videoData output to capture session");
        _status = YFSessionStatusSetupFailed;
        [_captureSession commitConfiguration];
        if ([self.delegate respondsToSelector:@selector(scannerDidSessionStatusChanged:)]) {
            dispatch_main_async(^{
                [self.delegate scannerDidSessionStatusChanged:self];
            });
        }
        return;
    }
    
    _status = YFSessionStatusSetupSucceed;
    [_captureSession commitConfiguration];
    
    if ([self.delegate respondsToSelector:@selector(scannerDidSessionStatusChanged:)]) {
        dispatch_main_async(^{
            [self.delegate scannerDidSessionStatusChanged:self];
        });
    }
}

- (BOOL)addDefaultCameraInputToCaptureSession:(AVCaptureSession *)captureSession
{
    NSError *error;
    AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    
    if(error){
        NSLog(@"error configuring camera input: %@", [error localizedDescription]);
        return NO;
    } else {
        BOOL success = [self addInput:cameraDeviceInput toCaptureSession:captureSession];
        
        //先进行判断是否支持控制对焦,开启自动对焦功能，加快识别二维码
        if (cameraDeviceInput.device.isFocusPointOfInterestSupported &&[cameraDeviceInput.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [cameraDeviceInput.device lockForConfiguration:nil];
            [cameraDeviceInput.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [cameraDeviceInput.device unlockForConfiguration];
        }
        _captureDeviceInput = cameraDeviceInput;
        return success;
    }
}

- (BOOL)addMetadataOutputToCaptureSession:(AVCaptureSession *)captureSession {
    
    BOOL success = [self addOutput:_metadataOutput toCaptureSession:captureSession];
    if (success) {
        [_metadataOutput setMetadataObjectsDelegate:self queue:_metadataObjectsQueue];
        _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;
    }
    
    return success;
}

- (BOOL)addVideoDataOutputToCaptureSession:(AVCaptureSession *)captureSession {
    
    BOOL success = [self addOutput:_videoDataOutput toCaptureSession:captureSession];
    if (success) {
        [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    }
    
    return success;
}

- (BOOL)addInput:(AVCaptureDeviceInput *)input toCaptureSession:(AVCaptureSession *)captureSession
{
    if([captureSession canAddInput:input]){
        [captureSession addInput:input];
        return YES;
    } else {
        NSLog(@"can't add input: %@", [input description]);
    }
    return NO;
}


- (BOOL)addOutput:(AVCaptureOutput *)output toCaptureSession:(AVCaptureSession *)captureSession
{
    if([captureSession canAddOutput:output]){
        [captureSession addOutput:output];
        return YES;
    } else {
        NSLog(@"can't add output: %@", [output description]);
    }
    return NO;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSString *scannedResult = nil;
    AVMetadataObject *firstMetadata = metadataObjects.firstObject;
    if ([firstMetadata isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
        scannedResult = [(AVMetadataMachineReadableCodeObject *)firstMetadata stringValue];
    }
    
    //过滤无效的结果
    if (scannedResult == nil || [scannedResult isEqualToString:@""]) {
        return;
    }
    
    [self stopScanning];
    
    if (_scanSuccessResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _scanSuccessResult(scannedResult);
        });
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    if ([self.delegate respondsToSelector:@selector(scannerDidCaptureBrightnessSensitive:withBrightness:)]) {
        dispatch_main_async(^{
            [self.delegate scannerDidCaptureBrightnessSensitive:self withBrightness:brightnessValue];
        });
    }
}


#pragma mark - getters and setters
- (void)setMetadataObjectTypes:(NSArray<NSString *> *)metadataObjectTypes
{
    if (_metadataObjectTypes == metadataObjectTypes) {
        return;
    }
    
    if (metadataObjectTypes && metadataObjectTypes.count > 0) {
        _metadataObjectTypes = metadataObjectTypes;
    } else {
        _metadataObjectTypes = [self defaultMetaDataObjectTypes];
    }
    
    if (_status == YFSessionStatusUnSetup || _status == YFSessionStatusSetupFailed || _status == YFSessionStatusPemissionDenied) {
        return;
    }
    
    dispatch_async(_sessionQueue, ^{
        _metadataOutput.metadataObjectTypes = _metadataObjectTypes;
    });
}

-(NSArray<NSString *> *)metadataObjectTypes
{
    if (!_metadataObjectTypes) {
        _metadataObjectTypes = [self defaultMetaDataObjectTypes];
    }
    return _metadataObjectTypes;
}

- (void)setRectOfInterest:(CGRect)rectOfInterest {
    if (CGRectEqualToRect(rectOfInterest, CGRectZero)) {
        return;
    }
    dispatch_async(_sessionQueue, ^{
        _metadataOutput.rectOfInterest = rectOfInterest;
    });
}

- (NSArray *)defaultMetaDataObjectTypes
{
    NSMutableArray *types = [@[AVMetadataObjectTypeQRCode,
                               AVMetadataObjectTypeUPCECode,
                               AVMetadataObjectTypeCode39Code,
                               AVMetadataObjectTypeCode39Mod43Code,
                               AVMetadataObjectTypeEAN13Code,
                               AVMetadataObjectTypeEAN8Code,
                               AVMetadataObjectTypeCode93Code,
                               AVMetadataObjectTypeCode128Code,
                               AVMetadataObjectTypePDF417Code,
                               AVMetadataObjectTypeAztecCode] mutableCopy];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_0) {
        [types addObjectsFromArray:@[
                                     AVMetadataObjectTypeInterleaved2of5Code,
                                     AVMetadataObjectTypeITF14Code,
                                     AVMetadataObjectTypeDataMatrixCode
                                     ]];
    }
    
    return types;
}

@end
