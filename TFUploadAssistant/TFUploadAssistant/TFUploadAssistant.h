//
//  TFUploadAssistant.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFUploadOperationProtocol.h"

@protocol TFUploadAssistantDelegate <NSObject>
- (void)uploadAssistantProgressHandler:(NSString *)key token:(NSString *)token percent:(float)percent;
- (void)uploadAssistantCompletionHandler:(TFResponseInfo *)info key:(NSString *)key token:(NSString*)token success:(BOOL)success;
@end

@interface TFUploadAssistant : NSObject

@property (nonatomic ,strong) OSSClient *client;

+ (instancetype)sharedInstanceWithConfiguration:(TFConfiguration *)config;

/**
 *  检查上次出现问题的图片
 */
- (void)checkTask;

/**
 *    直接上传数据
 *
 *    @param data              待上传的数据
 *    @param key               上传到阿里云的object key
 *    @param token             上传需要的token, 由服务器生成
 *    @param progress          上传进度回调
 *    @param completion        上传完成后的回调函数
 */
- (void) putData:(NSData *)data
             key:(NSString *)key
           token:(NSString *)token
        progress:(TFUpProgressHandler)progressHandler
      completion:(TFUpCompletionHandler)completionHandler;

/**
 *    上传文件
 *
 *    @param filePath          文件路径
 *    @param key               上传到阿里云的object key
 *    @param token             上传需要的token, 由服务器生成
 *    @param progress          上传进度回调
 *    @param completion        上传完成后的回调函数
 */
- (void) putFile:(NSString *)filePath
             key:(NSString *)key
           token:(NSString *)token
        progress:(TFUpProgressHandler)progressHandler
      completion:(TFUpCompletionHandler)completionHandler;

/**
 *    上传PHAsset文件数组
 *
 *    @param asset             PHAsset文件数组
 *    @param keys              上传到阿里云的object key 数组
 *    @param token             上传需要的token, 由服务器生成
 *    @param progress          上传进度回调
 *    @param completion        上传完成后的回调函数
 */
- (void) putPHAssets:(NSArray *)assets
                keys:(NSArray *)keys
               token:(NSString *)token
            delegate:(id<TFUploadAssistantDelegate>)delegate;

- (void) putPHAssets:(NSArray *)assets
                keys:(NSArray *)keys
               token:(NSString *)token
            progress:(TFUpProgressHandler)progressHandler
          completion:(TFUpCompletionHandler)completionHandler;

/**
 *  上传PHAsset文件
 *
 *  @param asset             PHAsset文件
 *  @param key               上传到阿里云的object key
 *  @param token             上传需要的token, 由服务器生成
 *  @param progress          上传进度回调
 *  @param completion        上传完成后的回调函数
 */
- (void) putPHAsset:(PHAsset *)asset
                key:(NSString *)key
              token:(NSString *)token
           progress:(TFUpProgressHandler)progressHandler
         completion:(TFUpCompletionHandler)completionHandler;

/**
 *  添加上传回调监听
 *
 *  @param listener
 *  @param token
 */
- (void) attachListener:(id<TFUploadAssistantDelegate>)listener token:(NSString *)token;

/**
 *  卸载回调监听
 *
 *  @param listener 
 */
- (void) detachListener:(id<TFUploadAssistantDelegate>)listener;

/**
 *  清除全部监听
 *
 *  @param listener
 */
- (void) clearAllListener;

@end
