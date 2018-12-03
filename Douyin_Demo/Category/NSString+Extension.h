//
//  NSString+Extension.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extension)



- (NSString *)md5;


//获取当前时间戳
+ (NSString *)currentTime;
@end

NS_ASSUME_NONNULL_END
