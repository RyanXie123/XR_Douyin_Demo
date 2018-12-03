//
//  WebCacheHelper.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/29.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "WebCacheHelper.h"
#import <CommonCrypto/CommonDigest.h>



@interface WebDownLoaderOperation ()<NSURLSessionDataDelegate>

@property (nonatomic, copy) WebDownloaderProgressBlock progressBlock;//下载进度回调block
@property (nonatomic, copy) WebDownloaderCompletedBlock completedBlck; //下载完成回调
@property (nonatomic, copy) WebDownloaderCancelBlock cancelBlock; //取消下载回调

@property (nonatomic, strong) NSMutableData *data;//用于储存网络缓存的数据
@property (nonatomic, assign) NSInteger expectedSize;//网络资源的总大小

@property (nonatomic, strong) NSURLSession *sessoin;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) BOOL finished;

@end


@implementation WebDownLoaderOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithRequest:(NSURLRequest *)request progressBlock:(WebDownloaderProgressBlock)progressBlock completedBlock:(WebDownloaderCompletedBlock)completedBlock cancelBlock:(WebDownloaderCancelBlock)cancelBlock {
    if (self = [super init]) {
        _request = request;
        _progressBlock = progressBlock;
        _completedBlck = completedBlock;
        _cancelBlock = cancelBlock;
    }
    return self;
}


- (void)start {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
     //判断任务执行前是否取消了任务
    if (self.isCancelled) {
        [self done];
        return;
    }
    
    @synchronized (self) {
        //创建网络资源下载请求，并设置网络请求代理
//        NSURLSessionConfiguration
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 15;
        
        _sessoin = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        _dataTask = [_sessoin dataTaskWithRequest:_request];
        [_dataTask resume];
    }
    
    
}


- (void)cancel {
    @synchronized (self) {
        [self done];
    }
}

//更新任务状态
- (void)done {
    [super cancel];
    if (_executing) {
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        _executing = NO;
        _finished = YES;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        [self resetHttpSession];
    }
}

//重置请求数据
- (void)resetHttpSession {
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    if (self.sessoin) {
        [self.sessoin invalidateAndCancel];
        self.sessoin = nil;
    }
}


//网络资源下载请求获得响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger code = httpResponse.statusCode;
    if (code == 200) {
        completionHandler(NSURLSessionResponseAllow);
        self.data = [NSMutableData data];
        _expectedSize = httpResponse.expectedContentLength > 0 ? (NSInteger)httpResponse.expectedContentLength : 0;
        
    }else {
        completionHandler(NSURLSessionResponseCancel);
    }
}

//网络资源下载数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.data appendData:data];
    if (self.progressBlock) {
        self.progressBlock(self.data.length, self.expectedSize);
        
    }
}

//网络资源下载完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (_completedBlck) {
        if (error) {
            if (error.code == NSURLErrorCancelled) {
                !self.cancelBlock?:self.cancelBlock();
            }else {
                self.completedBlck(nil, error, NO);
            }
        }else {
            self.completedBlck(self.data, nil, YES);
        }
    }
    [self done];
}

//网络缓存数据复用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    NSCachedURLResponse *response = proposedResponse;
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringCacheData) {
        response = nil;
    }
    if (completionHandler) {
        completionHandler(response);
    }
    
}


- (BOOL)isExecuting {
    return _executing;
}
- (BOOL)isFinished {
    return _finished;
}
@end


@interface WebCacheHelper ()
@property (nonatomic, strong) NSCache *memCache;//内存缓存
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSURL *diskCacheDirectoryURL;//本地磁盘文件夹URL
@property (nonatomic, strong) dispatch_queue_t ioQueue; //查询缓存串行队列
@end


@implementation WebCacheHelper

+ (WebCacheHelper *)sharedWebCache {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[WebCacheHelper alloc]init];
    });
    return instance;
}


- (instancetype)init {
    if (self = [super init]) {
        //初始化内存缓存
        _memCache = [NSCache new];
        _memCache.name = @"WebCache";
        _memCache.totalCostLimit = 50 * 1024 * 1024;
        
        //初始化文件管理类
        _fileManager = [NSFileManager defaultManager];
        
        //获取本地磁盘缓存文件夹路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *diskCachePath = [NSString stringWithFormat:@"%@%@",docPath,@"/webCache"];
        
        //判断是否存在本地文件夹
        BOOL isDirectory = NO;
        BOOL isExist = [_fileManager fileExistsAtPath:diskCachePath isDirectory:&isDirectory];
        //如果不存在 或者不是一个文件夹  则创建文件夹
        if (!isExist || !isDirectory) {
            NSError *error = nil;
            [_fileManager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        //本地磁盘缓存文件夹URL
        _diskCacheDirectoryURL = [NSURL fileURLWithPath:diskCachePath];
         //查询缓存串行队列
        _ioQueue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}


//根据Key值从内存和磁盘中查询缓存数据
- (NSOperation *)queryDataFromMemory:(NSString *)key cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock {
    return [self queryDataFromMemory:key extension:nil cacheQueryCompletedBlock:cacheQueryCompletedBlock];
}

- (NSOperation *)queryDataFromMemory:(NSString *)key extension:(NSString *)extension cacheQueryCompletedBlock:(WebCacheQueryCompletedBlock)cacheQueryCompletedBlock {
    //这里的operation仅仅是一个标记，便于dispach执行的时候，知道操作是否取消
    NSOperation *operation = [NSOperation new];
    dispatch_async(_ioQueue, ^{
        if (operation.isCancelled) {
            return;
        }
        //从内存读取缓存
        NSData *data = [self dataFromMemoryCache:key];
        if (!data) {
            //从硬盘读取缓存
            [self dataFromDiskCache:key extension:extension];
        }
        
        if (data) {
            cacheQueryCompletedBlock(data,YES);
        }else {
            cacheQueryCompletedBlock(nil,NO);
        }
        
    });
    return operation;
}

//根据key值从内存中查询缓存数据
- (NSData *)dataFromMemoryCache:(NSString *)key {
    return [_memCache objectForKey:key];
}

//根据key从硬盘中查询缓存数据
- (NSData *)dataFromDiskCache:(NSString *)key extension:(NSString *)extension {
    return [NSData dataWithContentsOfFile:[self diskCachePathForKey:key extension:extension]];
}

//存储缓存数据到磁盘和硬盘
- (void)storeDataCache:(NSData *)data forKey:(NSString *)key {
    dispatch_async(_ioQueue, ^{
        [self storeDataToMemoryCache:data forKey:key];
        [self storeDataToDiskCache:data key:key extension:nil];
    });
}

- (void)storeDataToMemoryCache:(NSData *)data forKey:(NSString *)key {
    if (data && key) {
        [self.memCache setObject:data forKey:key];
    }
}

- (void)storeDataToDiskCache:(NSData *)data key:(NSString *)key extension:(NSString *)extension {
    if (data && key) {
        [_fileManager createFileAtPath:[self diskCachePathForKey:key extension:extension] contents:data attributes:nil];
    }
}


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



@implementation WebDownloader

+ (WebDownloader *)sharedDownloader {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        //初始化用于处理下载任务的队列，设置最大并发量为8
        _downloadQueue = [[NSOperationQueue alloc]init];
        _downloadQueue.name = @"com.start.webdownloader";
        _downloadQueue.maxConcurrentOperationCount = 8;
    }
    return self;
}


- (WebCombineOperation *)downloadWithURL:(NSURL *)url progressBlock:(WebDownloaderProgressBlock)progressBlock completedBlock:(WebDownloaderCompletedBlock)completedBlock cancelBlock:(WebDownloaderCancelBlock)cancelBlock {
    
    //初始化下载请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    request.HTTPShouldUsePipelining = YES;
    
    
    __weak typeof(self) weakSelf = self;
    
    NSString *key = url.absoluteString;
    //初始化组合任务WebCombineOperation
    __block WebCombineOperation *operation = [WebCombineOperation new];
    operation.cacheOperation = [[WebCacheHelper sharedWebCache]queryDataFromMemory:key cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        //判断是否找到缓存
        if (hasCache) {
            //找到直接返回缓存数据
            if (completedBlock) {
                completedBlock(data,nil,YES);
            }
        }else {
            operation.downloadOperation = [[WebDownLoaderOperation alloc]initWithRequest:request progressBlock:progressBlock completedBlock:^(NSData *data, NSError *error, BOOL finished) {
                if (finished && !error) {
                    //缓存
                    [[WebCacheHelper sharedWebCache]storeDataCache:data forKey:key];
                    completedBlock(data,nil,YES);
                }else {
                    completedBlock(data,error,NO);
                }
            } cancelBlock:^{
                if (cancelBlock) {
                    cancelBlock();
                }
            }];
            [weakSelf.downloadQueue addOperation:operation.downloadOperation];
        }
    }];
     //返回包含了查询任务和下载任务的组合任务
    return operation;
}

@end
