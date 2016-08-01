//
//  LXAVAudioRecorderController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/30.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXAVAudioRecorderController.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, BtnTypeName){
    BtnTypeNameDefault = -1,
    BtnTypeNameRecord,
    BtnTypeNamePause,
    BtnTypeNameResume,
    BtnTypeNameStop
};

#define kRecordAudioFile @"myRecord.caf"

@interface LXAVAudioRecorderController ()<AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）

@property (weak, nonatomic) UIProgressView *audioPower;//音频波动

@end

@implementation LXAVAudioRecorderController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    self.title = @"录音";
    
    [self createUI];
    [self setAudioSession];
}

#pragma mark - Create view

- (void)createUI
{
    UIProgressView *audioPower = [[UIProgressView alloc] initWithFrame:CGRectMake(globalAlignMargin, 200, kScreenWidth - 2*globalAlignMargin, 20)];
    [self.view addSubview:audioPower];
    self.audioPower = audioPower;
    
    NSArray *btnNameArr = @[@"record", @"pause", @"resume", @"stop"];
    CGFloat tap = (kScreenWidth-4*60 - 2*globalAlignMargin)/3.0 + 60;
    for (int i = 0; i < btnNameArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(globalAlignMargin + i*tap, kScreenHeight - 64 - 70, 60, 40)];
        
        btn.backgroundColor = [UIColor grayColor];
        btn.tag = i;
        [btn setTitle:btnNameArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

#pragma mark - SystemDelegate

/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
    NSLog(@"录音完成!");
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    [self.audioPower setProgress:progress];
}

#pragma mark - Enent response

- (void)btnClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case BtnTypeNameRecord:
        case BtnTypeNameResume: {
            if (![self.audioRecorder isRecording]) {
                [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
                self.timer.fireDate = [NSDate distantPast];
            }
        } break;
            
        case BtnTypeNamePause: {
            if ([self.audioRecorder isRecording]) {
                [self.audioRecorder pause];
                self.timer.fireDate = [NSDate distantFuture];
            }
        } break;
            
        case BtnTypeNameStop: {
            [self.audioRecorder stop];
            self.timer.fireDate = [NSDate distantFuture];
            self.audioPower.progress=0.0;
        } break;
            
        default: break;
    }
}

#pragma mark - Private methods

/**
 *  设置音频会话
 */
-(void)setAudioSession
{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
- (NSURL *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

#pragma mark - Setter and getter

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[self getSavePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end




