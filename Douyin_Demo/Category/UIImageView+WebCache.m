//
//  UIImageView+WebCache.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/3.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "Constants.h"
#import <objc/runtime.h>
@implementation UIImageView (WebCache)
- (void)setImageWithURL:(NSURL *)imageURL {
    [self cancelOperation];
    WebCombineOperation *operation = [[WebDownloader sharedDownloader]downloadWithURL:imageURL progressBlock:nil completedBlock:^(NSData *data, NSError *error, BOOL finished) {
        UIImage *image = [[UIImage alloc]initWithData:data];
        __weak typeof(self) weakSelf;
        dispatch_main_async_safe(^{
            weakSelf.image = image;
        });
    } cancelBlock:nil];
    
    objc_setAssociatedObject(self, &loadOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)setImageWithURL:(NSURL *)imageURL completedBlock:(WebImageCompletedBlock)completedBlock {
    [self cancelOperation];
    
    WebCombineOperation *operation = [[WebDownloader sharedDownloader]downloadWithURL:imageURL progressBlock:nil completedBlock:^(NSData *data, NSError *error, BOOL finished) {
        UIImage *image = [[UIImage alloc]initWithData:data];
        dispatch_main_async_safe(^{
            completedBlock(image,error);
        });
    } cancelBlock:nil];
    
    objc_setAssociatedObject(self, &loadOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)cancelOperation {
    WebCombineOperation *operation = objc_getAssociatedObject(self, &loadOperationKey);
    if (operation) {
        [operation cancel];
    }
}
@end
