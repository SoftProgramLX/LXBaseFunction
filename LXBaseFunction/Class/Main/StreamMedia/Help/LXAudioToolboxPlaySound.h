//
//  LXAudioToolboxPlaySound.h
//  LXAudioToolbox
//
//  Created by 李旭 on 16/3/29.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SoundType){
    SoundTypeSystem = 1,
    SoundTypeLocalFile = 2,
};

@interface LXAudioToolboxPlaySound : NSObject

+ (void)playSoundEffect:(NSString *)soundName withSoundType:(NSInteger)type withAlongShake:(BOOL)shake;
+ (void)playSystemShake;

@end
