//
//  RefreshControl.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/3.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, RefreshHeaderState) {
    RefreshHeaderStateIdle,
    RefreshHeaderStatePulling,
    RefreshHeaderStateRefreshing,
    RefreshHeaderStateAll
};


typedef void(^OnRefresh)(void);

@interface RefreshControl : UIControl


@property (nonatomic, strong) UIImageView *indicatorView;
@property (nonatomic, weak) UIScrollView *superView;
@property (nonatomic, assign) RefreshHeaderState refreshState;
@property (nonatomic, copy) OnRefresh onRefresh;


- (void)endRefresh;
- (void)loadAll;

@end


