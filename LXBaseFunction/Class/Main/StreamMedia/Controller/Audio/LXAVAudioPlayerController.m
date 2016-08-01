//
//  LXAVAudioPlayerController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/30.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXAVAudioPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface LXAVAudioPlayerController ()<AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
    NSTimer *timer;
    UIProgressView *pro[4];
    NSTimeInterval totalTime;
    NSInteger curdentIndex;
}
@property (nonatomic, weak)   UILabel *topPastTimeLabel;
@property (nonatomic, weak)   UISlider *topProgressSlider;
@property (nonatomic, weak)   UILabel *topRemainderLabel;
@property (nonatomic, weak)   UIImageView *imgView;
@property (nonatomic, strong) CABasicAnimation *imgAnima;

@end

@implementation LXAVAudioPlayerController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = globalBlackColor;
    self.title = @"明天过后";
    curdentIndex = 0;
    [self addAudioPlayer];
    [self setupAudio];
    [self createUI];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stop];
    [super viewDidDisappear:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //  返回前一个页面的时候释放内存
}

#pragma mark - Create view

- (void)addAudioPlayer
{
    //音乐播放器
    NSError *error=nil;
    //    NSURL *fileUrl = [LXHelpClass networkResourcesIntoLocalWithHttp:@"http://data.vod.itc.cn/?prod=app&new=/5/36/aUe9kB0906IvkI5UCpq11K.mp4" withLocalFile:@"test.mp3"];
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.fileNameArr[curdentIndex] ofType:nil]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    player.delegate = self;
    [player prepareToPlay];
    if(error){
        NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
        return;
    }
    //开启变速功能
    player.enableRate = YES;
    //开启音频变动功能
    player.meteringEnabled = YES;
    player.numberOfLoops = 0;
    [self play];
}

- (void)createUI
{
    //已播放时间
    UILabel *topPastTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 50, 40)];
    topPastTimeLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:topPastTimeLabel];
    self.topPastTimeLabel = topPastTimeLabel;
    
    //播放进度条
    UISlider *topProgressSlider = [[UISlider alloc] initWithFrame:CGRectMake(70, 20, kScreenWidth - 70*2, 40)];
    topProgressSlider.value = 0.0;
    [topProgressSlider addTarget:self action:@selector(progressSlider:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:topProgressSlider];
    self.topProgressSlider = topProgressSlider;
    
    //剩余播放时间
    UILabel *topRemainderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 20, 50, 40)];
    topRemainderLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:topRemainderLabel];
    self.topRemainderLabel = topRemainderLabel;
    
    //音乐背景图
    CGFloat proY = kScreenHeight - 64 - 300;
    CGFloat imgY = topProgressSlider.y + topProgressSlider.height + 10;
    CGFloat imgH = proY - imgY - 10;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-imgH)/2.0, imgY, imgH, imgH)];
    imgView.image = [LXHelpClass getEllipseImageWithImage:[UIImage imageNamed:@"zhangjie"]];
    [self.view addSubview:imgView];
    self.imgView = imgView;

    //给音乐背景图加旋转动画
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];//绕着z轴为矢量，进行旋转(@"transform.rotation.z"==@@"transform.rotation")
    anima.toValue = [NSNumber numberWithFloat:M_PI*2];
    anima.duration = 10.0f;
    anima.repeatCount = MAXFLOAT;
    [imgView.layer addAnimation:anima forKey:@"rotateAnimation"];
    self.imgAnima = anima;
    
    for (int i = 0; i < 4; i++) {
        pro[i] = [[UIProgressView alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0 + 50*i, proY + 150, 150, 20)];
        //锚点，设置它绕哪一个点旋转
        pro[i].layer.anchorPoint = CGPointMake(0.0, 0.5);
        //旋转
        pro[i].transform = CGAffineTransformMakeRotation(270 * M_PI / 180);
        [self.view addSubview:pro[i]];
    }
    
    [self createBtn];
    
    //频率
    UILabel *rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, kScreenHeight - 64 - 80 - 15, kScreenWidth - 120, 50)];
    rateLabel.text = @"频率";
    rateLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:rateLabel];
    
    UISlider * volSlider = [[UISlider alloc] initWithFrame:CGRectMake(80, kScreenHeight - 64 - 80, kScreenWidth - 120, 20)];
    volSlider.minimumValue = 0.5;
    volSlider.maximumValue = 2.0;
    volSlider.value = 1.0;
    [volSlider addTarget:self action:@selector(volSlider:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:volSlider];
    
    //音量
    UILabel *soundLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, kScreenHeight - 64 - 40 - 15, kScreenWidth - 120, 50)];
    soundLabel.text = @"音量";
    soundLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:soundLabel];
    
    UISlider *bottomSoundSlider = [[UISlider alloc] initWithFrame:CGRectMake(80, kScreenHeight - 64 - 40, kScreenWidth - 120, 20)];
    bottomSoundSlider.value = 0.3;
    [bottomSoundSlider addTarget:self action:@selector(bottomSoundSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:bottomSoundSlider];
}

- (void)createBtn
{
    CGFloat btnY = kScreenHeight - 64 - 140 - 50;
    //上一曲
    UIButton * lastSongBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lastSongBtn.frame = CGRectMake(10, btnY, 60, 50);
    [lastSongBtn addTarget:self action:@selector(lastSongBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [lastSongBtn setTitle:@"上一曲" forState:UIControlStateNormal];
    [self.view addSubview:lastSongBtn];
    
    //下一曲
    UIButton * nextSongBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nextSongBtn.frame = CGRectMake(kScreenWidth-70, btnY, 60, 50);
    [nextSongBtn addTarget:self action:@selector(nextSongBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [nextSongBtn setTitle:@"下一曲" forState:UIControlStateNormal];
    [self.view addSubview:nextSongBtn];
    
    //播放
    UIButton * play = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    play.frame = CGRectMake(20, btnY+50, 80, 50);
    [play addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [play setTitle:@"play" forState:UIControlStateNormal];
    [self.view addSubview:play];
    
    //暂停
    UIButton * pause = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    pause.frame = CGRectMake(120, btnY+50, 80, 50);
    [pause addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [pause setTitle:@"pause" forState:UIControlStateNormal];
    [self.view addSubview:pause];
    
    //停止
    UIButton * stop = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    stop.frame = CGRectMake(220, btnY+50, 80, 50);
    [stop addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [stop setTitle:@"stop" forState:UIControlStateNormal];
    [self.view addSubview:stop];
}

#pragma mark - Observer

//播放完成时调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放完成！");
    [self nextSongBtnClicked:nil];
    //根据实际情况播放完成可以将会话关闭，其他音频应用继续播放
//    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

//刷新
- (void)refresh
{
    self.topProgressSlider.value = player.currentTime / player.duration;
    //刷新以下当前频率，必须要刷新
    [player updateMeters];
    
    //  获取当前时间
    NSTimeInterval currentTime = player.currentTime;
    self.topPastTimeLabel.text = [LXHelpClass getTimeByProgress:currentTime];
    self.topRemainderLabel.text = [LXHelpClass getTimeByProgress:totalTime - currentTime];
    
    float f[4];
    f[0] = [player peakPowerForChannel:0];
    f[1] = [player peakPowerForChannel:1];
    f[2] = [player averagePowerForChannel:0];
    f[3] = [player averagePowerForChannel:1];
    for (int i = 0; i < 4; i++) {
        pro[i].progress = f[i] / -100.0;
    }
}

/**
 *  一旦输出改变则执行此方法
 *
 *  @param notification 输出改变通知对象
 */
- (void)routeChange:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    int changeReason = [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    NSLog(@"changeReason:%d", changeReason);
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription = dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription = [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            [self pause];
        }
    } else if (changeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        [self play];
    }
}

#pragma mark - Enent response

- (void)lastSongBtnClicked:(UIButton *)sender
{
    curdentIndex = (--curdentIndex + self.fileNameArr.count) % self.fileNameArr.count;
    self.title = self.fileNameArr[curdentIndex];
    [self stop];
    player = nil;
    [self addAudioPlayer];
}

- (void)nextSongBtnClicked:(UIButton *)sender
{
    curdentIndex = (++curdentIndex) % self.fileNameArr.count;
    self.title = self.fileNameArr[curdentIndex];
    [self stop];
    player = nil;
    [self addAudioPlayer];
}

- (void)play
{
    if (!player.isPlaying) {
        [self resumeLayer:self.imgView.layer];
    }
    
    [player play];
    //  总时间
    totalTime = player.duration;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
}

- (void)pause
{
    if (player.isPlaying) {
        [player pause];
        [timer invalidate];
        
        [self pauseLayer:self.imgView.layer];
    }
}

- (void)stop
{
    if (player.isPlaying) {
        [player stop];
        [timer invalidate];
        
        [self pauseLayer:self.imgView.layer];
        //    [self.imgView.layer removeAnimationForKey:@"rotateAnimation"];
    }
}

//进度
- (void)progressSlider:(UISlider *)slider
{
    player.currentTime = player.duration * slider.value;
}

//音量slider
- (void)bottomSoundSliderAction:(UISlider *)sender
{
    [player setVolume:sender.value];
    if (sender.value == 0) {
        NSLog(@"静音");
    }
}

//频率
- (void)volSlider:(UISlider *)slider
{
    player.rate = slider.value;
}

#pragma mark - Private methods

- (void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (void)setupAudio
{
    //设置后台播放模式
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    //添加通知，拔出耳机后暂停播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

@end


