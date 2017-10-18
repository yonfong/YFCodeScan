//
//  SKYRootTableController.m
//  YFCodeScan_Example
//
//  Created by yongfeng on 2017/10/17.
//  Copyright © 2017年 bluesky0109. All rights reserved.
//

#import "SKYRootTableController.h"
#import <YFCodeScan/YFScanController.h>

@interface SKYRootTableController ()

@end

@implementation SKYRootTableController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellId = @"kTestCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];

    cell.textLabel.text = @"扫一扫";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YFScanController *scanCtl = [[YFScanController alloc] init];
    [self.navigationController pushViewController:scanCtl animated:YES];
}

@end
