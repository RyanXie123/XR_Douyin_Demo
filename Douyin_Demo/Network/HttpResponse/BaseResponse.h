//
//  BaseResponse.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "JSONModel.h"



@interface BaseResponse : JSONModel
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSInteger has_more;
@property (nonatomic, assign) NSInteger total_count;
@end


