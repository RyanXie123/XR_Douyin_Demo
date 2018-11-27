//
//  GroupChat.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "GroupChat.h"

@implementation GroupChat
+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    if([propertyName isEqualToString:@"taskId"]
       ||[propertyName isEqualToString:@"isTemp"]
       ||[propertyName isEqualToString:@"picImage"]
       ||[propertyName isEqualToString:@"contentSize"]
       ||[propertyName isEqualToString:@"cellHeight"]
       ||[propertyName isEqualToString:@"cellAttributedString"])
        return YES;
    return NO;
}
@end
