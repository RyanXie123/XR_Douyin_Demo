//
//  WebCacheHelper.h
//  NSOperation
//
//  Created by 谢汝 on 2019/5/23.
//  Copyright © 2019 谢汝. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^webCacheQueryCompletedBlock)(id data,BOOL hasCache);
typedef void(^WebDownloaderResponseBlock)(NSHTTPURLResponse *response);
typedef void(^WebDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSData *data);
typedef void(^WebDownloaderCompletedBlcok)(NSData *data, NSError *error, BOOL finished);
typedef void(^WebDownloaderCancelBlock)(void);

//申明网络资源下载类
@class WebDownLoadOperation;
@interface WebCombineOperation : NSObject
//网络资源下载取消后的block
@property (nonatomic, copy) WebDownloaderCancelBlock cancelBlock;
//查询缓存NSOperation任务
@property (nonatomic, strong) NSOperation *cacheOperation;
//下载网络资源任务
@property (nonatomic, strong) WebDownLoadOperation *downloadOperation;
//取消查询缓存NSOperation和下载资源WebDownloadOperation
- (void)cancel;

@end


@interface WebCacheHelper : NSObject
//单例
+ (WebCacheHelper *)sharedWebCache;
//根据key从内存和本地磁盘中查询缓存数据
- (NSOperation *)queryDataFromMemory:(NSString *)key CacheQueryCompletedBlock:(webCacheQueryCompletedBlock)cacheQueryCompletedBlock;
//根据key从内存和本地磁盘中查询缓存数据 所查询的数据包含指定文件类型
- (NSOperation *)queryDataFromMemory:(NSString *)key CacheQueryCompletedBlock:(webCacheQueryCompletedBlock)cacheQueryCompletedBlock extension:(NSString *)extension;



//根据key值从本地磁盘中查询缓存数据，所查询缓存数据包含指定文件类型
-(NSOperation *)queryURLFromDiskMemory:(NSString *)key cacheQueryCompletedBlock:(webCacheQueryCompletedBlock)cacheQueryCompletedBlock extension:(NSString *)extension;

//储存缓存数据到内存和本地磁盘
- (void)storeDataCache:(NSData *)data forKey:(NSString *)key;

//储存缓存数据到本地磁盘
- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key;
- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key extension:(NSString *)extension;
@end






//自定义用于下载网络资源的NSOperation任务
@interface WebDownLoadOperation : NSOperation<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLRequest *request;


//初始化
- (instancetype)initWithRequest:(NSURLRequest *)request responseBlock:(WebDownloaderResponseBlock)responseBlock progressBlock:(WebDownloaderProgressBlock)progressBlock completedBlock:(WebDownloaderCompletedBlcok)completedBlock cancelBlock:(WebDownloaderCancelBlock)cancelBlock;


@end


//自定义网络资源下载器
@interface WebDownloader : NSObject


@property (nonatomic, strong) NSOperationQueue *downloadConcurrentQueue;
@property (nonatomic, strong) NSOperationQueue *downloadSerialQueue;

- (WebCombineOperation *)downloadWithUrl:(NSURL *)url
                           progressBlock:(WebDownloaderProgressBlock)progressBlock
                          completedBlock:(WebDownloaderCompletedBlcok)completedBlock
                             cancelBlock:(WebDownloaderCancelBlock)cancelBlock;



- (WebCombineOperation *)downloadWithUrl:(NSURL *)url
                           responseBlock:(WebDownloaderResponseBlock)responseBlock
                           progressBlock:(WebDownloaderProgressBlock)progressBlock
                          completedBlock:(WebDownloaderCompletedBlcok)completedBlock
                             cancelBlock:(WebDownloaderCancelBlock)cancelBlock
                            isConcurrent:(BOOL)isConcurrent;
//单例
+ (WebDownloader *)sharedDownloader;

@end
