//
//  ImageMessageCell.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/4.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "ImageMessageCell.h"
#import "CircleProgressView.h"
#import <Masonry.h>

static const CGFloat kImageMsgCornerRadius = 10;
static const CGFloat kImageMsgMaxWidth     = 200;
static const CGFloat kImageMsgMaxHeight    = 200;
static const CGFloat kImageMsgPadding      = 8;

@interface ImageMessageCell ()
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@end


@implementation ImageMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = ColorClear;
        
        _avatar = [[UIImageView alloc] init];
        _avatar.image = [UIImage imageNamed:@"img_find_default"];
        _avatar.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_avatar];
        
        _imageMsg = [[UIImageView alloc] init];
        _imageMsg.backgroundColor = ColorGray;
        _imageMsg.contentMode = UIViewContentModeScaleAspectFit;
        _imageMsg.layer.cornerRadius = kImageMsgCornerRadius;
        _imageMsg.userInteractionEnabled = YES;
        [self.contentView addSubview:_imageMsg];
        
        _progressView = [CircleProgressView new];
        [self.contentView addSubview:_progressView];
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.imageMsg);
            make.width.height.mas_equalTo(50);
        }];
        
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    _imageMsg.image = nil;
    [_progressView setProgress:0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([MD5_UDID isEqualToString:_chat.visitor.udid]) {
        _avatar.frame = CGRectMake(ScreenWidth - kImageMsgPadding - 30, kImageMsgPadding, 30, 30);
    }else {
        _avatar.frame = CGRectMake(kImageMsgPadding, kImageMsgPadding, 30, 30);
    }
    [self updateImageFrame];
}


- (void)updateImageFrame {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if([MD5_UDID isEqualToString:_chat.visitor.udid]){
        _imageMsg.frame = CGRectMake(CGRectGetMinX(self.avatar.frame) - kImageMsgPadding - _imageWidth, kImageMsgPadding, _imageWidth, _imageHeight);
    }else {
        _imageMsg.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame) + kImageMsgPadding, kImageMsgPadding, _imageWidth, _imageHeight);
    }
    [CATransaction commit];
}

- (void)initData:(GroupChat *)chat {
    _chat = chat;
    
    _imageWidth = [ImageMessageCell imageWidth:chat];
    _imageHeight = [ImageMessageCell imageHeight:chat];
    
    __weak typeof(self) weakSelf = self;
    if (chat.picImage) {
        [_progressView setHidden:YES];
        UIImage *image = [chat.picImage drawRoundedRectImage:kImageMsgCornerRadius width:_imageWidth height:_imageHeight];
        [_imageMsg setImage:image];
    
    }else {
        [_progressView setHidden:NO];
        
        [_imageMsg setImageWithURL:[NSURL URLWithString:chat.pic_medium.url] progressBlock:^(CGFloat progress) {
            weakSelf.progressView.progress = progress;
        } completedBlcok:^(UIImage *image, NSError *error) {
            if (!error) {
                weakSelf.chat.picImage = image;
                [weakSelf.imageMsg setImage:[image drawRoundedRectImage:kImageMsgCornerRadius width:weakSelf.imageWidth height:weakSelf.imageHeight]];
                [weakSelf.progressView setHidden:YES];
            }
        }];

    }
}


+ (CGFloat)imageWidth:(GroupChat *)chat {
    NSInteger width = chat.pic_large.width;
    NSInteger height = chat.pic_large.height;
    CGFloat ratio = (CGFloat)width / (CGFloat)height;
    if (width > height) {
        if (width > kImageMsgMaxWidth) {
            width = kImageMsgMaxWidth;
        }
    }else {
        if (height > kImageMsgMaxHeight) {
            width = kImageMsgMaxHeight * ratio;
        }
    }
    return width;
}


+ (CGFloat)imageHeight:(GroupChat *)chat {
    NSInteger width = chat.pic_large.width;
    NSInteger height = chat.pic_large.height;
    CGFloat ratio = (CGFloat)width / (CGFloat)height;
    
    if (height > width) {
        if (height > kImageMsgMaxHeight) {
            height = kImageMsgMaxHeight;
        }
    }else{
        if (width > kImageMsgMaxWidth) {
            height = kImageMsgMaxWidth / ratio;
        }
    }
    return height;
    
}

+ (CGFloat)cellHeight:(GroupChat *)chat {
    return chat.contentSize.height + 2 * kImageMsgPadding;
}

+ (CGSize)contentSize:(GroupChat *)chat {
    return CGSizeMake([self imageWidth:chat], [self imageHeight:chat]);
}

@end
