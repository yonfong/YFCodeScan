//
//  YFScanner.m
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import "YFScanner.h"

@interface YFScanner()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong, readwrite) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) dispatch_queue_t metadataObjectsQueue;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation YFScanner

@synthesize metadataObjectTypes = _metadataObjectTypes;

- (instancetype)init
{
    return [self initWithScanSuccess:nil];
}

- (instancetype)initWithScanSuccess:(void (^)(NSString * _Nonnull))success {
    if(self = [super init]){
        self.scanSuccessResult = success;
        _sessionQueue = dispatch_queue_create( "com.bluesky.scanner.session", DISPATCH_QUEUE_SERIAL );
        _metadataObjectsQueue = dispatch_queue_create( "com.bluesky.scanner.metadataObjects", DISPATCH_QUEUE_SERIAL );
        _captureSession = [[AVCaptureSession alloc] init];
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        _sessionSetupResult = YFSessionSetupResultSuccess;
    }
    return self;
}

- (void)startScanning
{
    [_captureSession startRunning];
}

- (void)stopScanning
{
    [_captureSession stopRunning];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    if (![self.captureDeviceInput.device isTorchModeSupported:torchMode]) {
        return;
    }
    
    [self.captureDeviceInput.device lockForConfiguration:nil];
    self.captureDeviceInput.device.torchMode = torchMode;
    [self.captureDeviceInput.device unlockForConfiguration];
}

- (AVCaptureVideoPreviewLayer *_Nullable)previewLayer
{
    if(!_previewLayer && _captureSession){
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    }
    return _previewLayer;
}

#pragma mark - Capture Session Setup
- (void)setupCaptureSession
{
    if (self.sessionSetupResult != YFSessionSetupResultSuccess) {
        return ;
    }
    
    [self.captureSession beginConfiguration];
    if(![self addDefaultCameraInputToCaptureSession:self.captureSession]){
        NSLog(@"failed to add camera input to capture session");
        self.sessionSetupResult = YFSessionSetupResultFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    
    if (![self addMetadataOutputToCaptureSession:self.captureSession]) {
        NSLog(@"failed to add metadata output to capture session");
        self.sessionSetupResult = YFSessionSetupResultFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    
    self.sessionSetupResult = YFSessionSetupResultSuccess;
    [self.captureSession commitConfiguration];
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
    
    BOOL success = [self addOutput:self.metadataOutput toCaptureSession:captureSession];
    if (success) {
        [self.metadataOutput setMetadataObjectsDelegate:self queue:self.metadataObjectsQueue];
        self.metadataObjectTypes = self.metadataObjectTypes;
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

#pragma mark - getters and setters
- (void)setMetadataObjectTypes:(NSArray<AVMetadataObjectType> *)metadataObjectTypes
{
    if (_metadataObjectTypes == metadataObjectTypes) {
        return;
    }
    
    if (metadataObjectTypes && metadataObjectTypes.count > 0) {
        _metadataObjectTypes = metadataObjectTypes;
    } else {
        _metadataObjectTypes = [self defaultMetaDataObjectTypes];
    }
    
    dispatch_async(self.sessionQueue, ^{
        self.metadataOutput.metadataObjectTypes = _metadataObjectTypes;
    });
}

-(NSArray<AVMetadataObjectType> *)metadataObjectTypes
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
    dispatch_async(self.sessionQueue, ^{
        self.metadataOutput.rectOfInterest = rectOfInterest;
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
