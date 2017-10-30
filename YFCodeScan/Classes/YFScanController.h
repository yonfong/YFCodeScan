//
//  YFScanController.h
//  Pods
//
//  Created by sky on 2017/10/16.
//

#import "YFScanPreviewView.h"
#import "YFScanner.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YFScanCodeType) { YFScanCodeTypeQRCode, YFScanCodeTypeBarCode, YFScanCodeTypeQRAndBarCode };

@interface YFScanController : UIViewController

@property (nonatomic, strong, readonly) YFScanner *scanner;

@property (nonatomic, strong) YFScanPreviewView *preivewView;

@property (nonatomic, copy) void (^scannedHandle)(NSString *scannedResult);

@property (nonatomic, assign) BOOL enableInterestRect;

@property (nonatomic, assign) YFScanCodeType scanCodeType;

@property (nonatomic, copy) NSArray<NSString *> *metadataObjectTypes;

@property (nonatomic, copy) NSString *topBarTitle;

+ (instancetype)defaultScanCtroller;

- (void)startScanning;

- (void)stopScanning;

@end
