//
//  LXCacheDataSingleton.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/1.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXCacheDataSingleton.h"
#import "SynthesizeSingleton.h"

@implementation LXCacheDataSingleton

SYNTHESIZE_SINGLETON_FOR_CLASS(LXCacheDataSingleton)

- (id)init
{
    self = [super init];
    if (self) {
        self.wifiStatus = 1;
        //获取当前网络状态
        [self getCurrentNet];
    }
    return self;
}

- (void)getCurrentNet
{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        self.wifiStatus = status;
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AFNetworkReachabilityStatus" object:[NSString stringWithFormat:@"%d", (int)status]];
    }];
    [mgr startMonitoring];
}

@end
