//
//  UIImageView+WebCache.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/3.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "UIImageView+WebCache.h"

#import <objc/runtime.h>
@implementation UIImageView (WebCache)
- (void)setImageWithURL:(NSURL *)imageURL {
    [self cancelOperation];
    
    WebCombineOperation *operation = [[WebDownloader sharedDownloader]downloadWithUrl:imageURL progressBlock:nil completedBlock:^(NSData *data, NSError *error, BOOL finished) {
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

    
    WebCombineOperation *operation = [[WebDownloader sharedDownloader]downloadWithUrl:imageURL progressBlock:nil completedBlock:^(NSData *data, NSError *error, BOOL finished) {
        UIImage *image = [[UIImage alloc]initWithData:data];
        __weak typeof(self) weakSelf;
        dispatch_main_async_safe(^{
            weakSelf.image = image;
            completedBlock(image,error);
        });
    } cancelBlock:nil];
    
    objc_setAssociatedObject(self, &loadOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)setImageWithURL:(NSURL *)imageURL progressBlock:(WebImageProgressBlock)progressBlock completedBlcok:(WebImageCompletedBlock)completedBlock {
    [self cancelOperation];
    WebCombineOperation *operation =  [[WebDownloader sharedDownloader]downloadWithUrl:imageURL progressBlock:^(NSInteger receivedSize, NSInteger expectedSize, NSData *data) {
        NSString *percentStr = [NSString stringWithFormat:@"%.1f",(CGFloat)receivedSize/(CGFloat)expectedSize];
        CGFloat percent = [percentStr floatValue];
        dispatch_main_async_safe(^{
            progressBlock(percent);
        });
    } completedBlock:^(NSData *data, NSError *error, BOOL finished) {
        UIImage *image = [[UIImage alloc]initWithData:data];
        dispatch_main_async_safe(^{
            completedBlock(image,error);
        });
    } cancelBlock:^{
        
    }];
    objc_setAssociatedObject(self, &loadOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)cancelOperation {
    WebCombineOperation *operation = objc_getAssociatedObject(self, &loadOperationKey);
    if (operation) {
        [operation cancel];
    }
}
@end
