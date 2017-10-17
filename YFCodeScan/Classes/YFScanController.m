//
//  YFScanController.m
//  Pods
//
//  Created by sky on 2017/10/16.
//

#import "YFScanController.h"

@interface YFScanController ()

@property (nonatomic, strong, readwrite)YFScanner *scanner;

@end

@implementation YFScanController

@synthesize metadataObjectTypes = _metadataObjectTypes;

- (instancetype)init
{
    return [self initWithPreviewView:nil scanCodeType:YFScanCodeTypeQRAndBarCode];
}

- (instancetype)initWithPreviewView:(YFScanPreviewView *)previewView scanCodeType:(YFScanCodeType)scanCodeType
{
    if (self = [super init]) {
        _preivewView = previewView;
        _scanCodeType = scanCodeType;
        _enableInterestRect = YES;
    }
    return self;
}

+ (instancetype)scanCtrollerWith:(YFScanPreviewView *)previewView
{
    return [self scanCtrollerWith:previewView scanCodeType:YFScanCodeTypeQRAndBarCode];
}

+ (instancetype)scanCtrollerWith:(YFScanPreviewView *)previewView scanCodeType:(YFScanCodeType)scanCodeType
{
    return [[self alloc] initWithPreviewView:previewView scanCodeType:scanCodeType];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    YFScanPreviewView *previewView = self.preivewView;
    if (!previewView) {
        previewView = [[YFScanPreviewView alloc] initWithFrame:self.view.bounds];
        self.preivewView = previewView;
    }
    [self.view addSubview:self.preivewView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestCameraPemissionWithResult:^(BOOL granted) {
        if (granted) {
            if (!self.scanner) {
                CGRect interestRect = CGRectZero;
                if (self.enableInterestRect) {
                    interestRect = [self.preivewView getRectOfInterest];
                }
                self.scanner = [[YFScanner alloc] initWithScanCrop:interestRect scanSuccess:^(NSString * _Nonnull scannedResult) {
                    if (self.scannedHandle) {
                        self.scannedHandle(scannedResult);
                    }
                }];
                self.scanner.metadataObjectTypes = self.metadataObjectTypes;
            }
            [self startScanning];
        } else {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            NSString *message = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"中允许%@访问你的相机",appName];
            
            UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"相机被禁用" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:settingURL]) {
                    [[UIApplication sharedApplication] openURL:settingURL];
                }
            }];
            [alertCtl addAction:sureAction];
            
            [self presentViewController:alertCtl animated:YES completion:nil];
        }
    }];
    
    AVCaptureVideoPreviewLayer *previewLayer = [self.scanner previewLayer];
    if (previewLayer && ![self.preivewView.layer.sublayers containsObject:previewLayer]) {
        previewLayer.frame = self.preivewView.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.preivewView.layer insertSublayer:previewLayer atIndex:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopScanning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

    
    [self.preivewView startScanningAnimation];
}

- (void)startScanning
{
    [self.scanner startScanning];
    [self.preivewView startScanningAnimation];
}

- (void)stopScanning
{
    [self.scanner stopScanning];
    [self.preivewView stopScanningAnimation];
}


- (void)requestCameraPemissionWithResult:(void(^)( BOOL granted))completion
{
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                completion(YES);
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                completion(NO);
                break;
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (granted) {
                                                     completion(true);
                                                 } else {
                                                     completion(false);
                                                 }
                                             });
                                         }];
            }
                break;
                
        }
    }
}

#pragma mark - getters && setters
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
}

-(NSArray<AVMetadataObjectType> *)metadataObjectTypes
{
    if (!_metadataObjectTypes) {
        _metadataObjectTypes = [self defaultMetaDataObjectTypes];
    }
    return _metadataObjectTypes;
}

- (NSArray *)defaultMetaDataObjectTypes
{
    NSArray *qrCodeTypes = @[AVMetadataObjectTypeQRCode];
    NSArray *barCodeTypes = @[AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];

    if (self.scanCodeType == YFScanCodeTypeQRCode) {
        return qrCodeTypes;
    } else if (self.scanCodeType == YFScanCodeTypeBarCode) {
        return barCodeTypes;
    } else {
        return [[NSArray arrayWithArray:qrCodeTypes] arrayByAddingObjectsFromArray:barCodeTypes];
    }
}

@end
