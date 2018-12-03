//
//  ChatTextView.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/3.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "ChatTextView.h"
#import "Constants.h"


static const CGFloat kChatTextViewLeftInset = 15;
static const CGFloat kChatTextViewRightInset = 85;
static const CGFloat kChatTextViewTopBottomInset = 15;


@interface ChatTextView ()
@property (nonatomic, assign) CGFloat  keyboardHeight; //键盘高度
@property (nonatomic, assign) CGFloat textViewHeight; //textView高度


@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIButton *emotionBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;

@end



@implementation ChatTextView


- (instancetype)init {
    return [self initWithFrame:ScreenFrame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 0)];
        _container.backgroundColor = ColorThemeGrayDark;
        [self addSubview:_container];
        
        _keyboardHeight  = SafeAreaBottomHeight;
        _editMessageType = ChatEditMessageTypeNone;
        
        _textView = [[UITextView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 0)];
        _textView.backgroundColor = ColorClear;
        _textView.clipsToBounds = NO;
        _textView.textColor = ColorWhite;
        _textView.font = BigFont;
        _textView.scrollEnabled = NO;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail; //省略号在末尾
        _textView.textContainerInset = UIEdgeInsetsMake(kChatTextViewTopBottomInset, kChatTextViewLeftInset, kChatTextViewTopBottomInset, kChatTextViewRightInset);
        _textView.textContainer.lineFragmentPadding = 0;
        _textViewHeight = ceilf(_textView.font.lineHeight);
        
        _placeholderLabel = [[UILabel alloc]init];
        _placeholderLabel.text = @"发送消息...";
        _placeholderLabel.textColor = ColorGray;
        _placeholderLabel.font = BigFont;
        _placeholderLabel.frame = CGRectMake(kChatTextViewLeftInset, 0, ScreenWidth - kChatTextViewLeftInset - kChatTextViewRightInset, 50);
        [_textView addSubview:_placeholderLabel];
        
        [_container addSubview:_textView];
        
        
        
        
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateContainerFrame];
}



- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        if (_editMessageType == ChatEditMessageTypeNone) {
            return nil;
        }
    }
    
    return hitView;
}

- (void)updateContainerFrame {
    CGFloat textViewHeight = _keyboardHeight > SafeAreaBottomHeight ? 0: BigFont.lineHeight + 2 * kChatTextViewTopBottomInset;
    _textView.frame = CGRectMake(0, 0, ScreenWidth, textViewHeight);
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.container.frame = CGRectMake(0, ScreenHeight - self.keyboardHeight - textViewHeight, ScreenWidth, self.keyboardHeight + textViewHeight);
        if (self.delegate) {
            [self.delegate onChatViewHeightChange:self.container.frame.size.height];
        }
    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (void)show {
    UIView *window = [[[UIApplication sharedApplication]delegate]window];
    [window addSubview:self];
}

@end
