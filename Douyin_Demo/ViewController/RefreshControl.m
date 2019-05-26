//
//  RefreshControl.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/3.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "RefreshControl.h"

#import <Masonry.h>

@implementation RefreshControl

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, -50, ScreenWidth, 50)];
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _refreshState = RefreshHeaderStateIdle;
        _indicatorView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon60LoadingMiddle"]];
        [self addSubview:_indicatorView];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.mas_equalTo(25);
    }];
    
    if (!_superView) {
        _superView = (UIScrollView *)self.superview;
        [_superView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (_superView.isDragging && _refreshState == RefreshHeaderStateIdle && _superView.contentOffset.y < -80) {
            _refreshState = RefreshHeaderStatePulling;
        }
        
        if (!_superView.isDragging && _refreshState == RefreshHeaderStatePulling && _superView.contentOffset.y > -50) {
            [self startRefresh];
            _onRefresh();
        }
        
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)startRefresh {
    if (_refreshState != RefreshHeaderStateRefreshing) {
        _refreshState = RefreshHeaderStateRefreshing;
        UIEdgeInsets edgeInset = _superView.contentInset;
        edgeInset.top += 50;
        _superView.contentInset = edgeInset;
        
        [self startAnimation];
    }
}


- (void)endRefresh {
    if (_refreshState != RefreshHeaderStateIdle) {
        _refreshState = RefreshHeaderStateIdle;
        UIEdgeInsets edgeInset = _superView.contentInset;
        edgeInset.top -= 50;
        _superView.contentInset = edgeInset;
        
        [self stopAnimation];
    }
}


- (void)loadAll {
    _refreshState = RefreshHeaderStateAll;
    self.hidden = YES;
}

- (void)startAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(M_2_PI);
    animation.duration = 1.5;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    [self.indicatorView.layer addAnimation:animation forKey:@"rotationAnimation"];
}

- (void)stopAnimation {
    [self.indicatorView.layer removeAllAnimations];
}

@end
