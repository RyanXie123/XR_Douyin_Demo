//
//  BaseViewController.h
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/24.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
- (void) initNavigationBarTransparent;

- (void) setBackgroundColor:(UIColor *)color;

- (void) setTranslucentCover;

- (void) initLeftBarButton:(NSString *)imageName;

- (void) setStatusBarHidden:(BOOL) hidden;

- (void) setStatusBarBackgroundColor:(UIColor *)color;

- (void) setNavigationBarTitle:(NSString *)title;

- (void) setNavigationBarTitleColor:(UIColor *)color;

- (void) setNavigationBarBackgroundColor:(UIColor *)color;

- (void) setNavigationBarBackgroundImage:(UIImage *)image;

- (void) setStatusBarStyle:(UIStatusBarStyle)style;

- (void) setNavigationBarShadowImage:(UIImage *)image;

- (void) back;

- (CGFloat) navagationBarHeight;

- (void) setLeftButton:(NSString *)imageName;

- (void) setBackgroundImage:(NSString *)imageName;
@end

NS_ASSUME_NONNULL_END
