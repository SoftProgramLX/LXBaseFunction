//
//  LXHealthKitManager.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/1.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXHealthKitManager.h"
#import "SynthesizeSingleton.h"
#import "LXHealthStepModel.h"

@interface LXHealthKitManager ()

@property (nonatomic, strong) HKHealthStore *healthStore;

@end

@implementation LXHealthKitManager

SYNTHESIZE_SINGLETON_FOR_CLASS(LXHealthKitManager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    if ([HKHealthStore isHealthDataAvailable]) {
        NSLog(@"此设备能使用健康数据");
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        [healthStore requestAuthorizationToShareTypes:[self shareTypes] readTypes:[self readTypes] completion:^(BOOL success, NSError *error) {
            if (success == YES)  {
                NSLog(@"授权成功");
            } else {
                NSLog(@"授权失败");
            }
        }];
        self.healthStore = healthStore;
    } else {
        NSLog(@"此设备不能使用健康数据");
    }
}

- (void)getStepCountWithSuccess:(void (^)(NSArray *))success withfailure:(void (^)(NSError *))failure
{
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:self.startDate endDate:self.endDate options:HKQueryOptionStrictEndDate];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 1;
    
    HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:self.startDate intervalComponents:dateComponents];
    
    collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
        
        NSMutableArray *returnArr = [NSMutableArray array];
        for (NSInteger i = result.statistics.count - 1; i >= 0; i--) {
            HKStatistics *statistic = result.statistics[i];
            for (HKSource *source in statistic.sources) {
                if ([source.name isEqualToString:[UIDevice currentDevice].name]) {
                    LXHealthStepModel *model = [[LXHealthStepModel alloc] init];
                    model.startDateStr = [self changeToDateStrWithDate:statistic.startDate];
                    model.endDateStr = [self changeToDateStrWithDate:statistic.endDate];
                    
                    HKQuantity *quantity = [statistic sumQuantityForSource:source];
                    if ([quantity isCompatibleWithUnit:[HKUnit countUnit]]) {
                        model.stepCount = (NSInteger)[quantity doubleValueForUnit:[HKUnit countUnit]];
                    }
                    [returnArr addObject:model];
                }
            }
        }
        
        if (!error) {
            if (success) {
                success(returnArr);
            }
        } else if (failure) {
            failure(error);
        }
    };
    [self.healthStore executeQuery:collectionQuery];
}

- (void)getQuantityType:(NSString *)identifier withSuccess:(void (^)(NSArray *))success withfailure:(void (^)(NSError *))failure
{
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:identifier];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:self.startDate endDate:self.endDate options:HKQueryOptionStrictEndDate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:YES];
    
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        if(!error) {
            if (success) {
                success(results);
            }
        } else if (failure) {
            failure(error);
        }
    }];
    [self.healthStore executeQuery:sampleQuery];
}

- (NSSet *)readTypes
{
    NSSet *readTypesSet =
    [NSSet setWithObjects:
     [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
     [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight], nil];
    return readTypesSet;
}

- (NSSet *)shareTypes
{
    NSSet *shareTypesSet =
    [NSSet setWithObjects:
     [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
     [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight], nil];
    return shareTypesSet;
}

- (NSDate *)changeToDateWithDateStr:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    if (!dateStr.length > 0) {
        dateStr = @"2016-01-01 00:00:00";
    }
    return [dateFormatter dateFromString:dateStr];
}

- (NSString *)changeToDateStrWithDate:(NSDate *)myDate
{
    NSDateFormatter*df = [[NSDateFormatter alloc] init];//格式化
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (!myDate) {
        myDate = [NSDate date];
    }
    return [df stringFromDate:myDate];
}

+ (NSDate *)getTodayAgoWithDays:(NSInteger)days
{
    LXHealthKitManager *health = [self sharedLXHealthKitManager];
    NSDate *endDate = [NSDate date];
    NSString *dateStr = [[health changeToDateStrWithDate:endDate] substringToIndex:10];
    NSDate *newEndDate = [health changeToDateWithDateStr:[dateStr stringByAppendingString:@" 00:00:00"]];
    
    NSTimeInterval timeInterval= [newEndDate timeIntervalSinceReferenceDate];
    timeInterval -= days * 3600 * 24;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
}

@end



