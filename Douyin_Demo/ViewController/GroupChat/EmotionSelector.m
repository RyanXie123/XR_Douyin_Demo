//
//  EmotionSelector.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/5.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "EmotionSelector.h"

@implementation EmotionSelector


@end



@implementation EmotionCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _emotion = [[UIImageView alloc]initWithFrame:self.bounds];
        _emotion.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_emotion];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _emotion.image = nil;
}


- (void)initData:(NSString *)key {
    _emotionKey = key;
    NSString *emotionsPath = [[NSBundle mainBundle]pathForResource:@"Emoticons" ofType:@"bundle"];
    NSString *iconPath = [emotionsPath stringByAppendingPathComponent:key];
    _emotion.image = [UIImage imageWithContentsOfFile:iconPath];
    
}
@end
