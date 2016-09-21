//
//  LXCreateQRCodeController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/9/21.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXCreateQRCodeController.h"
#import "QRCodeGenerator.h"

@interface LXCreateQRCodeController () <UITextFieldDelegate>

@property (nonatomic, weak)   UITextField *testTextField;
@property (nonatomic, weak)   UIButton *createBtn;
@property (nonatomic, weak)   UIButton *saveBtn;
@property (nonatomic, weak)   UIImageView *testImageView;

@end

@implementation LXCreateQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createUI];
    if(IOS_VERSION>=7.0){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)createUI
{
    UITextField *testTextField = [[UITextField alloc] init];
    testTextField.placeholder = @"输入二维码内容";
    testTextField.delegate = self;
    testTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    ViewBorderRadius(testTextField, 5, 1, [UIColor blackColor]);
    [self.view addSubview:testTextField];
    self.testTextField = testTextField;
    
    UIButton *createBtn = [[UIButton alloc] init];
    [createBtn setTitle:@"生成二维码" forState:UIControlStateNormal];
    [createBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    createBtn.backgroundColor = [UIColor blueColor];
    [createBtn addTarget:self action:@selector(createBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    self.createBtn = createBtn;
    
    UIButton *saveBtn = [[UIButton alloc] init];
    [saveBtn setTitle:@"保存到相册" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveBtn.backgroundColor = [UIColor blueColor];
    [saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    self.saveBtn = saveBtn;
    
    UIImageView *testImageView = [[UIImageView alloc] init];
    testImageView.backgroundColor = [UIColor colorWithRed:0.429 green:0.810 blue:1.000 alpha:1.000];
    [self.view addSubview:testImageView];
    self.testImageView = testImageView;
    
    WeakSelf(self);
    
    [self.testTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.view.mas_top).offset(50);
        make.left.equalTo(weakself.view).offset(60);
        make.right.equalTo(weakself.view).offset(-60);
        make.height.equalTo(@(34));
    }];
    
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.testTextField.mas_bottom).offset(40);
        make.right.equalTo(weakself.saveBtn.mas_left).offset(-40);
        make.width.equalTo(@(100));
        make.height.equalTo(@(44));
        make.left.equalTo(weakself.view.mas_left).offset((kScreenWidth-100*2-40)/2.0);
    }];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.createBtn.mas_top);
        make.width.equalTo(weakself.createBtn.mas_width);
        make.height.equalTo(weakself.createBtn.mas_height);
    }];
    
    [self.testImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakself.createBtn.mas_bottom).offset(40);
        make.left.equalTo(weakself.view).offset(60);
        make.right.equalTo(weakself.view).offset(-60);
        make.height.equalTo(weakself.testTextField.mas_width);
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.testTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)createBtnClicked
{
    /*字符转二维码
     */
    self.testImageView.image = [QRCodeGenerator qrImageForString:self.testTextField.text imageSize:self.testImageView.bounds.size.width];
}

- (void)saveBtnClicked
{
    [self saveImageToAlbum];
}

//保存二维码图片到相册
-(void)saveImageToAlbum
{
    UIImageWriteToSavedPhotosAlbum(self.testImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

//保存图片回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *) error contextInfo:(void *)contextInfo
{
    if(error != NULL)
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请打开应用的相册权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
        }];
    }
    else
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"已保存到相册" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
        }];
    }
    
}

@end


