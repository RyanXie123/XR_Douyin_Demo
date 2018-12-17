//
//  ChatTextView.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/3.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "ChatTextView.h"
#import "Constants.h"
#import "EmotionSelector.h"

static const CGFloat kChatTextViewLeftInset = 15;
static const CGFloat kChatTextViewRightInset = 85;
static const CGFloat kChatTextViewTopBottomInset = 15;


@interface ChatTextView ()<UITextViewDelegate>
@property (nonatomic, assign) CGFloat  keyboardHeight; //键盘高度
@property (nonatomic, assign) CGFloat textHeight; //文字高度


@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIButton *emotionBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;

@property (nonatomic, strong) EmotionSelector *emotionSelector;

@end



@implementation ChatTextView


- (instancetype)init {
    return [self initWithFrame:ScreenFrame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = ColorClear;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
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
        _textView.delegate = self;
        _textHeight = ceilf(_textView.font.lineHeight);
        
        _placeholderLabel = [[UILabel alloc]init];
        _placeholderLabel.text = @"发送消息...";
        _placeholderLabel.textColor = ColorGray;
        _placeholderLabel.font = BigFont;
        _placeholderLabel.frame = CGRectMake(kChatTextViewLeftInset, 0, ScreenWidth - kChatTextViewLeftInset - kChatTextViewRightInset, 50);
        [_textView addSubview:_placeholderLabel];
        [_container addSubview:_textView];
        
        
        _emotionBtn = [[UIButton alloc]init];
        [_emotionBtn setImage:[UIImage imageNamed:@"baseline_emotion_white"] forState:UIControlStateNormal];
        [_emotionBtn setImage:[UIImage imageNamed:@"outline_keyboard_grey"] forState:UIControlStateSelected];
        [_textView addSubview:_emotionBtn];
        
        _photoBtn = [[UIButton alloc] init];
        
        [_photoBtn setImage:[UIImage imageNamed:@"outline_photo_white"] forState:UIControlStateNormal];
        [_photoBtn setImage:[UIImage imageNamed:@"outline_photo_red"] forState:UIControlStateSelected];
        [_photoBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
        [_textView addSubview:_photoBtn];
        
        
        [self addObserver:self forKeyPath:@"keyboardHeight" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateContainerFrame];
    
    _photoBtn.frame = CGRectMake(ScreenWidth - 50, 0, 50, 50);
    _emotionBtn.frame = CGRectMake(ScreenWidth - 85, 0, 50, 50);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"keyboardHeight"]) {
        if (_keyboardHeight == SafeAreaBottomHeight) {
            _textView.textColor = ColorWhite;
            _container.backgroundColor = ColorThemeGrayDark;
            
            [_emotionBtn setImage:[UIImage imageNamed:@"baseline_emotion_white"] forState:UIControlStateNormal];
            [_photoBtn setImage:[UIImage imageNamed:@"outline_photo_white"] forState:UIControlStateNormal];
        }else {
            
            _textView.textColor = ColorBlack;
            _container.backgroundColor = ColorWhite;
            
            
            [_emotionBtn setImage:[UIImage imageNamed:@"baseline_emotion_grey"] forState:UIControlStateNormal];
            [_photoBtn setImage:[UIImage imageNamed:@"outline_photo_grey"] forState:UIControlStateNormal];
        }
    }else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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


- (void)handleGesture:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:_container];
    if (![_container.layer containsPoint:point]) {//点击不在输入View内，隐藏键盘
        [self hideKeyboard];
    }
}

- (void)updateContainerFrame {
    
    CGFloat textViewHeight = _keyboardHeight > SafeAreaBottomHeight ? _textHeight + 2 * kChatTextViewTopBottomInset: BigFont.lineHeight + 2 * kChatTextViewTopBottomInset;
    _textView.frame = CGRectMake(0, 0, ScreenWidth, textViewHeight);
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.container.frame = CGRectMake(0, ScreenHeight - self.keyboardHeight - textViewHeight, ScreenWidth, self.keyboardHeight + textViewHeight);
        if (self.delegate) {
            [self.delegate onChatViewHeightChange:self.container.frame.size.height];
        }
    } completion:^(BOOL finished) {
        
    }];
    
    
}


#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
    if (!textView.hasText) {
        _placeholderLabel.hidden = NO;
        _textHeight = ceilf(_textView.font.lineHeight);
    }else {
        _placeholderLabel.hidden = YES;
        _textHeight = [attributedStr multiLineSize:ScreenWidth - kChatTextViewLeftInset - kChatTextViewRightInset].height;
    }
    [self updateContainerFrame];
    
    
}

#pragma mark - KeyboardNotification

- (void)keyboardWillShow:(NSNotification *)notificatoin {
    _editMessageType = ChatEditMessageTypeText;
    NSDictionary *userInfo = [notificatoin userInfo];
    CGFloat keyBoardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

    self.keyboardHeight = keyBoardHeight;
    [self updateContainerFrame];
    
    
}


- (void)hideKeyboard {
    _editMessageType = ChatEditMessageTypeNone;
    self.keyboardHeight = SafeAreaBottomHeight;
    [self updateContainerFrame];
    [_textView resignFirstResponder];
}






- (void)show {
    UIView *window = [[[UIApplication sharedApplication]delegate]window];
    [window addSubview:self];
}




- (EmotionSelector *)emotionSelector {
    if (!_emotionSelector) {
        _emotionSelector = [[EmotionSelector alloc]init];
    }
    return _emotionSelector;
}
@end
