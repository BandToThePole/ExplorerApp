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

+ (NSURLSession*)defaultSession {
    static NSURLSession * session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return session;
}

+ (NSURL*)apiUrl:(NSString *)path {
    return [SyncAccount apiUrl:path username:[SyncAccount username] password:[SyncAccount password]];
}

+ (NSURL*)apiUrl:(NSString*)path username:(NSString*)username password:(NSString*)password {
    username = [username stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
    password = [password stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPasswordAllowedCharacterSet]];
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:%@@bandtothepoleweb.azurewebsites.net/api/%@", username, password, path]];
}

+ (void)setUsername:(NSString *)username password:(NSString *)password callback:(void (^)(BOOL))callback {
    NSURLSessionDataTask * task = [[SyncAccount defaultSession] dataTaskWithURL:[SyncAccount apiUrl:@"check" username:username password:password] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                callback(NO);
            }
            else {
                NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:username forKey:@"username"];
                    [defaults setBool:YES forKey:@"signedin"];
                    [[SyncAccount wrapper] mySetObject:password forKey:(__bridge id)kSecValueData];
                    callback(YES);
                }
                else {
                    callback(NO);
                }
            }
        });
    }];
    [task resume];
}


@end
