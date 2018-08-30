//
//  ViewController.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "ViewController.h"
#import <TFPhotoBrowser/TFImagePickerController.h>
#import <TFPhotoBrowser/TFLibraryViewController.h>
#import "TFUploadAssistant.h"
#import "TFConfiguration.h"
#import <CommonCrypto/CommonDigest.h>
//#import "TFUcloudUploadAssistant.h"
//#import "UFileAPIUtils.h"
//#import "UFileAPI.h"

#define kAliBucketHostId            @"oss-cn-hangzhou.aliyuncs.com"
#define kAliEndPoint                @"http://oss-cn-hangzhou.aliyuncs.com"
#define kAliBucket                  @"timeface-image01"
#define kAliAuthSTS                 @"http://auth.timeface.org/aliyun/sts"

#define kUcloudBucketName           @"digitalconference"
#define kUcloudBucketHostId         @"ufile.ucloud.cn"
#define kUcloudPublicKey            @"10V/wm8ru7aHMy8f+TyEKzXlV+LlbPNR+LYj4Md5IUOtlSzjmH0pRw=="
#define kUcloudPrivateKey           @"3f9f52222498a8b9a7015fd49a063c5a1cf54feb"

@interface ViewController ()<TFImagePickerControllerDelegate,TFLibraryViewControllerDelegate,TFUploadAssistantDelegate>

@property (nonatomic ,strong) TFConfiguration *config;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, CGRectGetWidth(self.view.bounds) - 200, 60);
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:@"选择照片" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onViewClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _config = [[TFConfiguration alloc] init];
    
    _config.aliBucket       = kAliBucket;
    _config.aliAuthSTS      = kAliAuthSTS;
    _config.aliBucketHostId = kAliBucketHostId;
    _config.aliEndPoint     = kAliEndPoint;
    
    [TFConfiguration enableLog];
    [TFConfiguration setMaxConcurrentRequestCount:8];
    //[TFConfiguration setCompressionQuality:0.6];
    
    _config.uploadType = TFUploadTypeAliyun;

//    _config.ucloudScheme = @"http";
//    _config.ucloudBucketName = kUcloudBucketName;
//    _config.ucloudBucketHostId = kUcloudBucketHostId;
//    _config.ucloudPublicKey = kUcloudPublicKey;
//    _config.ucloudPrivateKey = kUcloudPrivateKey;
    //[[TFUploadAssistant sharedInstanceWithConfiguration:_config] checkTask];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onViewClick:(id)sender {
    
    TFLibraryViewController *vc = [[TFLibraryViewController alloc]init];
    vc.libraryControllerDelegate = self;
    vc.allowsMultipleSelection = YES;
    vc.maximumNumberOfSelection = 100;

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nc.toolbarHidden = NO;
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark - TFImagePickerControllerDelegate

- (void)imagePickerController:(TFImagePickerController *)picker
       didFinishPickingAssets:(NSArray<PHAsset *> *)assets {
    
}

- (void)didSelectPHAssets:(NSArray<TFAsset *> *)assets
               removeList:(NSArray<TFAsset *> *)removeList
                    infos:(NSMutableArray *)infos {
    
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    NSLog(@"startTime: %@", @(startTime));
    
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *keyArray = [NSMutableArray array];
    for (TFAsset *asset in assets) {
        
        [array addObject:asset.phAsset];
        //melvin/test-0602-19/%@.%@
        NSString* key = [NSString stringWithFormat:@"%@-1104-003.%@",asset.md5,asset.fileExtension];
        [keyArray addObject:key];
    }
    
    NSLog(@"select photos count: %@", @(keyArray.count));
    
    [[TFUploadAssistant sharedInstanceWithConfiguration:_config] putPHAssets:array
                                                                        keys:keyArray
                                                                       token:@"timeface-1" delegate:self];
}

- (NSString *)getMD5StringFromNSString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([data bytes], (CC_LONG)[data length], digest);
    NSMutableString *result = [NSMutableString string];
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat: @"%02x", (int)(digest[i])];
    }
    return [result copy];
}

#pragma mark - TFUploadAssistantDelegate
- (void)uploadAssistantProgressHandler:(NSString *)key token:(NSString *)token percent:(float)percent {
    NSLog(@"key:%@ token:%@ progress:%f", key, token,percent);
}

- (void)uploadAssistantCompletionHandler:(TFResponseInfo *)info
                                     key:(NSString *)key
                                   token:(NSString*)token
                                 success:(BOOL)success {
    //TFULogDebug
    NSLog(@"%@", key);
    
    //NSLog(@"token : %@ upload over info:%@",token,info);
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"endTime: %@", @(endTime));
}

@end
