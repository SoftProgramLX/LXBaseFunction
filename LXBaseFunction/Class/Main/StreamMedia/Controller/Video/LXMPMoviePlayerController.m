//
//  LXMPMoviePlayerController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/1.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXMPMoviePlayerController.h"
#import <MediaPlayer/MediaPlayer.h>

#define videoSizeRate (320/180.0)

@interface LXMPMoviePlayerController ()
{
    NSInteger direction;
    LXCacheDataSingleton *singleton;
    UILabel *remindLabel;
    UIButton *deleteBtn;
    CGRect backBtnFrame;
}
@property (nonatomic, strong) MPMoviePlayerController *mpPlayer;
@property (nonatomic, weak)   UIActivityIndicatorView *videoLoading;
@property (nonatomic, strong)   UIButton *backBtn;

@end

@implementation LXMPMoviePlayerController

#warning 支持自动横竖屏

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"在线视频";
    self.view.backgroundColor = bgColor;
    singleton = [LXCacheDataSingleton sharedLXCacheDataSingleton];
    direction = UIDeviceOrientationLandscapeLeft;
    
    [self addMPMoviePlayer];
    [self createUI];
    [self addNotificationCenters];
    //获取缩略图
    [self thumbnailImageRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.backBtn.hidden = NO;
    
    [LXHelpClass appDelegate].allowRotation = UIInterfaceOrientationMaskAll;
    
    [[LXHelpClass appDelegate].window addSubview:_backBtn];
    if (![self.mpPlayer isPreparedToPlay]) {
        self.mpPlayer.contentURL = self.mp4URL;
        [self.mpPlayer play];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!self.mpPlayer.isFullscreen) {
        self.backBtn.hidden = YES;
        [self.mpPlayer stop];
        [LXHelpClass appDelegate].allowRotation = UIInterfaceOrientationMaskPortrait;
    }
    self.navigationController.navigationBarHidden = NO;
    [super viewWillDisappear:YES];
}

- (void)dealloc
{
    [_backBtn removeFromSuperview];
    _backBtn = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Create view

- (void)addMPMoviePlayer
{
    MPMoviePlayerController *mpPlayer = [[MPMoviePlayerController alloc] init];
    mpPlayer.view.frame = CGRectMake(0, 20, kScreenWidth, kScreenWidth/videoSizeRate);
    mpPlayer.backgroundView.backgroundColor = [UIColor blackColor];
    mpPlayer.scalingMode = MPMovieScalingModeAspectFill;
    [self.view addSubview:mpPlayer.view];
    self.mpPlayer = mpPlayer;
}

- (void)createUI
{
    UIActivityIndicatorView *videoLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    videoLoading.frame = CGRectMake(0, 0, self.mpPlayer.view.width, self.mpPlayer.view.height);
    videoLoading.hidesWhenStopped = YES;
    [videoLoading startAnimating];
    [self.mpPlayer.view addSubview:_videoLoading = videoLoading];
    
    [self judgeNetwork];
    
    backBtnFrame = CGRectMake(-10, 20, 86, 44);
    UIButton *backBtn = [[UIButton alloc] initWithFrame:backBtnFrame];
    [backBtn setImage:[UIImage imageNamed:@"s_video"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"s_video_sel"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn = backBtn;
}

#pragma mark - Observer

- (void)enterFullscreen:(NSNotification *)noti
{
    [self fullScreen:YES];
    [LXHelpClass setDeviceLandscape:direction];
}

- (void)exitFullscreen:(NSNotification *)noti
{
    [self fullScreen:NO];
    
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient != UIDeviceOrientationPortrait) {
        direction = UIDeviceOrientationPortrait;
        [LXHelpClass setDeviceLandscape:direction];
    }
    direction = UIDeviceOrientationLandscapeLeft;
}

- (void)loadCompletion:(NSNotification *)noti
{
    [self.videoLoading stopAnimating];
}

- (void)orientChange:(NSNotification *)noti
{
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    switch (orient)
    {
        case UIDeviceOrientationPortrait:
            self.mpPlayer.fullscreen = NO;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            direction = UIDeviceOrientationLandscapeLeft;
            self.mpPlayer.fullscreen = YES;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            self.mpPlayer.fullscreen = NO;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            direction = UIDeviceOrientationLandscapeRight;
            self.mpPlayer.fullscreen = YES;
            break;
            
        default:  break;
    }
}

- (void)mediaPlayerPlaybackStateChange:(NSNotification *)notification
{
    switch (self.mpPlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放.");//注意播放完成时的状态是暂停
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放.");
            break;
        default:
            NSLog(@"播放状态:%li",self.mpPlayer.playbackState);
            break;
    }
}

- (void)mediaPlayerThumbnailRequestFinished:(NSNotification *)notification
{
    NSLog(@"视频截图完成.");
    UIImage *image=notification.userInfo[MPMoviePlayerThumbnailImageKey];
    //保存图片到相册(首次调用会请求用户获得访问相册权限)
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

#pragma mark - Enent response

- (void)backBtnClicked:(UIButton *)sender
{
    [LXHelpClass appDelegate].allowRotation = UIInterfaceOrientationMaskPortrait;
    [self.mpPlayer stop];
    [self.mpPlayer.view removeFromSuperview];
    self.mpPlayer = nil;
    [self deleteBtnClicked:sender];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteBtnClicked:(UIButton *)sender
{
    [sender removeFromSuperview];
    sender = nil;
    
    [remindLabel removeFromSuperview];
    remindLabel = nil;
}

#pragma mark - Private methods

- (void)addNotificationCenters
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    //进入全屏
    [defaultCenter addObserver:self selector:@selector(enterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    //退出全屏
    [defaultCenter addObserver:self selector:@selector(exitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    //加载完成开始播放
    [defaultCenter addObserver:self selector:@selector(loadCompletion:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
    //播放状态改变
    [defaultCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.mpPlayer];
    //屏幕旋转
    [defaultCenter addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    //每次截图成功会调用一次
    [defaultCenter addObserver:self selector:@selector(mediaPlayerThumbnailRequestFinished:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:self.mpPlayer];
}

-(void)thumbnailImageRequest
{
    //获取3.0s、10.0s的缩略图
    [self.mpPlayer requestThumbnailImagesAtTimes:@[@3.0,@10.0] timeOption:MPMovieTimeOptionExact];
}

- (void)judgeNetwork
{
    if (singleton.wifiStatus == 1) {
        remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, 40)];
        remindLabel.text = @"⚠正在使用2G/3G/4G网络，可能会产生网络流量";
        remindLabel.font = [UIFont systemFontOfSize:14];
        remindLabel.textColor = [UIColor whiteColor];
        remindLabel.backgroundColor = [UIColor blueColor];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:remindLabel];
        
        deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(remindLabel.width - 40, 10, 20, 20)];
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"icon_return_sel"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [remindLabel addSubview:deleteBtn];
        
        //3秒的时间
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC);
        //最少也要三秒以后才能执行block任务
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [remindLabel removeFromSuperview];
            remindLabel = nil;
        });
    }
}

- (void)fullScreen:(BOOL)whether
{
    if (whether) {
        _backBtn.frame = CGRectZero;
        remindLabel.frame = CGRectMake(0, 0, kScreenWidth, 40);
    } else {
        _backBtn.frame = backBtnFrame;
        remindLabel.frame = CGRectMake(0, 0, kScreenWidth, 40);
    }
}

@end

