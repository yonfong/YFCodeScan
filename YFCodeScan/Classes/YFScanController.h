//
//  YFScanController.h
//  Pods
//
//  Created by sky on 2017/10/16.
//

#import <UIKit/UIKit.h>
#import "YFScanner.h"
#import "YFScanPreviewView.h"

@interface YFScanController : UIViewController

@property (nonatomic, strong)YFScanner *scanner;

@property (nonatomic, strong)YFScanPreviewView *preivewView;

@property (nonatomic, copy)void (^scannedHandle)(NSString *scannedResult);

@property (nonatomic, assign) BOOL enableInterestRect;

- (void)startScanning;

- (void)stopScanning;

@end
