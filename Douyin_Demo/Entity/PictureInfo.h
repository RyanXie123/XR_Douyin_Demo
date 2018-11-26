//
//  PictureInfo.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PictureInfo : BaseModel
@property (nonatomic, copy) NSString      *file_id;
@property (nonatomic, copy) NSString      *url;
@property (nonatomic, assign) NSInteger   width;
@property (nonatomic, assign) NSInteger   height;
@property (nonatomic, copy) NSString      *type;
@end

NS_ASSUME_NONNULL_END
