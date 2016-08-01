//
//  LXFreeStreamerAudioController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/31.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXFreeStreamerAudioController.h"
#import "FSAudioStream.h"

@interface LXFreeStreamerAudioController ()

@property (nonatomic,strong) FSAudioStream *audioStream;

@end

@implementation LXFreeStreamerAudioController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    
    [self.audioStream play];
}

/**
 *  取得网络地址
 *
 *  @return 文件路径
 */
- (NSURL *)getNetworkUrl
{
    NSString *urlStr = @"http://stream.srg-ssr.ch/rsc_de/mp3_128.m3u";
    NSURL *url = [NSURL URLWithString:urlStr];
    return url;
}
/**
 *  取得本地文件路径
 *
 *  @return 文件路径
 */
- (NSURL *)getFileUrl
{
    NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"mingtianguohou.mp3" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

/**
 *  创建FSAudioStream对象
 *
 *  @return FSAudioStream对象
 */
- (FSAudioStream *)audioStream
{
    if (!_audioStream) {
        NSURL *url = [self getNetworkUrl];
        //创建FSAudioStream对象
        _audioStream = [[FSAudioStream alloc] initWithUrl:url];
        _audioStream.onFailure = ^(FSAudioStreamError error,NSString *description){
            NSLog(@"播放过程中发生错误，错误信息：%@",description);
        };
        _audioStream.onCompletion = ^(){
            NSLog(@"播放完成!");
        };
        [_audioStream setVolume:0.5];//设置声音
    }
    return _audioStream;
}

@end



