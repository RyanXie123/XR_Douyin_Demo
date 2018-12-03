//
//  WebCacheHelper.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/29.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <Foundation/Foundation.h>

//缓存查询完毕后的回调block，data返回类型包括NSString缓存文件路径、NSData格式缓存数据
typedef void(^WebCacheQueryCompletedBlock)(id data,BOOL hasCache);

//网络资源下载进度
typedef void(^WebDownloaderProgressBlock)(NSInteger reveivedSize,NSInteger expectedSize);
typedef void(^WebDownloaderCompletedBlock)(NSData *data,NSError *error,BOOL finished);
typedef void(^WebDownloaderCancelBlock)(void);





@interface WebDownLoaderOperation : NSOperation
- (instancetype)initWithRequest:(NSURLRequest *)request progressBlock:(WebDownloaderProgressBlock)progressBlock completedBlock:(WebDownloaderCompletedBlock)completedBlock cancelBlock:(WebDownloaderCancelBlock)cancelBlock;

@end

//处理网络资源缓存类
@interface WebCacheHelper : NSObject
//单例
+ (WebCacheHelper *)sharedWebCache;
//根据Key值从内存和磁盘中查询缓存数据
- (NSOperation *)queryDataFromMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock ;

//存储缓存数据到磁盘和硬盘
- (void)storeDataCache:(NSData *)data forKey:(NSString *)key;

@end



//查询缓存的NSOperation任务和下载资源的WebDownloadOperation任务合并的类
@interface WebCombineOperation : NSObject
//查询缓存NSOperation任务
@property (strong, nonatomic) NSOperation *cacheOperation;
//下载网络资源任务
@property (nonatomic, strong) WebDownLoaderOperation *downloadOperation;

- (void)cancel;
@end




@interface WebDownloader : NSObject
//用于处理下载任务的NSOperationQueue队列
@property (strong, nonatomic) NSOperationQueue *downloadQueue;
//单例
+ (WebDownloader *)sharedDownloader;
//下载指定URL网络资源
- (WebCombineOperation *)downloadWithURL:(NSURL *)url progressBlock:(WebDownloaderProgressBlock)progressBlock completedBlock:(WebDownloaderCompletedBlock)completedBlock cancelBlock:(WebDownloaderCancelBlock)cancelBlock;

@end
