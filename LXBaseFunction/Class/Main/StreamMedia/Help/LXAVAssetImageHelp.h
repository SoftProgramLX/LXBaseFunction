//
//  LXAVAssetImageController.h
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/5.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXAVAssetImageHelp : NSObject

/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */
+ (void)thumbnailImageRequest:(CGFloat)timeBySecond withURL:(NSString *)urlStr;

@end
