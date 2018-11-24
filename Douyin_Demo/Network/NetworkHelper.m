//
//  NetworkHelper.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/24.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "NetworkHelper.h"

NSString *const BaseUrl = @"http://116.62.9.17:8080/douyin/";
NSString *const NetworkDomain = @"com.start.douyin";

@implementation NetworkHelper


+ (AFHTTPSessionManager *)sharedManager {
    static AFHTTPSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 15.0f;
    });
    return manager;
}

+ (void)processResponseData:(id)responseObject success:(HttpSuccess)success failure:(HttpFailure)failure{
    NSInteger code = -1;
    NSString *message = @"response data error";
    if([responseObject isKindOfClass:NSDictionary.class]) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        code = [(NSNumber *)[dic objectForKey:@"code"] integerValue];
        message = (NSString *)[dic objectForKey:@"message"];
    }
    if(code == 0){
        success(responseObject);
    }else{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message                                                                     forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:NetworkDomain code:HttpResquestFailed userInfo:userInfo];
        failure(error);
    }
}


+ (NSURLSessionTask *)getWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager]GET:[BaseUrl stringByAppendingString:urlPath] parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        //未连接到网络
        if(status == AFNetworkReachabilityStatusNotReachable) {
//            [UIWindow showTips:@"未连接到网络"];
            failure(error);
            return ;
        }
    }];
}






@end
