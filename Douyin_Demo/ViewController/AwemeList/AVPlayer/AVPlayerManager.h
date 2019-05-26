//
//  AVPlayerManager.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2019/5/26.
//  Copyright © 2019 谢汝. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface AVPlayerManager : NSObject
@property (nonatomic, strong) NSMutableArray<AVPlayer *>   *playerArray;  //用于存储AVPlayer的数组

+ (AVPlayerManager *)shareManager;
+ (void)setAudioMode;
- (void)play:(AVPlayer *)player;
- (void)pause:(AVPlayer *)player;
- (void)pauseAll;
- (void)replay:(AVPlayer *)player;
- (void)removeAllPlayers;

@end

NS_ASSUME_NONNULL_END
