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

+ (void)setUsername:(NSString*)username passwword:(NSString*)password;

@end
