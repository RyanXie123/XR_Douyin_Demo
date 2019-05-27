//
//  MusicAlbumView.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2019/5/26.
//  Copyright © 2019 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicAlbumView : UIView
@property (nonatomic, strong) UIImageView *album;

- (void)startAnimation:(CGFloat)rate;
- (void)resetView;

@end

NS_ASSUME_NONNULL_END
