//
//  AppDelegate.m
//  norway
//
//  Created by Thomas Denney on 24/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "AppDelegate.h"

@import MobileCenter;
@import MobileCenterAnalytics;
@import MobileCenterCrashes;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [MSMobileCenter start:@"b4eabb45-6563-40c0-ac58-61b548eea858" withServices:@[
                                                                                 [MSAnalytics class],
                                                                                 [MSCrashes class]
                                                                                 ]];
    
    // Override point for customization after application launch.
    SerializedDatabase * serialDB = [[SerializedDatabase alloc] initWithPath:[NorwayDatabase databasePath] readOnly:NO error:nil];
    self.database = [[NorwayDatabase alloc] initWithSerialDatabase:serialDB];
    self.connectionManager = [[ConnectionManager alloc] init];
    [self.connectionManager connectDefault];
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
