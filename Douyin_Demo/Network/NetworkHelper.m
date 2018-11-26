//
//  NetworkHelper.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/24.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "NetworkHelper.h"
#import "Constants.h"

#import "VisitorRequest.h"

NSString *const BaseUrl = @"http://116.62.9.17:8080/douyin/";
NSString *const NetworkDomain = @"com.start.douyin";
NSString *const NetworkStatusChangeNotification = @"NetworkStatusChangeNotification";
//创建访客用户接口
NSString *const CreateVisitorPath = @"visitor/create";


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


+ (NSURLSessionDataTask *)getWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager]GET:[BaseUrl stringByAppendingString:urlPath] parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        //未连接到网络
        if(status == AFNetworkReachabilityStatusNotReachable) {
            [UIWindow showTips:@"未连接到网络"];
            failure(error);
            return ;
        }
    }];
}

+ (NSURLSessionDataTask *)postWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager]POST:[BaseUrl stringByAppendingString:urlPath] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


+ (NSURLSessionDataTask *)uploadWithUrlPath:(NSString *)urlPath data:(NSData *)data request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager]POST:[BaseUrl stringByAppendingString:urlPath] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"file" mimeType:@"multipart/form-data"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

+ (NSURLSessionDataTask *)uploadWithUrlPath:(NSString *)urlPath dataArray:(NSArray<NSData *> *)dataArray request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager]POST:[BaseUrl stringByAppendingString:urlPath] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSData *data in dataArray) {
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[NSString currentTime]];
            [formData appendPartWithFileData:data name:@"files" fileName:fileName mimeType:@"multipart/form-data"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}




#pragma mark - Recehability
+ (AFNetworkReachabilityManager *)sharedRechabilityManager {
    static dispatch_once_t onceToken;
    static AFNetworkReachabilityManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [AFNetworkReachabilityManager sharedManager];
    });
    return manager;
}
+ (void)startListening {
    [[NetworkHelper sharedRechabilityManager]startMonitoring];
    [[NetworkHelper sharedRechabilityManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NetworkStatusChangeNotification object:nil];
        if (![NetworkHelper isNotReachabelStatus:status]) {
            [NetworkHelper registerUserInfo];
        }
    }];
}
//+ (AFNetworkReachabilityStatus)networkStatus;
+ (BOOL)isNotReachabelStatus:(AFNetworkReachabilityStatus)status {
    return status == AFNetworkReachabilityStatusNotReachable;
}




+ (void)registerUserInfo {
    VisitorRequest *request = [VisitorRequest new];
    request.udid = UDID;
    [NetworkHelper postWithUrlPath:CreateVisitorPath request:request success:^(id data) {
        VisitorResponse *response = [[VisitorResponse alloc]initWithDictionary:data error:nil];
 
        Visitor *visitor = response.data;
        writeVisitor(visitor);
    } failure:^(NSError *error) {
        
    }];
}




@end
