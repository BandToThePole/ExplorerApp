//
//  NorwayDatabase.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializedDatabase.h"
#import "Query.h"
#import "RecordingSession.h"

@class NorwayDatabase;

@protocol NorwayDatabaseDelegate <NSObject>

- (void)syncCompletedSuccessfully;
- (void)syncFailedDueToLoginError;
- (void)syncFailedDueToNetworkError:(NSError*)error;

@end

@interface NorwayDatabase : NSObject

+ (NSString*)generateGUID;
+ (NSString*)databasePath;

// Creates tables on creation
- (instancetype)initWithSerialDatabase:(SerializedDatabase*)serialDB;

@property (readonly) SerializedDatabase * serialDB;

- (NSArray<RecordingSession*>*)allSessions;

+ (NSDictionary*)serializeSessions:(NSArray<RecordingSession*>*)sessions;
+ (NSData*)encodeDictionary:(NSDictionary*)dict zlibCompress:(BOOL)compress;

@property id<NorwayDatabaseDelegate> delegate;

+ (NSDate*)lastSync;
+ (NSInteger)lastSyncByteCount;
- (void)startSyncWithAllData:(BOOL)allData;
- (NSInteger)numberCanSync;

@end
