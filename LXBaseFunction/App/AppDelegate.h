//
//  AppDelegate.h
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/25.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//默认不允许横屏，仅在全屏播放时允许横屏
@property (nonatomic, assign) NSUInteger allowRotation;

@end

