//
//  AwemeListCell.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2019/5/26.
//  Copyright © 2019 谢汝. All rights reserved.
//

#import "AwemeListCell.h"
#import "AVPlayerView.h"
#import "Aweme.h"
#import "MusicAlbumView.h"

@interface AwemeListCell ()<AVPlayerUpdateDelegate>

@property (nonatomic, strong) UIView *container;

@end

@implementation AwemeListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = ColorBlackAlpha1;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    //init player view;
    _playerView = [AVPlayerView new];
    _playerView.delegate = self;
    [self.contentView addSubview:_playerView];
    
    
    
    //init hover on player view container
    _container = [UIView new];
    [self.contentView addSubview:_container];
    
    _musicAlbum = [MusicAlbumView new];
    [_container addSubview:_musicAlbum];
    
    
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_musicAlbum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-100);
        make.right.equalTo(self).inset(10);
        make.width.height.mas_equalTo(50);
    }];
    
    
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
     _isPlayerReady = NO;
     [_playerView cancelLoading];
}

// update method
- (void)initData:(Aweme *)aweme {
    _aweme = aweme;
    
}
//播放进度更新回调方法
- (void)onProgressUpdate:(CGFloat)current total:(CGFloat)total {
    
}
- (void)onPlayItemStatusUpdate:(AVPlayerItemStatus)status {
    switch (status) {
        case AVPlayerItemStatusUnknown:
//            [self startLoadingPlayItemAnim:YES];
            break;
        case AVPlayerItemStatusReadyToPlay:
//            [self startLoadingPlayItemAnim:NO];
            
            _isPlayerReady = YES;
            [_musicAlbum startAnimation:_aweme.rate];
            
            if(_onPlayerReady) {
                _onPlayerReady();
            }
            break;
        case AVPlayerItemStatusFailed:
//            [self startLoadingPlayItemAnim:NO];
            [UIWindow showTips:@"加载失败"];
            break;
        default:
            break;
    }
}



- (void)play {
    [_playerView play];
}

- (void)pause {
    [_playerView pause];
}

- (void)replay {
     [_playerView replay];
}

- (void)startDownloadBackgroundTask {
    NSString *playUrl = _aweme.video.play_addr.url_list.firstObject;
    [_playerView setPlayerWithUrl:playUrl];
}


- (void)startDownloadHighPriorityTask {
    NSString *playUrl = _aweme.video.play_addr.url_list.firstObject;
    [_playerView startDownloadTask:[[NSURL alloc] initWithString:playUrl] isBackground:NO];
}

@end
