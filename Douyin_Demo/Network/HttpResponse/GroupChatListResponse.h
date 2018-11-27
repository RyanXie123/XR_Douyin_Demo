//
//  GroupChatListResponse.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/27.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupChat.h"
#import "BaseResponse.h"
NS_ASSUME_NONNULL_BEGIN

@interface GroupChatListResponse : BaseResponse
@property (nonatomic, strong) NSArray<GroupChat> *data;
@end

NS_ASSUME_NONNULL_END
