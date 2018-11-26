//
//  Visitor.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "BaseModel.h"
#import "PictureInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface Visitor : BaseModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *udid;
@property (nonatomic , strong) PictureInfo         *avatar_thumbnail;
@property (nonatomic , strong) PictureInfo         *avatar_medium;
@property (nonatomic , strong) PictureInfo         *avatar_large;
@end

NS_ASSUME_NONNULL_END
