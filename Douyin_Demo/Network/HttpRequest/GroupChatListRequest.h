//
//  GroupChatListRequest.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/27.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "BaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupChatListRequest : BaseRequest
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger size;
@end

NS_ASSUME_NONNULL_END
