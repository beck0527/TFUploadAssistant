//
//  TFConfiguration.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TFUploadType) {
    
    TFALIYUN = 0,
   
    TFUCLOUD = 1,
    
    TFAMAZON = 2
};


#define TFULogDebug(frmt, ...)\
if ([TFConfiguration isLogEnable]) {\
NSLog(@"[UploadAssistant Debug]: %@", [NSString stringWithFormat:(frmt), ##__VA_ARGS__]);\
}
static BOOL isEnable;
static uint32_t maxRequestCount = 5;
static float compressionQuality = 1;
@interface TFConfiguration : NSObject

@property (nonatomic ,copy) NSString *aliBucketHostId;
@property (nonatomic ,copy) NSString *aliEndPoint;
@property (nonatomic ,copy) NSString *aliBucket;
@property (nonatomic ,copy) NSString *aliAuthSTS;

@property (nonatomic ,copy) NSString *ucloudBucketHostId;
@property (nonatomic ,copy) NSString *ucloudBucketName;
@property (nonatomic ,copy) NSString *ucloudPublicKey;
@property (nonatomic ,copy) NSString *ucloudPrivateKey;

@property (nonatomic ,assign) TFUploadType uploadType;

+ (void)enableLog;
+ (void)disableLog;
+ (BOOL)isLogEnable;

/**
 *  设置最大并发数
 *
 *  @param count
 */
+ (void)setMaxConcurrentRequestCount:(uint32_t)count;

/**
 *  最大并发数
 *
 *  @return
 */
+ (uint32_t)maxConcurrentRequestCount;

/**
 *  设置图片压缩率
 *
 *  @param quality 压缩率 0 < q <= 1
 */
+ (void)setCompressionQuality:(float)quality;

+ (float)compressionQuality;

@end
