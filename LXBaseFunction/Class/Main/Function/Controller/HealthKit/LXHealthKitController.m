//
//  LXHealthKitController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/1.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXHealthKitController.h"
#import "LXHealthKitManager.h"

@interface LXHealthKitController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy)   NSMutableArray *modelArr;
@property (nonatomic, weak)   UITableView *tableView;

@end

@implementation LXHealthKitController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    
    [self createUI];
    [self downloadData];
}

- (void)setup
{
    self.view.backgroundColor = bgColor;
    self.title = @"健康";
    _modelArr = [NSMutableArray array];
}

#pragma mark - Loading data

- (void)downloadData
{
    LXHealthKitManager *myHealth = [LXHealthKitManager sharedLXHealthKitManager];
    myHealth.startDate = [LXHealthKitManager getTodayAgoWithDays:30];//获取今天之前三十天的步数
    [myHealth getStepCountWithSuccess:^(NSArray *results) {
        [self.modelArr setArray:results];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } withfailure:^(NSError *error) {
        NSLog(@"error:%@", error);
    }];
    
    [myHealth getQuantityType:HKQuantityTypeIdentifierHeight withSuccess:^(NSArray *results) {
        for (HKQuantitySample *sample in results) {
            NSLog(@"%@ \n%@ -- %@   %@", sample.quantityType, sample.startDate, sample.endDate, sample.quantity);
        }
    } withfailure:^(NSError *error) {
        NSLog(@"error:%@", error);
    }];
}

#pragma mark - Create view

- (void)createUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
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
    
    LXHealthStepModel *stepModel = self.modelArr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:    %8ld 步", [stepModel.startDateStr substringToIndex:10], stepModel.stepCount];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end



