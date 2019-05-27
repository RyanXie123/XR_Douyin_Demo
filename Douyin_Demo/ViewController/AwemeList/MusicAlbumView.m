//
//  MusicAlbumView.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2019/5/26.
//  Copyright © 2019 谢汝. All rights reserved.
//

#import "MusicAlbumView.h"

@interface MusicAlbumView ()
@property (nonatomic, strong) UIView *albumContainer;
@property (nonatomic, strong) NSMutableArray<CALayer *> *noteLayers;
@end

@implementation MusicAlbumView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 50, 50)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        
        _albumContainer = [[UIView alloc]initWithFrame:self.bounds];
        [self addSubview:_albumContainer];
        _noteLayers = [NSMutableArray array];
        
        
        CALayer *backgroundLayer = [CALayer layer];
        backgroundLayer.frame = self.bounds;
        backgroundLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"music_cover"].CGImage);
        [_albumContainer.layer addSublayer:backgroundLayer];
        
        _album = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 20, 20)];
        _album.contentMode = UIViewContentModeScaleAspectFill;
        [_albumContainer addSubview:_album];

    }
    return self;
}
- (void)resetView {
    
    [_noteLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [self.layer removeAllAnimations];
}

- (void)startAnimation:(CGFloat)rate {
    [self resetView];
    rate = rate<=0?15:rate;
    [self initMusicNoteAnimation:@"icon_home_musicnote1" delayTime:0.0f rate:rate];
    [self initMusicNoteAnimation:@"icon_home_musicnote2" delayTime:1.0f rate:rate];
    [self initMusicNoteAnimation:@"icon_home_musicnote3" delayTime:2.0f rate:rate];
    
    
    
    CABasicAnimation *rotationAnition = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnition.toValue = @(2 * M_PI);
    rotationAnition.duration = 3;
    rotationAnition.cumulative = YES;
    rotationAnition.repeatCount = MAXFLOAT;
    [self.albumContainer.layer addAnimation:rotationAnition forKey:nil];
    
}

- (void)initMusicNoteAnimation:(NSString *)imageName delayTime:(NSTimeInterval)delayTime rate:(CGFloat)rate {
    CAAnimationGroup *animatinGroup = [CAAnimationGroup new];
    animatinGroup.duration = rate/4;
    animatinGroup.beginTime = CACurrentMediaTime() + delayTime;
    animatinGroup.repeatCount = MAXFLOAT;
    animatinGroup.removedOnCompletion = NO;
    animatinGroup.fillMode = kCAFillModeForwards;
    animatinGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    //bezier 路径动画
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGFloat sideXLength = 40.0f;
    CGFloat sideYLength = 100.0f;
    
    CGPoint beginPoint = CGPointMake(CGRectGetMidX(self.bounds) - 5, CGRectGetMaxY(self.bounds));
    CGPoint endPoint = CGPointMake(beginPoint.x - sideXLength, beginPoint.y - sideYLength);
    
    CGFloat controlLength = 60.0f;
    CGPoint controlPoint = CGPointMake(beginPoint.x - sideXLength/2.0f - controlLength, beginPoint.y - sideYLength/2 + controlLength);
    
    UIBezierPath *customPath = [UIBezierPath bezierPath];
    [customPath moveToPoint:beginPoint];
    [customPath addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    pathAnimation.path = customPath.CGPath;
    
    
    //旋转动画
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    [rotationAnimation setValues:@[[NSNumber numberWithFloat:0],
                                   [NSNumber numberWithFloat:M_PI * 0.1],
                                   [NSNumber numberWithFloat:M_PI * (-0.1)]]];
    
    //透明度动画
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    [opacityAnimation setValues:@[[NSNumber numberWithFloat:0],
                                  [NSNumber numberWithFloat:0.2f],
                                  [NSNumber numberWithFloat:0.7f],
                                  [NSNumber numberWithFloat:0.2f],
                                  [NSNumber numberWithFloat:0]]];
    
    
    //缩放动画
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(1.0f);
    scaleAnimation.toValue = @(2.0f);
    
    [animatinGroup setAnimations:@[pathAnimation,rotationAnimation,opacityAnimation,scaleAnimation]];
    
    
    CAShapeLayer *noteLayer = [CAShapeLayer layer];
    noteLayer.opacity = 0.0f;
    noteLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:imageName].CGImage);
    noteLayer.frame = CGRectMake(beginPoint.x, beginPoint.y, 10, 10);
    [self.layer addSublayer:noteLayer];
    [_noteLayers addObject:noteLayer];
    [noteLayer addAnimation:animatinGroup forKey:nil];
    
}



@end
