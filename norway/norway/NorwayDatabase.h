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

@interface NorwayDatabase : NSObject

+ (NSString*)databasePath;

// Creates tables on creation
- (instancetype)initWithSerialDatabase:(SerializedDatabase*)serialDB;

@property (readonly) SerializedDatabase * serialDB;

- (NSArray<RecordingSession*>*)allSessions;

- (NSDictionary*)serializeSessions:(NSArray<RecordingSession*>*)sessions;

@end
