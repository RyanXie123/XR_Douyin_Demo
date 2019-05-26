//
//  AVPlayerView.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2019/5/23.
//  Copyright © 2019 谢汝. All rights reserved.
//

#import "AVPlayerView.h"
#import "NetworkHelper.h"
#import "WebCacheHelper.h"

//#import "AVPlayerManaer.h"


@interface AVPlayerView ()<AVAssetResourceLoaderDelegate>
@property (nonatomic ,strong) NSURL                *sourceURL;              //视频路径
@property (nonatomic ,strong) NSString             *sourceScheme;           //路径Scheme
@property (nonatomic ,strong) AVURLAsset           *urlAsset;               //视频资源
@property (nonatomic ,strong) AVPlayerItem         *playerItem;             //视频资源载体
@property (nonatomic ,strong) AVPlayer             *player;                 //视频播放器
@property (nonatomic ,strong) AVPlayerLayer        *playerLayer;            //视频播放器图形化载体
@property (nonatomic ,strong) id                   timeObserver;            //视频播放器周期性调用的观察者

@property (nonatomic, strong) NSMutableData        *data;                   //视频缓冲数据
@property (nonatomic, copy) NSString               *mimeType;               //资源格式
@property (nonatomic, assign) long long            expectedContentLength;   //资源大小
@property (nonatomic, strong) NSMutableArray       *pendingRequests;        //存储AVAssetResourceLoadingRequest的数组

@property (nonatomic, copy) NSString               *cacheFileKey;           //缓存文件key值
@property (nonatomic, strong) NSOperation          *queryCacheOperation;    //查找本地视频缓存数据的NSOperation
@property (nonatomic, strong) dispatch_queue_t     cancelLoadingQueue;

@property (nonatomic, strong) WebCombineOperation  *combineOperation;

@property (nonatomic, assign) BOOL                 retried;
@end

@implementation AVPlayerView 

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //初始化存储AVAssetResourceLoadingRequest的数组
        _pendingRequests = [NSMutableArray array];
        
        //初始化播放器
        _player = [AVPlayer new];
        //添加视频播放器图形化载体 AVPlayerLayer
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:_playerLayer];
        
        
        //初始化取消视频加载的队列
        _cancelLoadingQueue = dispatch_queue_create("com.start.cancelloadingqueue", DISPATCH_QUEUE_CONCURRENT);
        
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    //禁止隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _playerLayer.frame = self.layer.bounds;
    [CATransaction commit];
}

- (void)setPlayerWithUrl:(NSString *)url {
    //播放路径
    self.sourceURL = [NSURL URLWithString:url];
    
    //获取路径scheme
    NSURLComponents *components = [[NSURLComponents alloc]initWithURL:self.sourceURL resolvingAgainstBaseURL:NO];
    self.sourceScheme = components.scheme;
    
    //路径作为缓存key
    _cacheFileKey = self.sourceURL.absoluteString;
    
    
    __weak typeof(self) wSelf= self;
    //查找本地磁盘缓存
    _queryCacheOperation = [[WebCacheHelper sharedWebCache]queryURLFromDiskMemory:_cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        
    } extension:@"mp4"];
    
    
    
//    _queryCacheOperation = [[WebCacheHelper sharedWebCache]queryDataFromMemory:_cacheFileKey extension:@"mp4" cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
//        if (!hasCache) {
//            //当前路径无缓存  则将视频的网络路径的scheme改为其他自定义的scheme类型，http、https这类预留的scheme类型不能使AVAssetResourceLoaderDelegate中的方法回调
//            wSelf.sourceURL = [wSelf.sourceURL.absoluteString urlScheme:@"streaming"];
//        }else {
//            //当前路径有缓存  则使用本地路径作为播放源
//            wSelf.sourceURL = [NSURL fileURLWithPath:data];
//        }
//
//
//        //初始化AVURLAsset
//        wSelf.urlAsset = [AVURLAsset URLAssetWithURL:wSelf.sourceURL options:nil];
//         //设置AVAssetResourceLoaderDelegate代理
//        [wSelf.urlAsset.resourceLoader setDelegate:wSelf queue:dispatch_get_main_queue()];
//        //初始化AVPlayerItem
//        wSelf.playerItem = [AVPlayerItem playerItemWithAsset:wSelf.urlAsset];
//        //观察playerItem.status属性
//        [wSelf.playerItem addObserver:wSelf forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
//        //切换当前播放器的视频源
//        wSelf.player = [[AVPlayer alloc]initWithPlayerItem:wSelf.playerItem];
//        wSelf.playerLayer.player = wSelf.player;
//
//
//        //给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度
//        [wSelf addProgressObserver];
//    }];
    
}

- (void)addProgressObserver {
    __weak typeof(self) weakSelf = self;
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (weakSelf.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            //获取当前播放时间
            CGFloat current = CMTimeGetSeconds(time);
            //获取总播放时长
            CGFloat total = CMTimeGetSeconds([weakSelf.playerItem duration]);
            //重新播放视频
            if (total == current) {
                
            }
            
            //更新播放进度
            if (weakSelf.delegate) {
                [weakSelf.delegate onProgressUpdate:current total:total];
            }
            
        }
    }];
}
@end
