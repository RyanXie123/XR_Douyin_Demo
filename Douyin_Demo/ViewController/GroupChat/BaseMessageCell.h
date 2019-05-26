//
//  BaseMessageCell.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/27.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Masonry.h"
#import "GroupChat.h"
NS_ASSUME_NONNULL_BEGIN

@interface BaseMessageCell : UITableViewCell
+ (NSDictionary* )attributes;
+ (NSMutableAttributedString *)cellAttributedString:(GroupChat *)chat;


+ (CGSize)contentSize:(GroupChat *)chat;
+ (CGFloat)cellHeight:(GroupChat *)chat;

@end

NS_ASSUME_NONNULL_END
