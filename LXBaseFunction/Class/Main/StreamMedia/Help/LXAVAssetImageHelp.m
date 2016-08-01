//
//  LXAVAssetImageController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/5.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXAVAssetImageHelp.h"
#import <AVFoundation/AVFoundation.h>

@implementation LXAVAssetImageHelp

+ (void)thumbnailImageRequest:(CGFloat)timeBySecond withURL:(NSString *)urlStr
{
    //创建URL
    NSURL *url = [self getNetworkUrl:urlStr];
    //根据url创建AVURLAsset
    AVURLAsset *urlAsset=[AVURLAsset assetWithURL:url];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    
    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError *error=nil;
    CMTime time=CMTimeMakeWithSeconds(timeBySecond, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actualTime;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
        return;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"截取视频缩略图成功\n请到我的相册查看" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    
    CMTimeShow(actualTime);
    UIImage *image=[UIImage imageWithCGImage:cgImage];//转化为UIImage
    //保存到相册
    UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil);
    CGImageRelease(cgImage);
}

+ (NSURL *)getNetworkUrl:(NSString *)urlStr
{
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}

@end



