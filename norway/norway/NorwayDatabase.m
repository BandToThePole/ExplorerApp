//
//  NorwayDatabase.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "NorwayDatabase.h"
#import "NSArray+NWY.h"
#import "SyncAccount.h"

#import <compression.h>

@interface NorwayDatabase ()

@property NSOperationQueue * backgroundDataPrepQueue;

@property NSURLSessionDataTask * dataTask;

// Non-read only private version
@property SerializedDatabase * serialDB;

@property NSInteger databaseVersion;

@end

@implementation NorwayDatabase

+ (NSString*)generateGUID {
    NSUUID * guid = [NSUUID UUID];
    return guid.UUIDString;
}

+ (NSString*)databasePath {
    NSString * documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documents stringByAppendingPathComponent:@"documents.db"];
}

- (NSInteger)databaseVersion {
    __block NSInteger version = 0;
    [self.serialDB serialTransaction:^(sqlite3 *db) {
        Query * query = [[Query alloc] initWithDatabase:db string:@"PRAGMA user_version", nil];
        [query next];
        version = [query integerColumn:0];
    }];
    return version;
}

- (void)setDatabaseVersion:(NSInteger)databaseVersion {
    [self.serialDB serialTransaction:^(sqlite3 *db) {
        // Note that in order to change user_version you can't use placeholders, so its OK to use stringWithFormat here
        [[[Query alloc] initWithDatabase:db string:[NSString stringWithFormat:@"PRAGMA user_version = %ld", (long)databaseVersion], nil] execute];
    }];
}

- (void)_createGUIDsWhereNecessary {
    [self.serialDB serialTransaction:^(sqlite3 *db) {
        Query * sessions = [[Query alloc] initWithDatabase:db string:@"SELECT sessionid FROM sessions WHERE guid is null", nil];
        while ([sessions next]) {
            NSInteger databaseID = [sessions integerColumn:0];
            NSString * guid = [NorwayDatabase generateGUID];
            Query * update = [[Query alloc] initWithDatabase:db string:@"UPDATE sessions SET guid = ? WHERE sessionid = ?", guid, @(databaseID), nil];
            [update execute];
            NSLog(@"Had to add %@ to %ld", guid, (long)databaseID);
        }
    }];
}

- (BOOL)_createSchemaIfNecessary {
    __block BOOL success = NO;
    
    NSLog(@"Database version = %ld", (long)[self databaseVersion]);
    
    // Creates version 0 of the database
    [self.serialDB serialTransaction:^(sqlite3 *db) {
        success = [self.serialDB execute:@"CREATE TABLE IF NOT EXISTS sessions (sessionid INTEGER PRIMARY KEY AUTOINCREMENT, start REAL, end REAL)"];
        success = success && [self.serialDB execute:@"CREATE TABLE IF NOT EXISTS locations (locationid INTEGER PRIMARY KEY AUTOINCREMENT, session INTEGER, time REAL, lat REAL, long REAL, FOREIGN KEY(session) REFERENCES sessions(sessionid))"];
        success = success && [self.serialDB execute:@"CREATE TABLE IF NOT EXISTS heartrates (heartrateid INTEGER PRIMARY KEY AUTOINCREMENT, session INTEGER, time REAL, bpm INTEGER, FOREIGN KEY(session) REFERENCES sessions(sessionid))"];
        success = success && [self.serialDB execute:@"CREATE TABLE IF NOT EXISTS calories (calorieid INTEGER PRIMARY KEY AUTOINCREMENT, session INTEGER, time REAL, kcalcount INTEGER, FOREIGN KEY(session) REFERENCES sessions(sessionid))"];
        success = success && [self.serialDB execute:@"CREATE TABLE IF NOT EXISTS distances (distanceid INTEGER PRIMARY KEY AUTOINCREMENT, session INTEGER, time REAL, distance INTEGER, speed REAL, pace REAL, motion TEXT, FOREIGN KEY(session) REFERENCES sessions(sessionid))"];
    }];
    
    // Version 1 adds a boolean synced column to the sessions table
    if (self.databaseVersion < 1) {
        [self.serialDB serialTransaction:^(sqlite3 *db) {
            [self.serialDB execute:@"ALTER TABLE sessions ADD COLUMN synced INTEGER"];
        }];
        self.databaseVersion = 1;
    }
    
    // Version 2 adds a GUID column to the sessions table
    if (self.databaseVersion < 2) {
        [self.serialDB serialTransaction:^(sqlite3 *db) {
            [self.serialDB execute:@"ALTER TABLE sessions ADD COLUMN guid TEXT"];
        }];
        self.databaseVersion = 2;
    }
    
    // The original version of the app didn't store anything in the GUID column, so we need to fill that out
    [self _createGUIDsWhereNecessary];
    
    return success;
}

- (instancetype)initWithSerialDatabase:(SerializedDatabase *)serialDB {
    if (self = [super init]) {
        self.serialDB = serialDB;
        self.backgroundDataPrepQueue = [NSOperationQueue new];
        self.backgroundDataPrepQueue.maxConcurrentOperationCount = 1;
        if (![self _createSchemaIfNecessary]) {
            return nil;
        }
    }
    return self;
}

- (NSArray<RecordingSession*>*)allSessionsFromQuery:(Query*)sessionsQuery database:(sqlite3*)db {
    NSMutableArray<RecordingSession*>* sessions = [NSMutableArray new];
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
    return sessions;
}

- (NSArray<RecordingSession*>*)allSessions {
    __block NSArray * sessions = nil;
    [self.serialDB serialTransaction:^(sqlite3 *db) {
        Query * sessionsQuery = [[Query alloc] initWithDatabase:db string:@"SELECT * FROM sessions", nil];
        sessions = [self allSessionsFromQuery:sessionsQuery database:db];
    }];
    return sessions;
}

- (NSArray<RecordingSession*>*)allSessionsToSync:(BOOL)all {
    __block NSArray * sessions = nil;
    [self.serialDB serialTransaction:^(sqlite3 *db) {
        Query * sessionsQuery = [[Query alloc] initWithDatabase:db string:[NSString stringWithFormat:@"SELECT * FROM sessions WHERE end > start %@", all ? @"" : @"AND (synced = 0 OR synced IS NULL)"], nil];
        sessions = [self allSessionsFromQuery:sessionsQuery database:db];
    }];
    return sessions;
}

+ (NSDictionary*)serializeSessions:(NSArray<RecordingSession *> *)sessions {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return @{ @"recording_sessions": [sessions nwy_map:^id(id x) {
        return [x serializedDictionaryWithFormatter:dateFormatter sinceDate:[x startDate]];
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

+ (NSDate*)lastSync {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"lastSyncDate"];
}

+ (NSInteger)lastSyncByteCount {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"lastSyncByteCount"];
}

- (NSInteger)numberCanSync {
    __block NSInteger k = 0;
    [self.serialDB serialTransaction:^(sqlite3 *db) {
        // IS NULL required because the initial version didn't set the synced column
        Query * query = [[Query alloc] initWithDatabase:db string:@"SELECT COUNT(*) FROM sessions WHERE end > start AND (synced = 0 OR synced IS NULL)", nil];
        [query next];
        k = [query integerColumn:0];
    }];
    return k;
}

#pragma mark - Sync

- (void)startSyncWithAllData:(BOOL)allData {
    [self.backgroundDataPrepQueue addOperationWithBlock:^{
        if (self.dataTask) {
            // Terminate any existing sync sessions
            [self.dataTask cancel];
        }
        
        NSURL * url = [SyncAccount apiUrl:@"data"];
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
        urlRequest.HTTPMethod = @"POST";
        
        NSArray<RecordingSession*>* sessions = [self allSessionsToSync:allData];
        NSDictionary * sessionDict = [NorwayDatabase serializeSessions:sessions];
        NSData * compressedData = [NorwayDatabase encodeDictionary:sessionDict zlibCompress:YES];
        urlRequest.HTTPBody = compressedData;
        
        self.dataTask = [[SyncAccount defaultSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate syncFailedDueToNetworkError:error];
                });
            }
            else if (response) {
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    for (RecordingSession * session in sessions) {
                        [session markSynced];
                        [session save:self.serialDB];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:RecordingSessionChanged object:nil];
                    
                    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:[NSDate date] forKey:@"lastSyncDate"];
                    [defaults setInteger:compressedData.length forKey:@"lastSyncByteCount"];
                    [defaults synchronize];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate syncCompletedSuccessfully];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate syncFailedDueToLoginError];
                    });
                }
            }
        }];
        
        [self.dataTask resume];
    }];
}

@end
