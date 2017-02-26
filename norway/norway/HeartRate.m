//
//  HeartRate.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "HeartRate.h"
#import "RecordingSession.h"
#import "Query.h"

@interface HeartRate ()

@end

@implementation HeartRate

- (instancetype)initWithTime:(NSDate *)time bpm:(NSUInteger)bpm {
    if (self = [super init]) {
        self.time = time;
        self.bpm = bpm;
    }
    return self;
}

- (BOOL)save:(SerializedDatabase *)serialDB {
    __block BOOL success = NO;
    [serialDB serialTransaction:^(sqlite3 *db) {
        if (self.databaseID == 0) {
            Query * query = [[Query alloc] initWithDatabase:db string:@"INSERT INTO heartrates(time, bpm, session) VALUES (?, ?, ?)", self.time, @(self.bpm), @(self.session.databaseID), nil];
            success = [query execute];
            if (success) {
                self.databaseID = serialDB.lastInsertID;
            }
        }
        else {
            Query * query = [[Query alloc] initWithDatabase:db string:@"UPDATE heartrates SET time=?,bpm=?,session=? WHERE heartrateid=?", self.time, @(self.bpm), @(self.session.databaseID), @(self.databaseID), nil];
            success = [query execute];
        }
    }];
    return success;
}

@end
