//
//  LXTestViewController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/25.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXStreamMediaController.h"
#import "LXAVPlayVideoController.h"
#import "LXAudioToolboxController.h"
#import "LXAVAudioPlayerController.h"
#import "LXAVAudioRecorderController.h"
#import "LXFreeStreamerAudioController.h"
#import "LXMPMoviePlayerController.h"
#import "LXMPMoviePlayerViewController.h"
#import "LXAVAssetImageHelp.h"
#import "LXUIImagePickerController.h"

@interface LXStreamMediaController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak)   UITableView *tableView;
@property (nonatomic, copy)   NSArray *showDataArr;
@property (nonatomic, copy)   NSArray *sectionTitleArr;

@end

@implementation LXStreamMediaController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;

    //AVAudioPlayer不支持加载网络媒体流，只能播放本地文件
    
    _sectionTitleArr = @[@"视频", @"音频", @"摄像头", @"其它"];
    _showDataArr =
  @[@[@"AVPlayer网络视频", @"MPMoviePlayerController网络视频", @"MPMoviePlayerViewController网络视频"],
    @[@"AVAudioPlayer本地音乐", @"MPMusicPlayerController播放音乐", @"FreeStreamer在线音乐", @"AudioToolbox音效", @"AVAudioRecorder录音"],
    @[@"UIImagePickerController摄像头", @"AVFoundation拍照和录制视频"],
    @[@"AVAssetImageGenerator生成缩略图"]];
    
    [self createUI];
}

#pragma mark - Create view

- (void)createUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 49) style:UITableViewStylePlain];
    tableView.backgroundColor = bgColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
} 

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = bgColor;
    }
    
    //没有实现的功能
    if ((indexPath.section == 1 && indexPath.row == 1) || (indexPath.section == 2 && indexPath.row == 1)) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.textLabel.text = self.showDataArr[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
            //视频
        case 0: {
            [self videoDidSelectRowAtIndexPath:indexPath];
        } break;
            
            //音频
        case 1: {
            [self audioDidSelectRowAtIndexPath:indexPath];
        } break;
            
            //摄像头
        case 2: {
            [self cameraDidSelectRowAtIndexPath:indexPath];
        } break;
            
            //其它
        case 3: {
            [self otherDidSelectRowAtIndexPath:indexPath];
        }
            
        default: break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.showDataArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.showDataArr[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *headerId = @"headerView";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerId];
    
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerId];
    }
    
    headerView.textLabel.text = self.sectionTitleArr[section];
    return headerView;
}

#pragma mark - Private methods

- (void)videoDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            //AVPlayer网络视频
        case 0: {
            LXAVPlayVideoController *vc = [[LXAVPlayVideoController alloc] init];
            vc.movieURL = [NSURL URLWithString:mp4Website1];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
            //MPMoviePlayerController网络视频
        case 1: {
            LXMPMoviePlayerController *vc = [[LXMPMoviePlayerController alloc] init];
            vc.mp4URL = [NSURL URLWithString:mp4Website3];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
            //MPMoviePlayerViewController网络视频
        case 2: {
            LXMPMoviePlayerViewController *vc = [[LXMPMoviePlayerViewController alloc] init];
            vc.mp4URL = [NSURL URLWithString:mp4Website3];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        default: break;
    }
}

- (void)audioDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            //AVAudioPlayer本地音乐
        case 0: {
            LXAVAudioPlayerController *vc = [[LXAVAudioPlayerController alloc] init];
            vc.fileNameArr = @[@"mingtianguohou.mp3", @"xiguan.mp3", @"myRecord.caf"];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
            //MPMusicPlayerController播放音乐
        case 1: {
        } break;
            
            //FreeStreamer在线音乐
        case 2: {
            [self.navigationController pushViewController:[[LXFreeStreamerAudioController alloc] init] animated:YES];
        } break;
            
            //AudioToolbox音效
        case 3: {
            [self.navigationController pushViewController:[[LXAudioToolboxController alloc] init] animated:YES];
        } break;
            
            //AVAudioRecorder录音
        case 4: {
            [self.navigationController pushViewController:[[LXAVAudioRecorderController alloc] init] animated:YES];
        } break;
            
        default: break;
    }
}

- (void)cameraDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            //AVAssetImageGenerator生成缩略图
        case 0: {
            LXUIImagePickerController *vc = [[LXUIImagePickerController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        default: break;
    }
}

- (void)otherDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            //AVAssetImageGenerator生成缩略图
        case 0: {
            [LXAVAssetImageHelp thumbnailImageRequest:15.0 withURL:mp4Website3];
        } break;
            
        default: break;
    }
}

@end



