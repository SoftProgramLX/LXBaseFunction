//
//  LXPaintStep.h
//  LXBaseFunction
//
//  Created by 李旭 on 16/9/10.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXPaintStep : NSObject {
    
@public
    //路径
    NSMutableArray *pathPoints;
    //颜色
    CGColorRef color;
    //笔画粗细
    float strokeWidth;
}

@end
