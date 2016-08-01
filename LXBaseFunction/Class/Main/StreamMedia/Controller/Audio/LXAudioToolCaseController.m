//
//  LXAudioToolCaseController.m
//  LXAudioToolbox
//
//  Created by 李旭 on 16/3/29.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXAudioToolCaseController.h"
#import "LXAudioToolboxPlaySound.h"

@interface LXAudioToolCaseController ()

@end

@implementation LXAudioToolCaseController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    
    
    [self enterFullScreen];
    [self createUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self exitFullScreen];
    
    [super viewWillDisappear:YES];
}

#pragma mark - Create view

- (void)createUI
{
    UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 44)];
    bgImg.image = [UIImage imageNamed:@"pianoBackground"];
    [self.view addSubview:bgImg];
    
    UIView *btnBGView = [[UIView alloc] initWithFrame:CGRectMake(40, 120, 320, 140)];
    btnBGView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:btnBGView];
    
    NSArray *soundBtnTitle = @[@"Do", @"Re", @"Mi", @"Fa", @"So", @"La", @"Si"];
    CGFloat soundBtnW = btnBGView.width/7.0;
    for (int i = 0; i < 7; i++) {
        UIButton *soundBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*soundBtnW, 0, soundBtnW, btnBGView.height)];
        [soundBtn setTitle:soundBtnTitle[i] forState:UIControlStateNormal];
        [soundBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [soundBtn setBackgroundImage:[UIImage imageNamed:@"keyBackground01"] forState:UIControlStateNormal];
        soundBtn.tag = 1000 + i;
        [soundBtn addTarget:self action:@selector(soundBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnBGView addSubview:soundBtn];
    }
    
    NSArray *cahrBtnTitle = @[@"C", @"D", @"E", @"F", @"G"];
    CGFloat charBtnW = btnBGView.width/7.0 - 20;
    for (int i = 0; i < 5; i++) {
        CGFloat charBtnX = (soundBtnW - charBtnW/2.0) + i*soundBtnW + soundBtnW * (i/3);
        UIButton *charBtn = [[UIButton alloc] initWithFrame:CGRectMake(charBtnX, 0, charBtnW, btnBGView.height - 55)];
        [charBtn setTitle:cahrBtnTitle[i] forState:UIControlStateNormal];
        [charBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [charBtn setBackgroundImage:[UIImage imageNamed:@"keyBackground02"] forState:UIControlStateNormal];
        charBtn.tag = 2000 + i;
        [charBtn addTarget:self action:@selector(charBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnBGView addSubview:charBtn];
    }
}

#pragma mark - Enent response

- (void)soundBtnClicked:(UIButton *)sender
{
    NSString *audioFile = [NSString stringWithFormat:@"00%ld.mp3", sender.tag-1000 + 1];
    [LXAudioToolboxPlaySound playSoundEffect:audioFile withSoundType:SoundTypeLocalFile withAlongShake:NO];
}

- (void)charBtnClicked:(UIButton *)sender
{
    unichar ch = 'C';
    NSInteger index = (sender.tag-2000) + ch;
    NSString *audioFile = [NSString stringWithFormat:@"%c.mp3", (char)index];
    [LXAudioToolboxPlaySound playSoundEffect:audioFile withSoundType:SoundTypeLocalFile withAlongShake:NO];
}

#pragma mark - Private methods

- (void)enterFullScreen
{
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationLandscapeRight || orient == UIDeviceOrientationLandscapeLeft) {
        [LXHelpClass appDelegate].allowRotation = UIInterfaceOrientationMaskPortrait;
        [LXHelpClass setDeviceLandscape:UIDeviceOrientationPortrait];
    }
    [LXHelpClass appDelegate].allowRotation = UIInterfaceOrientationMaskLandscapeRight;
    [LXHelpClass setDeviceLandscape:UIDeviceOrientationLandscapeLeft];
}


- (void)exitFullScreen
{
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationPortrait || orient == UIDeviceOrientationPortraitUpsideDown) {
        [LXHelpClass appDelegate].allowRotation = UIInterfaceOrientationMaskLandscapeRight;
        [LXHelpClass setDeviceLandscape:UIInterfaceOrientationMaskLandscapeLeft];
    }
    
    [LXHelpClass appDelegate].allowRotation = UIInterfaceOrientationMaskPortrait;
    [LXHelpClass setDeviceLandscape:UIDeviceOrientationPortrait];
}

@end


