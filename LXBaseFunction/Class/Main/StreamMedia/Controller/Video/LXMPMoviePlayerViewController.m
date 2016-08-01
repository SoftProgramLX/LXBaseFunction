//
//  LXMPMoviePlayerViewController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/5.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXMPMoviePlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface LXMPMoviePlayerViewController ()

@property (nonatomic, strong) MPMoviePlayerViewController * player;

@end

@implementation LXMPMoviePlayerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:self.mp4URL];
    player.view.frame = CGRectMake(0, 0, kScreenWidth, 300);
    [self.view addSubview:player.view];
    self.player = player;
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake((kScreenWidth-100)/2.0, kScreenHeight - 64 - 100, 100, 50);
    [button setTitle:@"全屏播放" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonClick
{
    [self presentMoviePlayerViewControllerAnimated:self.player];
}

@end


