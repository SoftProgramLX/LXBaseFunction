# LXBaseFunction
整理iOS开发中使用的各种流媒体和常用的高级功能
由于时间关系，目前只写了一部分功能，全部都采用的是系统方法，没用第三方，截图如下：<br>
![screen1.png](http://upload-images.jianshu.io/upload_images/301102-7691e1283cfa8114.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
<br>
![screen2.png](http://upload-images.jianshu.io/upload_images/301102-d9d730ce9a8be4ec.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)<br>

个人比较懒，不爱多写文字，直接上代码，哈哈。

###视频
系统用AVFoundation与MediaPlayer框架实现播放视频的方案。其中AVFoundation扩展性好，都需自定义功能，而MediaPlayer集成简单，但是样式不可扩展。<br>

1.AVFoundation使用AVPlayer播放视频，它属于view的layer层。其功能都需要自定义，如音量、暂停、播放时长等。代码如下：<br>

```
- (void)addAVPlayer
{
    self.playerItem = [AVPlayerItem playerItemWithURL:self.movieURL];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = CGRectMake(0, 70, kScreenWidth, 300);
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    layer.backgroundColor = [[UIColor blackColor] CGColor];
    [self.view.layer addSublayer:layer];
    [self.player play];
}
#pragma mark - Observer

//添加进度观察
- (void)addProgressObserver
{
    //  设置每秒执行一次
    __weak LXAVPlayVideoController *wSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue: NULL usingBlock:^(CMTime time) {
        //        NSLog(@"进度观察 + %f", wSelf.topProgressSlider.value);
        //  获取当前时间
        CMTime currentTime = wSelf.player.currentItem.currentTime;
        //  转化成秒数
        CGFloat currentPlayTime = (CGFloat)currentTime.value/currentTime.timescale;
        //  总时间
        CMTime totalTime = wSelf.playerItem.duration;
        //  转化成秒
        wSelf.totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
        
        wSelf.topProgressSlider.value = currentPlayTime/wSelf.totalMovieDuration;
        wSelf.progressValue = CMTimeGetSeconds(currentTime)/wSelf.totalMovieDuration;
        wSelf.topPastTimeLabel.text = [LXHelpClass getTimeByProgress:currentPlayTime];
        wSelf.topRemainderLabel.text = [LXHelpClass getTimeByProgress:wSelf.totalMovieDuration - currentPlayTime];
        
        //        NSLog(@"%f %f %f %f", wSelf.topProgressSlider.value, wSelf.totalMovieDuration, currentPlayTime, currentPlayTime/wSelf.totalMovieDuration);
    }];
}

//播放结束后的代理回调
- (void)moviePlayDidEnd:(NSNotification *)notify
{
    [self setMovieParse];
}

#pragma mark - Enent response

//播放进度
- (void)topSliderValueChangedAction:(UISlider *)sender
{
    NSLog(@"进度条进度 + %f", sender.value);
    double currentTime = floor(self.totalMovieDuration * sender.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);
    [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}

//音量slider
- (void)bottomSoundSliderAction:(UISlider *)sender
{
    [self.player setVolume:sender.value];
    self.bottomSoundSlider.value = sender.value;
    if (sender.value == 0) {
        NSLog(@"静音");
    }
}

//播放暂停按钮
- (void)playBtnClicked:(UIButton *)sender
{
    if (isPlay) {
        [self setMovieParse];
    } else {
        [self setMoviePlay];
    }
    
    isPlay ^= 1;
}

#pragma mark - Private methods

- (void)addNotificationCenters
{
    //  注册观察者用来观察，是否播放完毕
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)setMovieParse
{
    [self.player pause];
}

- (void)setMoviePlay
{
    [self.player play];
}
```
2.MediaPlayer框架提供MPMoviePlayerController与MPMoviePlayerViewController播放视频，它们区别就是MPMoviePlayerViewController里面包含了一个MPMoviePlayerController，另外MPMoviePlayerViewController可以看作是一个控制器播放视频的。系统已经为之集成好了音量、播放暂停等功能。<br>

* MPMoviePlayerController的使用

```objective-c
- (void)addMPMoviePlayer
{
    MPMoviePlayerController *mpPlayer = [[MPMoviePlayerController alloc] init];
    mpPlayer.view.frame = CGRectMake(0, 20, kScreenWidth, kScreenWidth/videoSizeRate);
    mpPlayer.backgroundView.backgroundColor = [UIColor blackColor];
    mpPlayer.scalingMode = MPMovieScalingModeAspectFill;
    [self.view addSubview:mpPlayer.view];
    self.mpPlayer = mpPlayer;
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
```

* MPMoviePlayerViewController的使用

```objective-c
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
```
###音频
系统也提供灵活性很强的AVAudioPlayer和集成快的MPMusicPlayerController播放音乐。
具体功能实现请查看源码，这里不做过多介绍。

###健康
这方面的资料比较少，只好查看官方文档。这里我只写了获取步数这个常用功能。HealthKit框架提供了许多获取健康数据的API。
```objective-c
LXHealthKitManager *myHealth = [LXHealthKitManager sharedLXHealthKitManager];
myHealth.startDate = [LXHealthKitManager getTodayAgoWithDays:30];//获取今天之前三十天的步数
[myHealth getStepCountWithSuccess:^(NSArray *results) {
    [self.modelArr setArray:results];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
} withfailure:^(NSError *error) {
    NSLog(@"error:%@", error);
}];
```
LXHealthKitManager的代码如下：
```objective-c

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    if ([HKHealthStore isHealthDataAvailable]) {
        NSLog(@"此设备能使用健康数据");
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        [healthStore requestAuthorizationToShareTypes:[self shareTypes] readTypes:[self readTypes] completion:^(BOOL success, NSError *error) {
            if (success == YES)  {
                NSLog(@"授权成功");
            } else {
                NSLog(@"授权失败");
            }
        }];
        self.healthStore = healthStore;
    } else {
        NSLog(@"此设备不能使用健康数据");
    }
}

- (void)getStepCountWithSuccess:(void (^)(NSArray *))success withfailure:(void (^)(NSError *))failure
{
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:self.startDate endDate:self.endDate options:HKQueryOptionStrictEndDate];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 1;
    
    HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:self.startDate intervalComponents:dateComponents];
    
    collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
        
        NSMutableArray *returnArr = [NSMutableArray array];
        for (NSInteger i = result.statistics.count - 1; i >= 0; i--) {
            HKStatistics *statistic = result.statistics[i];
            for (HKSource *source in statistic.sources) {
                if ([source.name isEqualToString:[UIDevice currentDevice].name]) {
                    LXHealthStepModel *model = [[LXHealthStepModel alloc] init];
                    model.startDateStr = [self changeToDateStrWithDate:statistic.startDate];
                    model.endDateStr = [self changeToDateStrWithDate:statistic.endDate];
                    
                    HKQuantity *quantity = [statistic sumQuantityForSource:source];
                    if ([quantity isCompatibleWithUnit:[HKUnit countUnit]]) {
                        model.stepCount = (NSInteger)[quantity doubleValueForUnit:[HKUnit countUnit]];
                    }
                    [returnArr addObject:model];
                }
            }
        }
        
        if (!error) {
            if (success) {
                success(returnArr);
            }
        } else if (failure) {
            failure(error);
        }
    };
    [self.healthStore executeQuery:collectionQuery];
}
```
<br>
源码请点击[github地址](https://github.com/SoftProgramLX/LXBaseFunction)下载。
---
QQ:2239344645    [我的github](https://github.com/SoftProgramLX?tab=repositories)<br>
