//
//  LXNetWorkTool.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/26.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXNetWorkTool.h"
#import "SynthesizeSingleton.h"

@implementation LXNetWorkTool

SYNTHESIZE_SINGLETON_FOR_CLASS(LXNetWorkTool);

- (id)init
{
    self = [super init];
    if (self) {
        self.wifiType = 1;
        //获取当前网络状态
        [self getCurrentNet];
    }
    return self;
}

+ (void)getWithUrlString:(NSString *)urlStr withParam:(NSDictionary *)param success:(void (^)(NSDictionary * responseDic))success failure:(void (^)(NSError *error))failure
{
    if ([self sharedLXNetWorkTool].wifiType < 0) {
        NSError *error = nil;
        failure(error);
        return;
    }
    
    AFHTTPSessionManager *manager = [self afmanager];
    
    [manager GET:urlStr parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@", error);
    }];
}


+ (void)postWithUrlString:(NSString *)urlStr withParam:(NSDictionary *)param success:(void (^)(NSDictionary * responseDic))success failure:(void (^)(NSError *error))failure
{
    if ([self sharedLXNetWorkTool].wifiType < 0) {
        NSError *error = nil;
        failure(error);
        return;
    }
    
    AFHTTPSessionManager *manager = [self afmanager];
    
    [manager POST:urlStr parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        NSLog(@"%@", error);
    }];
}

+ (AFHTTPSessionManager*)afmanager
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.securityPolicy     = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer  = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json",nil];
    
    return manager;
}

- (void)getCurrentNet
{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        self.wifiType = status;
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




