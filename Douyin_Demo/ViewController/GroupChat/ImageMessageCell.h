//
//  ImageMessageCell.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/4.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "BaseMessageCell.h"

@class CircleProgressView;

@interface ImageMessageCell : BaseMessageCell
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIImageView *imageMsg;
@property (nonatomic, strong) GroupChat *chat;
@property (nonatomic, strong) CircleProgressView *progressView;


-(void)initData:(GroupChat *)chat;



@end


