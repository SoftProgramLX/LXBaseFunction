//
//  LXOpenSettingController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/9/22.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXOpenSettingController.h"

@interface LXOpenSettingController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy)   NSMutableArray *dataArr;
@property (nonatomic, weak)   UITableView *tableView;

@end

@implementation LXOpenSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self createUI];
}

- (void)initData
{
    _dataArr = [NSMutableArray array];
    
    NSString *email = [@"mailto:one@example.com,two@example.com?cc=bar@example.com&subject=测试&body=<b>email</b> body!" stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSArray *others = @[@[@"打电话", @"telprompt://123456789"], @[@"发短信", @"sms://123456789"], @[@"打开Safari", @"https://github.com/SoftProgramLX?tab=repositories"], @[@"发送邮件", email]];
    
    NSArray *settings = @[@[@"无线局域网", @"WIFI"], @[@"蓝牙", @"Bluetooth"], @[@"照片", @"Privacy&path=PHOTOS"], @[@"通用", @"General&path=Network"], @[@"通知", @"NOTIFICATIONS_ID"], @[@"关于本机", @"General&path=About"], @[@"日期与时间", @"General&path=DATE_AND_TIME"], @[@"iCloud", @"CASTLE"], @[@"定位服务", @"LOCATION_SERVICES"], @[@"音乐", @"MUSIC"], @[@"声音", @"Sounds"]];
    
    [self.dataArr addObject:others];
    [self.dataArr addObject:settings];
}

- (void)createUI
{
    self.title = @"打开系统功能";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) style:UITableViewStyleGrouped];
    tableView.backgroundColor = bgColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.dataArr[indexPath.section][indexPath.row][0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *urlStr = self.dataArr[indexPath.section][indexPath.row][1];
    if (indexPath.section == 1) {
        urlStr = [@"prefs:root=" stringByAppendingString:urlStr];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)self.dataArr[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

@end
