//
//  LXHealthKitManager.h
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/1.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "LXHealthStepModel.h"

@interface LXHealthKitManager : NSObject

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

+ (LXHealthKitManager *)sharedLXHealthKitManager;

- (void)getStepCountWithSuccess:(void (^)(NSArray *results))success withfailure:(void (^)(NSError *error))failure;
- (void)getQuantityType:(NSString *)identifier withSuccess:(void (^)(NSArray *))success withfailure:(void (^)(NSError *))failure;

//获取days天前的日期
+ (NSDate *)getTodayAgoWithDays:(NSInteger)days;

@end


