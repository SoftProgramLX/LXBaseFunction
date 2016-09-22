//
//  LXCalloutAnnotation.h
//  LXCLDemo
//
//  Created by 李旭 on 16/9/22.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface LXCalloutAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy,readonly) NSString *title;
@property (nonatomic, copy,readonly) NSString *subtitle;

//左侧图标
@property (nonatomic,strong) UIImage *icon;
//详情描述
@property (nonatomic,copy) NSString *detail;
//星级评价
@property (nonatomic,strong) UIImage *rate;

@end

