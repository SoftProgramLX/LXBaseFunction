//
//  LXZBarController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/9/21.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXZBarController.h"
#import "LXScanQRCodeController.h"
#import "LXCreateQRCodeController.h"

@interface LXZBarController ()

@end

@implementation LXZBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    
    self.title = @"二维码";
    
    UIButton *normalScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [normalScanBtn setTitle:@"常规扫描二维码" forState:UIControlStateNormal];
    [normalScanBtn setBackgroundColor:[UIColor blueColor]];
    [normalScanBtn addTarget:self action:@selector(normalScanQRCodeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:normalScanBtn];
    __weak __typeof(self) weakSelf = self;
    [normalScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).with.offset(100);
        make.size.mas_equalTo(CGSizeMake(150, 40));
    }];
    
    UIButton *customScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [customScanBtn setTitle:@"自定义扫描二维码" forState:UIControlStateNormal];
    [customScanBtn setBackgroundColor:[UIColor blueColor]];
    [customScanBtn addTarget:self action:@selector(customScanQRCodeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:customScanBtn];
    [customScanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).with.offset(200);
        make.size.mas_equalTo(CGSizeMake(150, 40));
    }];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [createBtn setTitle:@"生成二维码" forState:UIControlStateNormal];
    [createBtn setBackgroundColor:[UIColor blueColor]];
    [createBtn addTarget:self action:@selector(createQRCodeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    [createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).with.offset(300);
        make.size.mas_equalTo(CGSizeMake(150, 40));
    }];
}

- (void)customScanQRCodeView
{
    LXScanQRCodeController *scanQRCodeVC = [[LXScanQRCodeController alloc] init];
    [self.navigationController pushViewController:scanQRCodeVC animated:YES];
}

- (void)createQRCodeView
{
    LXCreateQRCodeController *createQRCodeVC = [[LXCreateQRCodeController alloc] init];
    [self.navigationController pushViewController:createQRCodeVC animated:YES];
}

- (void)normalScanQRCodeView
{
    //初始化相机控制器
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    //设置代理
    reader.readerDelegate = self;
    //基本适配
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    //二维码/条形码识别设置
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    //弹出系统照相机，全屏拍摄
    [self presentViewController:reader animated:YES completion:^{
        
    }];
}

#pragma mark - ZBarReaderDelegate
//扫描二维码的时候，识别成功会进入此方法，读取二维码内容
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol * symbol;
    for(symbol in results)
        break;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *result = symbol.data;
    
    NSLog(@"%@",result);
    
    //二维码扫描成功，弹窗提示
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"扫描成功" message:[NSString stringWithFormat:@"二维码内容:\n%@",result] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:^{
    }];
}

- (void)readerControllerDidFailToRead:(ZBarReaderController*) reader withRetry: (BOOL) retry
{
    
}

@end
