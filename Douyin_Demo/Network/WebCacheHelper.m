//
//  WebCacheHelper.m
//  NSOperation
//
//  Created by 谢汝 on 2019/5/23.
//  Copyright © 2019 谢汝. All rights reserved.
//

#import "WebCacheHelper.h"
#import <CommonCrypto/CommonDigest.h>


@implementation WebCombineOperation

//取消查询缓存NSOperation和下载资源WebDownloadOperation
- (void)cancel {
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    
    if (self.downloadOperation) {
        [self.downloadOperation cancel];
        self.downloadOperation = nil;
    }
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

@end



@interface WebCacheHelper ()
@property (nonatomic, strong) NSCache *memCache;//内存缓存
@property (nonatomic, strong) NSFileManager *fileManager;//文件管理类
@property (nonatomic, strong) NSURL *diskCacheDirectoryURL;//本地磁盘缓存文件夹路径
@property (nonatomic, strong) dispatch_queue_t ioQueue; //查询缓存任务队列
@end
@implementation WebCacheHelper
+ (WebCacheHelper *)sharedWebCache {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}


- (instancetype)init {
    if (self = [super init]) {
        
        //初始化内存缓存
        _memCache = [NSCache new];
        _memCache.name = @"webCache";
        _memCache.totalCostLimit = 50 * 1024 * 1024;
        
        //初始化文件管理类
        _fileManager = [NSFileManager defaultManager];
        
        
        //获取本地磁盘缓存文件夹路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *path = [paths lastObject];
        NSString *diskCachePath = [NSString stringWithFormat:@"%@%@",path,@"/webCache"];
        
    
        BOOL isDirectory = NO;
        BOOL isExisted =  [_fileManager fileExistsAtPath:diskCachePath isDirectory:&isDirectory];
        if (!isExisted || !isDirectory) {
            NSError *error;
            [_fileManager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        //本地缓存磁盘文件夹URL
        _diskCacheDirectoryURL = [NSURL fileURLWithPath:diskCachePath];
        //初始化查询缓存任务队列
        _ioQueue = dispatch_queue_create("com.start.webcache", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

//根据key从内存和本地磁盘中查询缓存数据
- (NSOperation *)queryDataFromMemory:(NSString *)key CacheQueryCompletedBlock:(webCacheQueryCompletedBlock)cacheQueryCompletedBlock {
    return [self queryDataFromMemory:key CacheQueryCompletedBlock:cacheQueryCompletedBlock extension:nil];
}

//根据key值从内存和本地磁盘中查询缓存数据，所查询数据包含指定文件类型
- (NSOperation *)queryDataFromMemory:(NSString *)key CacheQueryCompletedBlock:(webCacheQueryCompletedBlock)cacheQueryCompletedBlock extension:(NSString *)extension {
    NSOperation *operation = [NSOperation new];
    
    dispatch_async(_ioQueue, ^{
        if (operation.isCancelled) {
            return;
        }
        NSData *data = [self dataFromMemoryCache:key];
        BOOL memoryExists = YES;
        if (!data) {
            memoryExists = NO;
            data = [self dataFromDiskCache:key extension:extension];
        }
        //磁盘中有 内存中没有  保留一份在内存中
        if (!memoryExists && data) {
            [self storeDataToMemoryCache:data key:key];
        }
        
        if (data) {
            cacheQueryCompletedBlock(data,YES);
        }else {
            cacheQueryCompletedBlock(nil,NO);
        }
       
    });
    
    return operation;
    
}

-(NSOperation *)queryURLFromDiskMemory:(NSString *)key cacheQueryCompletedBlock:(webCacheQueryCompletedBlock)cacheQueryCompletedBlock extension:(NSString *)extension {
    NSOperation *operatioon = [NSOperation new];
    dispatch_async(_ioQueue, ^{
        if (operatioon.isCancelled) {
            return;
        }
        NSString *path = [self diskCachePathForKey:key extension:extension];
        if ([self.fileManager fileExistsAtPath:path]) {
            cacheQueryCompletedBlock(path, YES);
        }else {
            cacheQueryCompletedBlock(path, NO);
        }
        
    });
    return operatioon;
    
}

//根据key值 从内存中查询缓存数据
- (NSData *)dataFromMemoryCache:(NSString *)key {
    return [_memCache objectForKey:key];
}


//根据key值 从本地磁盘中查询缓存数据
- (NSData *)dataFromDiskCache:(NSString *)key extension:(NSString *)extension {
    return [NSData dataWithContentsOfFile:[self diskCachePathForKey:key extension:extension]];
}


//储存缓存数据到内存和本地磁盘
- (void)storeDataCache:(NSData *)data forKey:(NSString *)key {
    dispatch_async(_ioQueue, ^{
        [self storeDataToMemoryCache:data key:key];
        [self storeDataToDiskCache:data key:key];
    });
}


//存储缓存数据到内存
- (void)storeDataToMemoryCache:(NSData *)data key:(NSString *)key {
    if (data && key) {
        [self.memCache setObject:data forKey:key];
    }
}


- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key {
    [self storeDataToDiskCache:data key:key extension:nil];
}

- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key extension:(NSString *)extension {
    if (data && key) {
        [_fileManager createFileAtPath:[self diskCachePathForKey:key extension:extension] contents:data attributes:nil];
    }
}
//根据key值对应的磁盘缓存文件路径，文件路径保护指定扩展名
- (NSString *)diskCachePathForKey:(NSString *)key extension:(NSString *)extension {
    NSString *fileName = [self md5:key];
    NSString *cachePathForKey = [_diskCacheDirectoryURL URLByAppendingPathComponent:fileName].path;
    if (extension) {
        cachePathForKey = [cachePathForKey stringByAppendingFormat:@".%@",extension];
        
    }
    return cachePathForKey;
    
}



//key值进行md5签名
- (NSString *)md5:(NSString *)key {
    if(!key) {
        return @"temp";
    }
    const char *str = [key UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}



@end


@interface WebDownLoadOperation (){
    BOOL finished;
    BOOL executing;
}

@property (nonatomic, copy) WebDownloaderResponseBlock  responseBlock;
@property (nonatomic, copy) WebDownloaderProgressBlock progressBlcok;
@property (nonatomic, copy) WebDownloaderCompletedBlcok completedBlock;
@property (nonatomic, copy) WebDownloaderCancelBlock cancelBlock;


@property (nonatomic, strong) NSMutableData *data;//用于存储网络资源数据
@property (nonatomic, assign) NSInteger expectedSize;//网络资源数据总大小


@end


@implementation WebDownLoadOperation

- (instancetype)initWithRequest:(NSURLRequest *)request responseBlock:(WebDownloaderResponseBlock)responseBlock progressBlock:(WebDownloaderProgressBlock)progressBlock completedBlock:(WebDownloaderCompletedBlcok)completedBlock cancelBlock:(WebDownloaderCancelBlock)cancelBlock {
    if (self = [super init]) {
        _request = request;
        _responseBlock = [responseBlock copy];
        _progressBlcok = [progressBlock copy];
        _completedBlock = [completedBlock copy];
        _cancelBlock = [cancelBlock copy];
    }
    return self;
}

- (void)start {
    
    if ([self isCancelled]) {
        [self done];
        
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSLog(@"下载任务启动 线程: %@",[NSThread currentThread]);
    
    
    @synchronized (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 15;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        _dataTask = [_session dataTaskWithRequest:_request];
        [_dataTask resume];
    }
    
}

- (void)done {
    [super cancel];
    
    if (executing) {
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        executing = NO;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        [self reset];
    }
}

- (void)reset {
    if (_dataTask) {
        [_dataTask cancel];
    }
    if (_session) {
        [_session invalidateAndCancel];
        _session = nil;
    }
    
}


- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}
- (BOOL)isFinished {
    return finished;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (self.responseBlock) {
        self.responseBlock(httpResponse);
    }
    if (httpResponse.statusCode == 200) {
        
        self.data = [NSMutableData data];
        NSInteger expected = response.expectedContentLength > 0 ? response.expectedContentLength : 0;
        self.expectedSize = expected;
        completionHandler(NSURLSessionResponseAllow);
    }else {
        completionHandler(NSURLSessionResponseCancel);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    if (self.isCancelled) {
        [self done];
        return;
    }
    
    [self.data appendData:data];
    if (self.progressBlcok) {
        self.progressBlcok(self.data.length, self.expectedSize, data);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.completedBlock) {
        if (error) {
            if (error.code == NSURLErrorCancelled) {
                !_cancelBlock ? : _cancelBlock();
            }else {
                _completedBlock(nil , error, NO);
            }
            
        }else {
            self.completedBlock(self.data, nil, YES);
        }
    }
    
    [self done];
}


//网络资源复用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    NSCachedURLResponse *cachedResponse = proposedResponse;
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        cachedResponse = nil;
    }
    
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

@end


@implementation WebDownloader

+ (WebDownloader *)sharedDownloader {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

//初始化
- (instancetype)init {
    if (self = [super init]) {
        _downloadConcurrentQueue = [NSOperationQueue new];
        _downloadConcurrentQueue.name = @"com.concurrent.webdownloader";
        _downloadConcurrentQueue.maxConcurrentOperationCount = 6;
        
        _downloadSerialQueue = [NSOperationQueue new];
        _downloadSerialQueue.name = @"com.serial.webdownloader";
        _downloadSerialQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (WebCombineOperation *)downloadWithUrl:(NSURL *)url
                           progressBlock:(WebDownloaderProgressBlock)progressBlock
                          completedBlock:(WebDownloaderCompletedBlcok)completedBlock
                             cancelBlock:(WebDownloaderCancelBlock)cancelBlock {
    return [self downloadWithUrl:url responseBlock:nil progressBlock:progressBlock completedBlock:completedBlock cancelBlock:cancelBlock isConcurrent:YES];
}
- (WebCombineOperation *)downloadWithUrl:(NSURL *)url
                           responseBlock:(WebDownloaderResponseBlock)responseBlock
                           progressBlock:(WebDownloaderProgressBlock)progressBlock
                          completedBlock:(WebDownloaderCompletedBlcok)completedBlock
                             cancelBlock:(WebDownloaderCancelBlock)cancelBlock
                            isConcurrent:(BOOL)isConcurrent {
    
    //初始化网络资源下载请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    request.HTTPShouldUsePipelining = YES;
    
    
    WebCombineOperation *operation = [WebCombineOperation new];
    NSString *key = url.absoluteString;
    
    __weak typeof(self) wSelf = self;
    
    operation.cacheOperation = [[WebCacheHelper sharedWebCache]queryDataFromMemory:key CacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        if (hasCache) {
            //查找到直接返回数据
            if (completedBlock) {
                completedBlock(data,nil,YES);
            }
        }else {
            //未查找到则创建下载网络资源的WebDownloadOperation任务，并赋值组合任务WebCombineOperation
            operation.downloadOperation = [[WebDownLoadOperation alloc]initWithRequest:request responseBlock:^(NSHTTPURLResponse *response) {
                if (responseBlock) {
                    responseBlock(response);
                }
            } progressBlock:progressBlock completedBlock:^(NSData *data, NSError *error, BOOL finished) {
                //网络资源下载完毕  处理返回数据
                if (finished && !error) {
                    //若下载任务没有错误的情况下完成，则将下载数据进行缓存
                    [[WebCacheHelper sharedWebCache]storeDataCache:data forKey:key];
                    //任务完成回调
                    !completedBlock ? :completedBlock(data,nil,YES);
                }else {
                    //任务失败回调
                    completedBlock(data,error,NO);
                }
                
            } cancelBlock:^{
                if (cancelBlock) {
                    cancelBlock();
                }
            }];
            
            
            //将下载任务添加到队列
            if (isConcurrent) {
                [wSelf.downloadConcurrentQueue addOperation:operation.downloadOperation];
            }else {
                [wSelf.downloadSerialQueue addOperation:operation.downloadOperation];
            }
            
            
        }
        
        
        
    }];
    //返回包含查询任务和下载任务的组合任务
    return operation;
}

@end
