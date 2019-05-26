//
//  AppDelegate.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/23.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ChatListController.h"
#import "NetworkHelper.h"
#import "AVPlayerManager.h"
#import "AwemeListController.h"
#import "Aweme.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"awemes" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *array = dic[@"data"];
   
    NSMutableArray *arrayM = [Aweme arrayOfModelsFromDictionaries:array].mutableCopy;
    
    AwemeListController *controller = [[AwemeListController alloc]initWithVideoData:arrayM currentIndex:0 pageIndex:1 pageSize:1 awemeType:AwemeWork uid:@"12"];
    
    
    _window.rootViewController = [[UINavigationController alloc]initWithRootViewController:controller];
    [_window makeKeyAndVisible];
    [NetworkHelper startListening];
    [AVPlayerManager setAudioMode];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
