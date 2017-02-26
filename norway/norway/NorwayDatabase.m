//
//  NorwayDatabase.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "NorwayDatabase.h"

@interface NorwayDatabase ()

// Non-read only private version
@property SerializedDatabase * serialDB;

@end

@implementation NorwayDatabase

+ (NSString*)databasePath {
    NSString * documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documents stringByAppendingPathComponent:@"documents.db"];
}

- (BOOL)_createSchemaIfNecessary {
    __block BOOL success = NO;
    [self.serialDB serialTransaction:^(sqlite3 *db) {
        success = [[[Query alloc] initWithDatabase:db string:@"CREATE TABLE IF NOT EXISTS sessions (sessionid INTEGER PRIMARY KEY AUTOINCREMENT, start REAL, end REAL)", nil] execute];
        success = success && [[[Query alloc] initWithDatabase:db string:@"CREATE TABLE IF NOT EXISTS locations (locationid INTEGER PRIMARY KEY AUTOINCREMENT, session INTEGER, time REAL, lat REAL, long REAL, FOREIGN KEY(session) REFERENCES sessions(sessionid))", nil] execute];
        success = success && [[[Query alloc] initWithDatabase:db string:@"CREATE TABLE IF NOT EXISTS heartrates (heartrateid INTEGER PRIMARY KEY AUTOINCREMENT, session INTEGER, time REAL, bpm INTEGER, FOREIGN KEY(session) REFERENCES sessions(sessionid))", nil] execute];
        success = success && [[[Query alloc] initWithDatabase:db string:@"CREATE TABLE IF NOT EXISTS calories (calorieid INTEGER PRIMARY KEY AUTOINCREMENT, session INTEGER, time REAL, count INTEGER, FOREIGN KEY(session) REFERENCES sessions(sessionid))", nil] execute];
    }];
    return success;
}

- (instancetype)initWithSerialDatabase:(SerializedDatabase *)serialDB {
    if (self = [super init]) {
        self.serialDB = serialDB;
        if (![self _createSchemaIfNecessary]) {
            return nil;
        }
    }
    return self;
}

@end
