//
//  LXOtherMoreController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/1.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXOtherMoreController.h"
#import "LXHealthKitController.h"
#import "LXMasonryController.h"
#import "LXPaintViewController.h"
#import "LXZBarController.h"
#import "LXMapController.h"
#import "LXOpenSettingController.h"

@interface LXOtherMoreController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak)   UITableView *tableView;
@property (nonatomic, copy)   NSArray *showDataArr;

@end

@implementation LXOtherMoreController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    
    _showDataArr = @[@"运动步数", @"Masonry约束", @"画板", @"二维码", @"地图", @"打开系统功能"];
    
    [self createUI];
}

#pragma mark - Create view

- (void)createUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 49) style:UITableViewStylePlain];
    tableView.backgroundColor = bgColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = bgColor;
    }
    cell.textLabel.text = self.showDataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            LXHealthKitController *vc = [[LXHealthKitController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        case 1: {
            LXMasonryController *vc = [[LXMasonryController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        case 2: {
            LXPaintViewController *vc = [[LXPaintViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        case 3: {
            LXZBarController *vc = [[LXZBarController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        case 4: {
            LXMapController *vc = [[LXMapController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        case 5: {
            LXOpenSettingController *vc = [[LXOpenSettingController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        default: break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showDataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end



