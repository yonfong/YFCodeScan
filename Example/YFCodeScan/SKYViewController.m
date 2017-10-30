//
//  SKYViewController.m
//  YFCodeScan
//
//  Created by bluesky0109 on 10/14/2017.
//  Copyright (c) 2017 bluesky0109. All rights reserved.
//

#import "SKYViewController.h"
#import <YFCodeScan/YFScanPreviewView.h>
#import <YFCodeScan/YFScanner.h>

@interface SKYViewController ()

@property (nonatomic, strong) YFScanner *scanner;

@end

@implementation SKYViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scanner = [[YFScanner alloc] initWithScanSuccess:^(NSString *_Nonnull scannedResult) {
        NSLog(@"scanned code >> %@", scannedResult);
    }];

    [self configureInterface];
}

- (void)configureInterface {
    YFScanPreviewView *preview = [YFScanPreviewView defaultPreview];
    preview.frame = self.view.bounds;
    [self.view addSubview:preview];

    AVCaptureVideoPreviewLayer *previewLayer = [self.scanner previewLayer];

    previewLayer.frame = preview.layer.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [preview.layer insertSublayer:previewLayer atIndex:0];
    [self.scanner startScanning];
    [preview startScanningAnimation];
}

@end
