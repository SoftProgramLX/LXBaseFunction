//
//  LXMapController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/9/22.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXMapController.h"
#import "LXAnnotation.h"
#import "LXCalloutAnnotationView.h"

@interface LXMapController () <CLLocationManagerDelegate, MKMapViewDelegate>
{
    MKMapView *mapView;
    CLLocationManager *gpsManager;
    CLLocation *oldLocation;
    CLGeocoder *geocoder;
}
@end

@implementation LXMapController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    geocoder = [[CLGeocoder alloc]init];
    [self createUI];
    
    //开启定位，添加大头针，获取我的位置信息
    [self startLocation];
    [self addAnnotation];
    //    [self updateLocation:mapView.userLocation.location];
}

#pragma mark - Create view

- (void)createUI
{
    self.title = @"地图与定位";
    [self createHeaderView];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, kScreenHeight-64-44)];
    /*
     MKMapTypeStandard = 0,//标准卫星地图
     MKMapTypeSatellite,//卫星地图
     MKMapTypeHybrid//混合地图
     */
    mapView.delegate = self;
    mapView.mapType = MKMapTypeStandard;
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MKUserTrackingModeFollow;
    [self.view addSubview:mapView];
    
    gpsManager = [[CLLocationManager alloc] init];
    gpsManager.delegate = self;
    if([[[UIDevice currentDevice]systemVersion]doubleValue]>8.0){
        [gpsManager requestWhenInUseAuthorization];
    }else{
        [gpsManager requestAlwaysAuthorization];
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        gpsManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        gpsManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }else{
        NSLog(@"不能定位");
    }
}

- (void)createHeaderView
{
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    btnView.backgroundColor = [UIColor colorWithRed:0.669 green:1.000 blue:0.880 alpha:1.000];
    [self.view addSubview:btnView];
    
    NSArray *btnTitleArr = @[@"开始定位", @"停止定位", @"显示大头针", @"获取本地信息", @"Apple地图"];
    CGFloat btnW = (kScreenWidth)/btnTitleArr.count;
    for (int i = 0; i < btnTitleArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*btnW, 0, btnW, 44)];
        [btn setTitle:btnTitleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.tag = 100+i;
        if (i < 3) {
            btn.enabled = NO;
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        [btnView addSubview:btn];
    }
}

#pragma mark - Event response

- (void)btnClicked:(UIButton *)sender
{
    switch (sender.tag - 100) {
        case 0: {
            [self startLocation];
        } break;
            
        case 1: {
            [self stopLocation];
        } break;
            
        case 2: {
            [self removeCustomAnnotation];
            //            [self addAnnotation];
        } break;
            
        case 3: {
            [self getMyAddress];
        } break;
            
        case 4: {
            [self startAppleMap];
        } break;
            
        default: break;
    }
}

- (void) startLocation
{
    //开始定位
    [gpsManager startUpdatingLocation];
    //打开罗盘定位
    [gpsManager startUpdatingHeading];
}

- (void)stopLocation
{
    //定制定位
    [gpsManager stopUpdatingLocation];
    //关闭罗盘
    [gpsManager stopUpdatingHeading];
}

- (void) addAnnotation
{
    LXAnnotation *ann = [[LXAnnotation alloc] init];
    ann.title = @"北京";
    ann.subtitle = @"111";
    ann.coordinate=CLLocationCoordinate2DMake(40.002953, 116.022224);
    ann.image=[UIImage imageNamed:@"icon_pin_floating.png"];
    ann.icon=[UIImage imageNamed:@"icon_mark1.png"];
    ann.detail=@"详情地址介绍1";
    ann.rate=[UIImage imageNamed:@"icon_Movie_Star_rating.png"];
    
    LXAnnotation *ann2 = [[LXAnnotation alloc] init];
    ann2.title = @"北京";
    ann2.subtitle = @"222";
    ann2.coordinate=CLLocationCoordinate2DMake(40.202953, 116.423224);
    ann2.image=[UIImage imageNamed:@"icon_pin_floating.png"];
    ann2.icon=[UIImage imageNamed:@"icon_mark1.png"];
    ann2.detail=@"详情地址介绍2";
    ann2.rate=[UIImage imageNamed:@"icon_Movie_Star_rating.png"];
    
    LXAnnotation *ann3 = [[LXAnnotation alloc] init];
    ann3.title = @"北京";
    ann3.subtitle = @"333";
    ann3.coordinate=CLLocationCoordinate2DMake(40.002953, 116.324124);
    ann3.image=[UIImage imageNamed:@"icon_pin_floating.png"];
    ann3.icon=[UIImage imageNamed:@"icon_mark1.png"];
    ann3.detail=@"详情地址介绍3";
    ann3.rate=[UIImage imageNamed:@"icon_Movie_Star_rating.png"];
    
    [mapView addAnnotation:ann];
    [mapView addAnnotation:ann2];
    [mapView addAnnotation:ann3];
}

- (void)getMyAddress
{
    //反地理编码
    //根据坐标取得地名
    CLLocation *loca = [[CLLocation alloc] initWithLatitude:73 longitude:69];
    
    [geocoder reverseGeocodeLocation:loca completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        NSLog(@"我的位置详细信息:%@",placemark.addressDictionary);
        
        //根据地名确定地理坐标
        [geocoder geocodeAddressString:placemark.name completionHandler:^(NSArray *placemarks, NSError *error) {
            //取得第一个地标，地标中存储了详细的地址信息，注意：一个地名可能搜索出多个地址
            CLPlacemark *placemark=[placemarks firstObject];
            NSDictionary *addressDic= placemark.addressDictionary;
            NSLog(@"邮编:%@, 位置:%@, 详细信息:%@", placemark.postalCode, placemark.location, addressDic);
        }];
    }];
    
}

- (void)startAppleMap
{
    //搜索从北京市到天津市的驾车路线
    
    //根据“北京市”进行地理编码
    [geocoder geocodeAddressString:@"北京市" completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *clPlacemark1=[placemarks firstObject];//获取第一个地标
        NSLog(@"%@", clPlacemark1.location);
        NSLog(@"%f %f", [clPlacemark1.location coordinate].latitude, [clPlacemark1.location coordinate].longitude);
        MKPlacemark *mkPlacemark1=[[MKPlacemark alloc]initWithPlacemark:clPlacemark1];
        
        //注意地理编码一次只能定位到一个位置，不能同时定位，所在放到第一个位置定位完成回调函数中再次定位
        [geocoder geocodeAddressString:@"天津市" completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *clPlacemark2=[placemarks firstObject];//获取第一个地标
            MKPlacemark *mkPlacemark2=[[MKPlacemark alloc]initWithPlacemark:clPlacemark2];
            NSDictionary *options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
            MKMapItem *mapItem1=[[MKMapItem alloc]initWithPlacemark:mkPlacemark1];
            MKMapItem *mapItem2=[[MKMapItem alloc]initWithPlacemark:mkPlacemark2];
            [MKMapItem openMapsWithItems:@[mapItem1,mapItem2] launchOptions:options];
        }];
    }];
}

#pragma mark - SystemDelegate

#pragma mark - 地图控件代理方法

//显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[LXAnnotation class]]) {
        static NSString *key1=@"AnnotationKey1";
        MKAnnotationView *annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        //如果缓存池中不存在则新建
        if (!annotationView) {
            annotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
            //            annotationView.canShowCallout=true;//允许交互点击
            annotationView.calloutOffset=CGPointMake(0, 1);//定义详情视图偏移量
            annotationView.leftCalloutAccessoryView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_classify_cafe.png"]];//定义详情左侧视图
        }
        
        //修改大头针视图
        //重新设置此类大头针视图的大头针模型(因为有可能是从缓存池中取出来的，位置是放到缓存池时的位置)
        annotationView.annotation=annotation;
        annotationView.image=((LXAnnotation *)annotation).image;//设置大头针视图的图片
        
        return annotationView;
    }else if([annotation isKindOfClass:[LXCalloutAnnotation class]]){
        //对于作为弹出详情视图的自定义大头针视图无弹出交互功能（canShowCallout=false，这是默认值），在其中可以自由添加其他视图（因为它本身继承于UIView）
        LXCalloutAnnotationView *calloutView=[LXCalloutAnnotationView calloutViewWithMapView:mapView];
        calloutView.annotation=annotation;
        return calloutView;
    } else {
        return nil;
    }
}

/**
 *  选中大头针时触发
 *  点击一般的大头针LXAnnotation时添加一个大头针作为所点大头针的弹出详情视图
 */
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    LXAnnotation *annotation=view.annotation;
    if ([view.annotation isKindOfClass:[LXAnnotation class]]) {
        //添加详情大头针，渲染此大头针视图时将此模型对象赋值给自定义大头针视图完成自动布局
        LXCalloutAnnotation *annotation1=[[LXCalloutAnnotation alloc]init];
        annotation1.icon=annotation.icon;
        annotation1.detail=annotation.detail;
        annotation1.rate=annotation.rate;
        annotation1.coordinate=view.annotation.coordinate;
        [mapView addAnnotation:annotation1];
    }
}

//取消选中时触发
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self removeCustomAnnotation];
}

#pragma mark - 获取定位数据代理函数
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (int i = 0; i < locations.count; i++) {
        CLLocation *oneLocation = locations[i];
        if (oldLocation != oneLocation) {
            [self updateLocation:oneLocation];
            oldLocation = oneLocation;
            NSLog(@"经纬度是 %f  %f", [oneLocation coordinate].latitude, [oneLocation coordinate].longitude);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
}

#pragma mark - Private methods

//移除所用自定义大头针介绍
-(void)removeCustomAnnotation
{
    [mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[LXCalloutAnnotation class]]) {
            [mapView removeAnnotation:obj];
        }
    }];
}

//更新自己位置
- (void)updateLocation:(CLLocation *)location
{
    MKCoordinateRegion region;
    region.center.latitude = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude + 0.007;
    //地图显示大小
    region.span.latitudeDelta = 1;
    region.span.longitudeDelta = 1;
    
    [mapView setRegion:region animated:YES];
}

@end


