//
//  TextMessageCell.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMessageCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface TextMessageCell : BaseMessageCell

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) UIImageView *indicatorView;
@property (nonatomic, strong) UIImageView *tipIcon;
@property (nonatomic, strong) GroupChat *chat;

- (void)initData:(GroupChat *)chat;


@end

NS_ASSUME_NONNULL_END
