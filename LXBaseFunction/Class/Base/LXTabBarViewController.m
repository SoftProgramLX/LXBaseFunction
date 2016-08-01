//
//  LXTabBarViewController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/25.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXTabBarViewController.h"
#import "LXStreamMediaController.h"
#import "LXOtherMoreController.h"

@interface LXTabBarViewController ()

@end

@implementation LXTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    
    LXStreamMediaController *testVC = [[LXStreamMediaController alloc] init];
    [self addOneChlildVc:testVC title:@"流媒体" navigationTitle:@"流媒体" imageName:nil selectedImageName:nil];
    
    [self addOneChlildVc:[[LXOtherMoreController alloc] init] title:@"常用功能" navigationTitle:@"常用功能" imageName:nil selectedImageName:nil];
    [self addOneChlildVc:[[UIViewController alloc] init] title:@"其它" navigationTitle:@"其它" imageName:nil selectedImageName:nil];
    
//    self.tabBar.backgroundImage = [UIImage imageNamed:@""];
    self.tabBar.translucent = NO;
}

- (void)addOneChlildVc:(UIViewController *)childVc title:(NSString *)title navigationTitle:(NSString *)navTitle imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    childVc.title = title;
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    NSMutableDictionary *selectedTextAttrs = [NSMutableDictionary dictionary];
    selectedTextAttrs[NSForegroundColorAttributeName] = globalRedColor;
    [childVc.tabBarItem setTitleTextAttributes:selectedTextAttrs forState:UIControlStateSelected];
    
    childVc.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = selectedImage;
    
    LXNavigationController *nav = [[LXNavigationController alloc] initWithRootViewController:childVc];
    nav.navigationItem.title = navTitle;
    
    [self addChildViewController:nav];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
