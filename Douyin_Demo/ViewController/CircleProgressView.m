//
//  CircleProgressView.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/12/4.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "CircleProgressView.h"
#import "Constants.h"
@interface CircleProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end


@implementation CircleProgressView



- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 50, 50)];
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.backgroundColor = ColorBlackAlpha40.CGColor;
        self.layer.borderWidth = 1;
        self.layer.borderColor = ColorWhiteAlpha80.CGColor;
        
        
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = ColorWhiteAlpha80.CGColor;
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.width / 2;
}

- (UIBezierPath *)bezierPath:(CGFloat)progress {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:self.bounds.size.width/2 - 2 startAngle:-M_PI_2 endAngle:M_PI * 2 * progress - M_PI_2 clockwise:YES];
    [path addLineToPoint:center];
    [path closePath];
    return path;
}


- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _progressLayer.path = [self bezierPath:progress].CGPath;
}

@end
