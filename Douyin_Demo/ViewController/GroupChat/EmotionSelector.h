//
//  EmotionSelector.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/5.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EmotionSelectorHeight 220 + SafeAreaBottomHeight

@interface EmotionSelector : UIView

@end


@interface EmotionCell : UITableViewCell
@property (nonatomic, copy) NSString *emotionKey;
@property (nonatomic, strong) UIImageView *emotion;


- (void)initData:(NSString *)key;
@end
