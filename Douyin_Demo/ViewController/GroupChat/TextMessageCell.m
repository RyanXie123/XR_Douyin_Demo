//
//  TextMessageCell.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "TextMessageCell.h"
static const CGFloat kTextMsgCornerRadius = 10;
static const CGFloat kTextMsgMaxWidth   = 220;
static const CGFloat kTextMsgPadding    = 8;

@implementation TextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        _avatar = [[UIImageView alloc] init];
        _avatar.image = [UIImage imageNamed:@"img_find_default"];
        _avatar.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_avatar];
        
        _textView = [[UITextView alloc]init];
        _textView.textColor = [[TextMessageCell attributes]valueForKey:NSForegroundColorAttributeName];
        _textView.font = [[TextMessageCell attributes]valueForKey:NSFontAttributeName];
        _textView.scrollEnabled = NO;
        _textView.selectable = NO;
        _textView.editable = NO;
        _textView.backgroundColor = ColorClear;
        _textView.textContainerInset = UIEdgeInsetsMake(kTextMsgCornerRadius, kTextMsgCornerRadius, kTextMsgCornerRadius, kTextMsgCornerRadius);
        _textView.textContainer.lineFragmentPadding = 0;
        [self.contentView addSubview:_textView];
        
        _backgroundLayer = [[CAShapeLayer alloc]init];
        _backgroundLayer.zPosition = -1;
        [_textView.layer addSublayer:_backgroundLayer];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_indicatorView setHidden:YES];
    [_tipIcon setHidden:YES];
}



- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = _chat.contentSize;
    
    
    _avatar.frame = CGRectMake(kTextMsgPadding, kTextMsgPadding, 30, 30);
    _textView.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame) + kTextMsgPadding, kTextMsgPadding, size.width + kTextMsgCornerRadius * 2, size.height + kTextMsgCornerRadius * 2);
    self.backgroundLayer.path = [self createBezierPath:kTextMsgCornerRadius width:size.width height:size.height].CGPath;
    self.backgroundLayer.frame = CGRectMake(0, 0, size.width + kTextMsgCornerRadius * 2, size.height + kTextMsgCornerRadius * 2);
    _backgroundLayer.fillColor = ColorWhite.CGColor;
    
//    _backgroundlayer.fillColor = ColorWhite.CGColor;
    
    
}



- (void)initData:(GroupChat *)chat {
    _chat = chat;
    _textView.attributedText = chat.cellAttributedString;
//    if(chat.isTemp) {
//        [self startAnim];
//        if(chat.isFailed) {
//            [_tipIcon setHidden:NO];
//        }
//        if(chat.isCompleted) {
//            [self stopAnim];
//        }
//    }else {
//        [self stopAnim];
//    }
    
    __weak __typeof(self) wself = self;
    [_avatar setImageWithURL:[NSURL URLWithString:chat.visitor.avatar_thumbnail.url] progressBlock:^(CGFloat persent) {
    } completedBlock:^(UIImage *image, NSError *error) {
        wself.avatar.image = [image drawCircleImage];
    }];
}

- (UIBezierPath *)createBezierPath:(CGFloat)cornerRadius width:(CGFloat)width height:(CGFloat)height {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, cornerRadius)];
    [path addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(cornerRadius + width, 0)];
    [path addArcWithCenter:CGPointMake(cornerRadius + width, cornerRadius) radius:cornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(2 * cornerRadius + width, cornerRadius + height)];
    [path addArcWithCenter:CGPointMake(cornerRadius + width, cornerRadius + height) radius:cornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(cornerRadius, height + 2 * cornerRadius)];
    [path addArcWithCenter:CGPointMake(cornerRadius, cornerRadius + height) radius:cornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, cornerRadius)];
    
    return path;
}

+ (NSDictionary* ) attributes {
    return @{NSFontAttributeName:BigFont,NSForegroundColorAttributeName:ColorBlack};
}


+ (CGFloat)cellHeight:(GroupChat *)chat {
    return  chat.contentSize.height + kTextMsgCornerRadius * 2 + kTextMsgPadding * 2;;
}

+ (CGSize)contentSize:(GroupChat *)chat {
    return [chat.cellAttributedString multiLineSize:kTextMsgMaxWidth];
}
@end
