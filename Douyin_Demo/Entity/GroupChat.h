//
//  GroupChat.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BaseModel.h"
#import "Visitor.h"
#import "PictureInfo.h"

@protocol GroupChat;


@interface GroupChat : BaseModel
@property (nonatomic , copy) NSString              *id;
@property (nonatomic , copy) NSString              *msg_type;
@property (nonatomic , copy) NSString              *msg_content;
@property (nonatomic , strong) Visitor             *visitor;
@property (nonatomic , strong) PictureInfo         *pic_original;
@property (nonatomic , strong) PictureInfo         *pic_large;
@property (nonatomic , strong) PictureInfo         *pic_medium;
@property (nonatomic , strong) PictureInfo         *pic_thumbnail;
@property (nonatomic , assign) NSInteger           create_time;



@property (nonatomic , assign) NSInteger                    taskId;
@property (nonatomic , assign) BOOL                         isTemp;
@property (nonatomic , assign) BOOL                         isFailed;
@property (nonatomic , assign) BOOL                         isCompleted;
@property (nonatomic , assign) CGFloat                      percent;
@property (nonatomic , strong) UIImage                      *picImage;
@property (nonatomic , assign) CGSize                       contentSize;
@property (nonatomic , assign) CGFloat                      cellHeight;
@property (nonatomic , strong) NSMutableAttributedString    *cellAttributedString;
@end


