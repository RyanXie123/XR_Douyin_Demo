//
//  NSMutableAttributedString+Extension.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/27.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "NSMutableAttributedString+Extension.h"

@implementation NSMutableAttributedString (Extension)

- (CGSize)multiLineSize:(CGFloat)width {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}



@end
