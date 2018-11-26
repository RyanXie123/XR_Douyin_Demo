//
//  VisitorResponse.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "BaseResponse.h"
#import "Visitor.h"
NS_ASSUME_NONNULL_BEGIN

@interface VisitorResponse : BaseResponse
@property (nonatomic, copy) Visitor *data;
@end

NS_ASSUME_NONNULL_END
