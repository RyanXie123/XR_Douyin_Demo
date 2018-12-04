//
//  UIImage+Extension.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/29.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extension)
- (UIImage *)drawRoundedRectImage:(CGFloat)cornerRadius width:(CGFloat)width height:(CGFloat)height;
- (UIImage *)drawCircleImage;
@end

NS_ASSUME_NONNULL_END
