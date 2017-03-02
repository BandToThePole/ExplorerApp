//
//  NorwayDatabase.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "NorwayDatabase.h"
#import "NSArray+NWY.h"

#import <compression.h>

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
        success = success && [[[Query alloc] initWithDatabase:db string:@"CREATE TABLE IF NOT EXISTS calories (calorieid INTEGER PRIMARY KEY AUTOINCREMENT, session INTEGER, time REAL, kcalcount INTEGER, FOREIGN KEY(session) REFERENCES sessions(sessionid))", nil] execute];
        success = success && [[[Query alloc] initWithDatabase:db string:@"CREATE TABLE IF NOT EXISTS distances (distanceid INTEGER PRIMARY KEY AUTOINCREMENT, session INTEGER, time REAL, distance INTEGER, speed REAL, pace REAL, motion TEXT, FOREIGN KEY(session) REFERENCES sessions(sessionid))", nil] execute];
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

- (NSArray<RecordingSession*>*)allSessions {
    NSMutableArray * sessions = [NSMutableArray new];
    [self.serialDB serialTransaction:^(sqlite3 *db) {
        Query * sessionsQuery = [[Query alloc] initWithDatabase:db string:@"SELECT * FROM sessions", nil];
        while ([sessionsQuery next]) {
            RecordingSession * session = [[RecordingSession alloc] initWithQuery:sessionsQuery];
            
            Query * locations = [[Query alloc] initWithDatabase:db string:@"SELECT * FROM locations WHERE session = ?", @(session.databaseID), nil];
            while ([locations next]) {
                [session addLocation:[[Location alloc] initWithQuery:locations]];
            }
            
            Query * heartrates = [[Query alloc] initWithDatabase:db string:@"SELECT * FROM heartrates WHERE session = ?", @(session.databaseID), nil];
            while ([heartrates next]) {
                [session addHeartRate:[[HeartRate alloc] initWithQuery:heartrates]];
            }
            
            Query * calories = [[Query alloc] initWithDatabase:db string:@"SELECT * FROM calories WHERE session = ?", @(session.databaseID), nil];
            while ([calories next]) {
                [session addCalories:[[Calories alloc] initWithQuery:calories]];
            }
            
            Query * distances = [[Query alloc] initWithDatabase:db string:@"SELECT * FROM distances WHERE session = ?", @(session.databaseID), nil];
            while ([distances next]) {
                [session addDistance:[[Distance alloc] initWithQuery:distances]];
            }
            
            [sessions addObject:session];
        }
    }];
    return sessions;
}

+ (NSDictionary*)serializeSessions:(NSArray<RecordingSession *> *)sessions {
    NSISO8601DateFormatter * df = [NSISO8601DateFormatter new];
    return @{ @"recording_sessions": [sessions nwy_map:^id(id x) {
        return [x serializedDictionaryWithFormatter:df sinceDate:[x startDate]];
    }] };
}

+ (NSData*)encodeDictionary:(NSDictionary *)dict zlibCompress:(BOOL)compress {
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    if (compress) {
        // I don't actually know how big this out to be
        size_t dstBufferLen = data.length * 2;
        uint8_t * dstBuffer = calloc(dstBufferLen, sizeof(uint8_t));
        dstBufferLen = compression_encode_buffer(dstBuffer, dstBufferLen, data.bytes, data.length, NULL, COMPRESSION_ZLIB);
        if (dstBufferLen > 0) {
            // This method copies the
            data = [NSData dataWithBytes:dstBuffer length:dstBufferLen];
        }
        free(dstBuffer);
    }
    
    return data;
}

@end
