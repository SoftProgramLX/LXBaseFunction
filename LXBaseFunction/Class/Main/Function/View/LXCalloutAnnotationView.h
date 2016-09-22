//
//  LXCalloutAnnotationView.h
//  LXCLDemo
//
//  Created by 李旭 on 16/9/22.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "LXCalloutAnnotation.h"

@interface LXCalloutAnnotationView : MKAnnotationView

@property (nonatomic ,strong) LXCalloutAnnotation *annotation;

//从缓存取出标注视图
+(instancetype)calloutViewWithMapView:(MKMapView *)mapView;

@end
