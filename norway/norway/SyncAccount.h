//
//  SyncAccount.h
//  norway
//
//  Created by Thomas Denney on 25/04/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>

// Wrapper around iOS keychain API
@interface SyncAccount : NSObject

+ (BOOL)isSignedIn;
+ (void)signOut;

+ (NSString*)username;
+ (NSString*)password;

// https://username:password@bandtothepoleweb.azurewebsites.net/api/path
+ (NSURL*)apiUrl:(NSString*)path;

+ (NSURLSession*)defaultSession;

+ (void)setUsername:(NSString*)username password:(NSString*)password callback:(void(^)(BOOL))callback;

@end
