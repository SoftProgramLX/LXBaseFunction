//
//  LXAudioToolboxController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/29.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXAudioToolboxController.h"
#import "LXAudioToolCaseController.h"
#import "LXAudioToolboxPlaySound.h"

@interface LXAudioToolboxController ()

@end

@implementation LXAudioToolboxController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"音效";
    self.view.backgroundColor = bgColor;
    
#warning 模拟器不支持播放系统声音和震动
    NSArray *textArr = @[@"播放音效", @"播放音效并震动", @"播放震动", @"便携式电子琴"];
    for (int i = 0; i < textArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30 + i*50, kScreenWidth - 40, 40)];
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:textArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        btn.tag = 1000 + i;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)btnClicked:(UIButton *)sender
{
    switch (sender.tag - 1000) {
        case 0: {
            [LXAudioToolboxPlaySound playSoundEffect:@"new-mail.caf" withSoundType:SoundTypeSystem withAlongShake:NO];
        } break;
            
        case 1: {
            [LXAudioToolboxPlaySound playSoundEffect:@"sms-received1.caf" withSoundType:SoundTypeSystem withAlongShake:YES];
        } break;
            
        case 2: {
            [LXAudioToolboxPlaySound playSystemShake];
        } break;
            
        case 3: {
            [self.navigationController pushViewController:[[LXAudioToolCaseController alloc] init] animated:YES];
        } break;
            
        default: break;
    }
}

@end



