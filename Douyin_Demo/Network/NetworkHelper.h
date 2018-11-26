//
//  NetworkHelper.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/24.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>
#import "BaseRequest.h"
#import "VisitorResponse.h"

extern NSString *const BaseUrl;
extern NSString *const NetworkDomain;
extern NSString *const NetworkStatusChangeNotification;

typedef enum {
    HttpResquestFailed = -1000,
    UrlResourceFailed = -2000
} NetworkError;

typedef void(^UploadProgress)(CGFloat percent);
typedef void(^HttpSuccess)(id data);
typedef void(^HttpFailure)(NSError *error);

@interface NetworkHelper : NSObject


+ (AFHTTPSessionManager *)sharedManager;
+ (NSURLSessionTask *)getWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure;
+ (NSURLSessionDataTask *)postWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure;
+ (NSURLSessionDataTask *)uploadWithUrlPath:(NSString *)urlPath data:(NSData *)data request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure;
+ (NSURLSessionDataTask *)uploadWithUrlPath:(NSString *)urlPath dataArray:(NSArray<NSData *> *)dataArray request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure;


+ (AFNetworkReachabilityManager *)sharedRechabilityManager;
+ (void)startListening;
+ (AFNetworkReachabilityStatus)networkStatus;
+ (BOOL)isNotReachabelStatus:(AFNetworkReachabilityStatus)status;

@end


