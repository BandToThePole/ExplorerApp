//
//  SyncAccount.m
//  norway
//
//  Created by Thomas Denney on 25/04/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "SyncAccount.h"
#import "KeychainWrapper.h"
#import <Security/Security.h>

@implementation SyncAccount

+ (KeychainWrapper*)wrapper {
    static KeychainWrapper * wrapper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [[KeychainWrapper alloc] init];
    });
    return wrapper;
}

+ (BOOL)isSignedIn {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"signedin"];
}

+ (void)signOut {
    [[SyncAccount wrapper] resetKeychainItem];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"signedin"];
    [defaults synchronize];
}

+ (NSString*)username {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"username"];
}

+ (NSString*)password {
    return [[SyncAccount wrapper] myObjectForKey:(__bridge id)kSecValueData];
}

+ (void)setUsername:(NSString *)username passwword:(NSString *)password {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:@"username"];
    [defaults setBool:YES forKey:@"signedin"];
    [[SyncAccount wrapper] mySetObject:password forKey:(__bridge id)kSecValueData];
}


@end
