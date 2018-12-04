//
//  UIImageView+WebCache.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/3.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebCacheHelper.h"
static char loadOperationKey;

typedef void(^WebImageCompletedBlock)(UIImage *image,NSError *error);
typedef void(^WebImageProgressBlock)(CGFloat progress);

@interface UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)imageURL;
- (void)setImageWithURL:(NSURL *)imageURL completedBlock:(WebImageCompletedBlock)completedBlock;
- (void)setImageWithURL:(NSURL *)imageURL progressBlock:(WebImageProgressBlock)progressBlock completedBlcok:(WebImageCompletedBlock)completedBlock;


@end


