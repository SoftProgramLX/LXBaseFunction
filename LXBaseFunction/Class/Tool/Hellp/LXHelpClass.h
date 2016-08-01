//
//  LXHellpClass.h
//  LXBaseConfigProject
//
//  Created by lx on 16/1/10.
//  Copyright © 2016年 lx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface LXHelpClass : NSObject

+ (AppDelegate *)appDelegate;
+ (NSString *)devicePlatformString;
+ (NSString *)deviceString;
+ (NSDictionary *)getTestFileContent;
+ (CGFloat)calculateLabelighWithText:(NSString *)textStr withMaxSize:(CGSize)maxSize withFont:(CGFloat)font;
+ (void)setDeviceLandscape:(NSInteger)direction;
+ (NSString *)getTimeByProgress:(float)current;
+ (UIImage *)getEllipseImageWithImage:(UIImage *)originImage;
+ (NSURL *)networkResourcesIntoLocalWithHttp:(NSString *)httpStr withLocalFile:(NSString *)fileName;

@end



