//
//  YFScanController.m
//  Pods
//
//  Created by sky on 2017/10/16.
//

#import "YFScanController.h"

static NSString *const kPodName = @"YFCodeScan";

// 主线程执行
NS_INLINE void dispatch_main_async(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@interface YFScanController () <YFScannerDelegate>

@property (nonatomic, strong, readwrite) YFScanner *scanner;

@property (nonatomic, assign) BOOL preIdleTimerDisabled;

@property (nonatomic, assign) BOOL preNavigationBarHidden;

@property (nonatomic, assign) UIStatusBarStyle preStatusBarStyle;

@property (nonatomic, strong) UIView *topBarView;

@property (nonatomic, weak) UIView *topBarTitleView;

@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UILabel *flashTipLabel;

@end

@implementation YFScanController

@synthesize metadataObjectTypes = _metadataObjectTypes;

#pragma mark - initial
- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

+ (instancetype)defaultScanCtroller {
    return [[self alloc] init];
}

- (void)commonInit {
    _topBarTitle = @"扫一扫";
    _preivewView = [YFScanPreviewView defaultPreview];
    _scanCodeType = YFScanCodeTypeQRAndBarCode;
    _enableInterestRect = YES;
    _enableBrightnessSensitive = YES;
}

#pragma mark - lifeCycle

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    _scanner = [[YFScanner alloc] init];
    _scanner.delegate = self;

    self.preIdleTimerDisabled = [UIApplication sharedApplication].idleTimerDisabled;
    self.preNavigationBarHidden = self.navigationController.navigationBarHidden;
    self.preStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;

    [self.view addSubview:self.preivewView];
    [self configTopBar];

    AVCaptureVideoPreviewLayer *previewLayer = [self.scanner previewLayer];
    previewLayer.frame = self.preivewView.layer.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.preivewView.layer insertSublayer:previewLayer atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    __weak __typeof(self) weakSelf = self;

    switch (self.scanner.status) {
        case YFSessionStatusSetupSucceed:
        case YFSessionStatusStop: {
            [weakSelf.scanner startScanning];
        } break;
        case YFSessionStatusSetupFailed: {
            dispatch_main_async(^{
                UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"无法捕获图像" message:@"" preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alertCtl addAction:sureAction];
                [weakSelf presentViewController:alertCtl animated:YES completion:nil];
            });
        } break;

        case YFSessionStatusPemissionDenied: {
            dispatch_main_async(^{
                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
                NSString *message = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"中允许%@"
                                                               @"访问你的相机",
                                                               appName];

                UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"相机被禁用" message:message preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                                       NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                       if ([[UIApplication sharedApplication] canOpenURL:settingURL]) {
                                                                           [[UIApplication sharedApplication] openURL:settingURL];
                                                                       }
                                                                   }];
                [alertCtl addAction:sureAction];

                [weakSelf presentViewController:alertCtl animated:YES completion:nil];
            });
        } break;
        default:
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self stopScanning];
    [UIApplication sharedApplication].idleTimerDisabled = self.preIdleTimerDisabled;
    self.navigationController.navigationBarHidden = self.preNavigationBarHidden;
    [UIApplication sharedApplication].statusBarStyle = self.preStatusBarStyle;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.scanner.status == YFSessionStatusSetupSucceed) {
        dispatch_main_async(^{
            [self.preivewView startScanningAnimation];
        });
    }
}

#pragma mark - config

- (void)configTopBar {
    CGFloat statusBarHeight = CGRectGetHeight(UIApplication.sharedApplication.statusBarFrame);
    CGFloat navBarHeight = 44;
    CGFloat topBarHeight = statusBarHeight + navBarHeight;
    
    [self.view addSubview:self.topBarView];
    self.topBarView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = NSDictionaryOfVariableBindings(_topBarView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topBarView]|" options:0 metrics:nil views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topBarView(==height)]" options:0 metrics:@{@"height":@(topBarHeight)} views:views]];

    NSBundle *bundle = [NSBundle bundleForClass:[YFScanController class]];
    NSURL *bundleURL = [bundle URLForResource:kPodName withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:bundleURL];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *normalImage = [UIImage imageNamed:@"yf_navigationBar_backArrow_normal" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *highlightedImage = [UIImage imageNamed:@"yf_navigationBar_backArrow_highlighted" inBundle:bundle compatibleWithTraitCollection:nil];
    [backButton setImage:normalImage forState:UIControlStateNormal];
    [backButton setImage:highlightedImage forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.topBarView addSubview:backButton];

    views = NSDictionaryOfVariableBindings(backButton);
    [self.topBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[backButton(==height)]" options:0 metrics:@{@"height":@(navBarHeight)} views:views]];

    [self.topBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButton(==height)]" options:0 metrics:@{@"height":@(navBarHeight)} views:views]];

    NSLayoutConstraint *buttonCenterY = [NSLayoutConstraint constraintWithItem:backButton
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.topBarView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:statusBarHeight/2];
    [self.topBarView addConstraint:buttonCenterY];

    UILabel *topBarTitleView = [[UILabel alloc] init];
    topBarTitleView.font = [UIFont systemFontOfSize:16];
    topBarTitleView.textColor = [UIColor whiteColor];
    topBarTitleView.text = self.topBarTitle;
    topBarTitleView.textAlignment = NSTextAlignmentCenter;
    [self.topBarView addSubview:topBarTitleView];
    self.topBarTitleView = topBarTitleView;

    topBarTitleView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *titleCenterX = [NSLayoutConstraint constraintWithItem:topBarTitleView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.topBarView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0];

    NSLayoutConstraint *titleCenterY = [NSLayoutConstraint constraintWithItem:topBarTitleView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.topBarView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1
                                                                     constant:statusBarHeight/2];

    [self.topBarView addConstraint:titleCenterX];
    [self.topBarView addConstraint:titleCenterY];
    [topBarTitleView sizeToFit];
}

- (void)backButtonClicked {
    if (self.navigationController.topViewController == self) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)startScanning {
    [self.scanner startScanning];
    [self.preivewView startScanningAnimation];
}

- (void)stopScanning {
    [self.scanner stopScanning];
    [self.preivewView stopScanningAnimation];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)showFlashLight:(BOOL)weakLight {
    if (!(self.scanner.status == YFSessionStatusRunning || self.scanner.status == YFSessionStatusStop)) {
        return;
    }

    if (self.flashButton.selected) {
        return;
    }

    if (!self.flashButton.hidden && weakLight) {
        return;
    }

    if (self.flashButton.hidden && !weakLight) {
        return;
    }

    self.flashButton.hidden = !weakLight;
    self.flashTipLabel.hidden = !weakLight;
    self.flashTipLabel.text = @"轻触照亮";
}

- (void)flashClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    AVCaptureTorchMode trochMode = sender.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    [self.scanner setTorchMode:trochMode];
    if (sender.selected) {
        self.flashTipLabel.text = @"轻触关闭";
    } else {
        self.flashTipLabel.text = @"轻触照亮";
    }
}

#pragma mark - YFScannerDelegate

- (void)scannerWillStartSetup:(YFScanner *_Nonnull)scanner {
    NSLog(@"%s", __FUNCTION__);
}

- (void)scannerDidAddDeviceInputSucceed:(YFScanner *_Nonnull)scanner {
    NSLog(@"%s", __FUNCTION__);
}

- (void)scannerDidAddMetadataOutputSucceed:(YFScanner *_Nonnull)scanner {
    NSLog(@"%s", __FUNCTION__);
    scanner.metadataObjectTypes = self.metadataObjectTypes;
}

- (void)scannerDidSessionStatusChanged:(YFScanner *_Nonnull)scanner {
    NSLog(@"%s", __FUNCTION__);
    if (scanner.status == YFSessionStatusSetupSucceed) {
        [scanner startScanning];
    }
}

- (void)scannerDidCaptureBrightnessSensitive:(YFScanner *_Nonnull)scanner withBrightness:(CGFloat)brightness {
    if (!_enableBrightnessSensitive) {
        return;
    }
    BOOL weakLight = brightness < 0;
    [self showFlashLight:weakLight];
}

#pragma mark - getters && setters
- (void)setMetadataObjectTypes:(NSArray<NSString *> *)metadataObjectTypes {
    if (_metadataObjectTypes == metadataObjectTypes) {
        return;
    }

    if (metadataObjectTypes && metadataObjectTypes.count > 0) {
        _metadataObjectTypes = metadataObjectTypes;
    } else {
        _metadataObjectTypes = [self defaultMetaDataObjectTypes];
    }

    self.scanner.metadataObjectTypes = _metadataObjectTypes;
}

- (NSArray<NSString *> *)metadataObjectTypes {
    if (!_metadataObjectTypes) {
        _metadataObjectTypes = [self defaultMetaDataObjectTypes];
    }
    return _metadataObjectTypes;
}

- (UIView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[UIView alloc] initWithFrame:CGRectZero];
        _topBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    return _topBarView;
}

- (void)setScannedHandle:(void (^)(NSString *))scannedHandle {
    if (_scannedHandle != scannedHandle) {
        _scannedHandle = scannedHandle;
        self.scanner.scanSuccessResult = scannedHandle;
    }
}

- (void)setScanCodeType:(YFScanCodeType)scanCodeType {
    if (_scanCodeType != scanCodeType) {
        _scanCodeType = scanCodeType;

        self.metadataObjectTypes = [self defaultMetaDataObjectTypes];
    }
}

- (UIButton *)flashButton {
    if (!_flashButton) {
        NSBundle *bundle = [NSBundle bundleForClass:[YFScanController class]];
        NSURL *bundleURL = [bundle URLForResource:kPodName withExtension:@"bundle"];
        bundle = [NSBundle bundleWithURL:bundleURL];

        UIImage *normalImage = [UIImage imageNamed:@"yf_flashlight_normal" inBundle:bundle compatibleWithTraitCollection:nil];
        UIImage *highlightedImage = [UIImage imageNamed:@"yf_flashlight_highlighted" inBundle:bundle compatibleWithTraitCollection:nil];

        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashButton setImage:normalImage forState:UIControlStateNormal];
        [_flashButton setImage:highlightedImage forState:UIControlStateSelected];
        _flashButton.hidden = YES;
        [_flashButton addTarget:self action:@selector(flashClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_flashButton];

        CGRect scanCropRect = [self.preivewView getScanCropRect];

        CGFloat bottomYPositionOffset = CGRectGetHeight(self.view.bounds) - scanCropRect.origin.y - CGRectGetHeight(scanCropRect);

        _flashButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_flashButton
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:-bottomYPositionOffset - 20 - 20]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_flashButton
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];
    }
    return _flashButton;
}

- (UILabel *)flashTipLabel {
    if (!_flashTipLabel) {
        _flashTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _flashTipLabel.textColor = [UIColor whiteColor];
        _flashTipLabel.font = [UIFont systemFontOfSize:12];
        _flashTipLabel.hidden = YES;
        _flashTipLabel.text = @"轻触照亮";
        [self.view addSubview:_flashTipLabel];

        CGRect scanCropRect = [self.preivewView getScanCropRect];

        CGFloat bottomYPositionOffset = CGRectGetHeight(self.view.bounds) - scanCropRect.origin.y - CGRectGetHeight(scanCropRect);

        _flashTipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_flashTipLabel
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:-bottomYPositionOffset - 20]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_flashTipLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];
    }
    return _flashTipLabel;
}

- (NSArray<NSString *> *)defaultMetaDataObjectTypes {
    NSArray *qrCodeTypes = @[AVMetadataObjectTypeQRCode];
    NSArray *barCodeTypes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode93Code];

    if (self.scanCodeType == YFScanCodeTypeQRCode) {
        return qrCodeTypes;
    } else if (self.scanCodeType == YFScanCodeTypeBarCode) {
        return barCodeTypes;
    } else {
        return [[NSArray arrayWithArray:qrCodeTypes] arrayByAddingObjectsFromArray:barCodeTypes];
    }
}

@end
