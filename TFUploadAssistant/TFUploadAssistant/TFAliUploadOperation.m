//
//  TFAliUploadOperation.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFAliUploadOperation.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#import "TFUploadOption.h"
#import "TFConfiguration.h"
#import "TFUploadAssistant.h"
#import "TFResponseInfo.h"

@interface TFAliUploadOperation()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) TFConfiguration *config;
@property (nonatomic, strong) NSMutableDictionary *stats;
@property (nonatomic) int retryTimes;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) TFUpProgressHandler progressHandler;
@property (nonatomic, copy) TFUpCompletionHandler completionHandler;

@end

@implementation TFAliUploadOperation

- (instancetype) initWithData:(nonnull NSData *)data
                          key:(nonnull NSString *)key
                        token:(nonnull NSString *)token
                     progress:(nonnull TFUpProgressHandler)progressHandler
                     complete:(nonnull TFUpCompletionHandler)completionHandler
                       config:(nonnull TFConfiguration *)configuration {
    if (self = [super init]) {
        _data = data;
        _key = key;
        _token = token;
        _progressHandler = progressHandler;
        _completionHandler = completionHandler;
        _config = configuration;
        _stats = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}



+ (nonnull instancetype)uploadOperationWithData:(nonnull NSData *)data
                                            key:(nonnull NSString *)key
                                          token:(nonnull NSString *)token
                                       progress:(nonnull TFUpProgressHandler)progressHandler
                                       complete:(nonnull TFUpCompletionHandler)completionHandler
                                         config:(nonnull TFConfiguration *)configuration {
    
    TFAliUploadOperation *operation = [[TFAliUploadOperation alloc] initWithData:data
                                                                             key:key
                                                                           token:token
                                                                        progress:progressHandler
                                                                        complete:completionHandler
                                                                          config:configuration];
    return operation;
}


- (void)start {
    //    __weak __typeof(self)weakSelf = self;
    //检测文件是否存在
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    OSSClient *client = [[TFUploadAssistant sharedInstanceWithConfiguration:nil] client];
    BOOL objectExist = [client doesObjectExistInBucket:_config.aliBucket objectKey:_key error:nil];
    if (objectExist) {
        _progressHandler(_key,_token,1);
        _completionHandler(nil,_key,_token,YES);
        TFULogDebug(@"object :%@ exist",_key);
        return;
    }
    OSSPutObjectRequest *put = [OSSPutObjectRequest new];
    put.contentType = [OSSUtil detemineMimeTypeForFilePath:nil uploadName:_key];
    put.bucketName = _config.aliBucket;
    put.objectKey = _key;
    put.uploadingData = _data;
    put.contentMd5 = [OSSUtil base64Md5ForData:put.uploadingData];
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        float progress = (float)totalByteSent/(float)totalBytesExpectedToSend;
        //        __typeof(&*weakSelf) strongSelf = weakSelf;
        //        if (strongSelf && strongSelf.progressHandler) {
        //            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //            }];
        //            strongSelf.progressHandler(strongSelf.key,strongSelf.token,progress);
        //            
        //        }
        _progressHandler(_key,_token,progress);
    };
    OSSTask *putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        //        __typeof(&*weakSelf) strongSelf = weakSelf;
        TFResponseInfo *info = nil;
        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
        if (task.error) {
            TFULogDebug(@"%@", task.error);
            info = [TFResponseInfo responseInfoWithNetError:task.error duration:endTime - startTime];
        }
        OSSPutObjectResult * result = task.result;
        info = [[TFResponseInfo alloc] initWithStatusCode:result.httpResponseCode withDuration:endTime - startTime withBody:nil];
        if (result.httpResponseCode == 200) {
            //上传成功
            //            if (strongSelf && strongSelf.completionHandler) {
            //                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //                }];
            //                strongSelf.completionHandler(info,strongSelf.key,strongSelf.token,nil);
            //            }
            if (_completionHandler) {
                _completionHandler(info,_key,_token,YES);
            }
        }
        TFULogDebug(@"Result - requestId: %@ ",result.requestId);
        return nil;
    }];
}

@end
