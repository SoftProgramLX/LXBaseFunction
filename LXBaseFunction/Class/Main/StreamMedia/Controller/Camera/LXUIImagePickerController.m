//
//  LXUIImagePickerController.m
//  LXBaseFunction
//
//  Created by 李旭 on 16/4/5.
//  Copyright © 2016年 李旭. All rights reserved.
//

#import "LXUIImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, LXImagePickerSourceType){
    LXImagePickerSourceTypeDefault = 0,
    LXImagePickerSourceTypeCamera,
    LXImagePickerSourceTypeVideo,
    LXImagePickerSourceTypeLibrary
};

@interface LXUIImagePickerController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (assign,nonatomic) LXImagePickerSourceType sourceType;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, weak)   UIImageView *photo;//照片展示视图
@property (nonatomic, strong) AVPlayer *player;//播放器，用于录制完视频后播放视频

@end

@implementation LXUIImagePickerController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = bgColor;
    
    [self createUI];
}

#pragma mark - Create view

- (void)createUI
{
    NSArray *btnTitle = @[@"照片", @"视频", @"相册库"];
    for (int i = 0; i < btnTitle.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20 + i*((kScreenWidth-2*20-3*80)/2.0 + 80), 20, 80, 40)];
        btn.backgroundColor = [UIColor redColor];
        btn.tag = 1001+i;
        [btn setTitle:btnTitle[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(takeClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64 - 420, kScreenWidth, 400)];
    imgView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:imgView];
    self.photo = imgView;
}

#pragma mark - SystemDelegate

//完成
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        [self.photo setImage:image];//显示照片
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"取消");
    [self dismissViewControllerAnimated:YES completion:nil];
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    } else {
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        _player=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame = self.photo.bounds;
        [self.photo.layer addSublayer:playerLayer];
        [_player play];
    }
}

#pragma mark - Enent response

//点击拍照按钮
- (void)takeClick:(UIButton *)sender
{
    if (self.sourceType != sender.tag - 1000) {
        self.imagePicker = nil;
        self.sourceType = sender.tag - 1000;
    }
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - Private methods

- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker=[[UIImagePickerController alloc]init];
        _imagePicker.allowsEditing=YES;//允许编辑
        _imagePicker.delegate=self;//设置代理，检测操作
        
        if (self.sourceType == LXImagePickerSourceTypeLibrary) {
            _imagePicker.mediaTypes=@[(NSString *)kUTTypeImage];
            _imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;//设置image picker的来源，这里设置为摄像头
            _imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
            if (self.sourceType == LXImagePickerSourceTypeCamera) {
                _imagePicker.mediaTypes=@[(NSString *)kUTTypeImage];
                _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
            } else {
                _imagePicker.mediaTypes=@[(NSString *)kUTTypeMovie];
                _imagePicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
                _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
            }
        }
    }
    return _imagePicker;
}

@end




