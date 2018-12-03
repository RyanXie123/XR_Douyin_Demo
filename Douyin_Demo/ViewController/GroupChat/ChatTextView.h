//
//  ChatTextView.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/3.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>

//chat edit message type enum
typedef NS_ENUM(NSUInteger, ChatEditMessageType) {
    ChatEditMessageTypeText,
    ChatEditMessageTypePhoto,
    ChatEditMessageTypeEmotion,
    ChatEditMessageTypeNone
};


@protocol ChatTextViewDelegate <NSObject>

@required

- (void)onChatViewHeightChange:(CGFloat)height;

@end


NS_ASSUME_NONNULL_BEGIN

@interface ChatTextView : UIView

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) ChatEditMessageType editMessageType;

- (void)show;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
