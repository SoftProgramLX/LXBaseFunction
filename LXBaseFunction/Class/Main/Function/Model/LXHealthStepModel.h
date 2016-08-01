//
//  LXHealthStepModel.h
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/1.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXHealthStepModel : NSObject

@property (nonatomic, copy)   NSString *startDateStr;
@property (nonatomic, copy)   NSString *endDateStr;
@property (nonatomic, assign) NSInteger stepCount;

@end
