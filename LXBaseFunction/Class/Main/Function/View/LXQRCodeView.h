//
//  LXQRCode.h
//  LXBaseFunction
//
//  Created by 李旭 on 16/9/21.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXQRCodeView : UIView

/**
 *  透明的区域
 */
@property (nonatomic, assign) CGSize transparentArea;

- (void)startScan;
- (void)stopScan;

@end
