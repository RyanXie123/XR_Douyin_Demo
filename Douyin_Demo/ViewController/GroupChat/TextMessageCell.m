//
//  TextMessageCell.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "TextMessageCell.h"
static const CGFloat kTextMsgMaxWidth   = 220;


@implementation TextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        
        
    }
    return self;
}





+ (CGFloat)cellHeight:(GroupChat *)chat {
    return  chat.contentSize.height;
}

+ (CGSize)contentSize:(GroupChat *)chat {
    return [chat.cellAttributedString multiLineSize:kTextMsgMaxWidth];
}
@end
