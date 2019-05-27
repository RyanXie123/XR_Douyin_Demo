//
//  AwemeListCell.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2019/5/26.
//  Copyright © 2019 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^OnPlayerReady)(void);
NS_ASSUME_NONNULL_BEGIN
@class AVPlayerView;
@class Aweme;
@class MusicAlbumView;

@interface AwemeListCell : UITableViewCell


@property (nonatomic, strong) Aweme            *aweme;
@property (nonatomic, strong) AVPlayerView     *playerView;


@property (nonatomic, strong) OnPlayerReady    onPlayerReady;
@property (nonatomic, assign) BOOL             isPlayerReady;
@property (nonatomic, strong) MusicAlbumView   *musicAlbum;

- (void)initData:(Aweme *)aweme;
- (void)play;
- (void)pause;
- (void)replay;
- (void)startDownloadBackgroundTask;
- (void)startDownloadHighPriorityTask;
@end

NS_ASSUME_NONNULL_END
