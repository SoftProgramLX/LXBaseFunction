//
//  LXAVPlayVideoController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/28.
//  Copyright © 2016年 李旭. All rights reserved.
//

/**
 @"http://data.vod.itc.cn/?prod=app&new=/194/216/JBUeCIHV4s394vYk3nbgt2.mp4",
 @"http://data.vod.itc.cn/?prod=app&new=/5/36/aUe9kB0906IvkI5UCpq11K.mp4",
 @"http://data.vod.itc.cn/?prod=app&new=/10/66/eCGPkAewSVqy9P57hvB11D.mp4",
 @"http://data.vod.itc.cn/?prod=app&new=/125/206/g586XlZhJQBGTnFDS75cPF.mp4",
 
 @"http://www.radioswissclassic.ch/live/mp3.m3u"
 */

#import "LXAVPlayVideoController.h"
#import <AVFoundation/AVFoundation.h>

@interface LXAVPlayVideoController ()<UIGestureRecognizerDelegate>
{
    BOOL isPlay;
}
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, weak)   UILabel *topPastTimeLabel;
@property (nonatomic, weak)   UISlider *topProgressSlider;
@property (nonatomic, weak)   UILabel *topRemainderLabel;
@property (nonatomic, weak)   UIButton *playBtn;
@property (nonatomic, weak)   UISlider *bottomSoundSlider;

@property (nonatomic, assign) CGFloat totalMovieDuration;
@property (nonatomic, assign) CGFloat progressValue;

@end

@implementation LXAVPlayVideoController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"在线视频";
    self.view.backgroundColor = globalBlackColor;
    isPlay = YES;
    
    [self addAVPlayer];
    [self createUI];
    [self addNotificationCenters];
    [self addProgressObserver];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //  返回前一个页面的时候释放内存
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

#pragma mark - Create view

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

- (void)createUI
{
    //已播放时间
    UILabel *topPastTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 50, 40)];
    [self.view addSubview:topPastTimeLabel];
    topPastTimeLabel.textColor = [UIColor whiteColor];
    self.topPastTimeLabel = topPastTimeLabel;
    
    //播放进度条
    UISlider *topProgressSlider = [[UISlider alloc] initWithFrame:CGRectMake(70, 20, kScreenWidth - 70*2, 40)];
    topProgressSlider.value = 0.0;
    [topProgressSlider addTarget:self action:@selector(topSliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:topProgressSlider];
    self.topProgressSlider = topProgressSlider;
    
    //剩余播放时间
    UILabel *topRemainderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 20, 50, 40)];
    topRemainderLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:topRemainderLabel];
    self.topRemainderLabel = topRemainderLabel;
    
    //播放／暂停按钮
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2.0, kScreenHeight - 64 - 90, 100, 30)];
    [playBtn setTitle:@"Play/Pause" forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    self.playBtn = playBtn;
    
    //音量
    UISlider *bottomSoundSlider = [[UISlider alloc] initWithFrame:CGRectMake(80, kScreenHeight - 64 - 40, kScreenWidth - 120, 20)];
    bottomSoundSlider.value = 0.3;
    [bottomSoundSlider addTarget:self action:@selector(bottomSoundSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:bottomSoundSlider];
    self.bottomSoundSlider = bottomSoundSlider;
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

@end




