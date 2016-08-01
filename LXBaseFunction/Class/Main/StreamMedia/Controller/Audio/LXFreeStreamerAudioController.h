//
//  LXFreeStreamerAudioController.h
//  LXBaseFunction
//
//  Created by 李旭 on 16/3/31.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXFreeStreamerAudioController : UIViewController

@end

#warning 导入FSAudioStream的步骤
/*
 1.拷贝FreeStreamer中的FreeStreamer文件夹中的内容到项目中。
 2.添加FreeStreamer使用的类库：CFNetwork.framework、AudioToolbox.framework、AVFoundation.framework、libxml2.dylib、MediaPlayer.framework。
 3.如果引用libxml2.dylib编译不通过，需要在Xcode的Targets-Build Settings-Header Build Path中添加
     $(inherited) /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include $(SDKROOT)/usr/include/libxml2
 4.添加头文件 #import "FSAudioStream.h"
 **/
