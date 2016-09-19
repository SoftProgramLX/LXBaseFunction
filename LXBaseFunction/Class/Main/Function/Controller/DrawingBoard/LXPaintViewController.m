//
//  LXPaintViewController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/9/10.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXPaintViewController.h"
#import "LXPaintView.h"

@implementation LXPaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    
    LXPaintView *paintView = [[LXPaintView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:paintView];
}

@end
