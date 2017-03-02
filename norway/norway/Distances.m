//
//  Distances.m
//  norway
//
//  Created by Thomas Denney on 02/03/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "Distances.h"
#import "RecordingSession.h"

@implementation Distances

- (instancetype)initWithTime:(NSDate *)date distance:(NSUInteger)distance speed:(double)speed pace:(double)pace motionType:(NSString*)motionType {
    if (self = [super init]) {
        self.time = date;
        self.totalDistance = distance;
        self.speed = speed;
        self.pace = pace;
        self.motionType = motionType;
    }
    return self;
}

- (instancetype)initWithQuery:(Query *)query {
    self = [super initWithQuery:query];
    if (self) {
        self.time = [query dateColumn:2];
        self.totalDistance = [query integerColumn:3];
        self.speed = [query doubleColumn:4];
        self.pace = [query doubleColumn:5];
        self.motionType = [query stringColumn:6];
    }
    return self;
}

- (BOOL)save:(SerializedDatabase *)serializedDB {
    __block BOOL success;
    [serializedDB serialTransaction:^(sqlite3 *db) {
        if (self.databaseID == 0) {
            Query * query = [[Query alloc] initWithDatabase:db string:@"INSERT INTO distances(time,distance,speed,pace,motion,session) VALUES (?,?,?,?,?,?)", self.time, @(self.totalDistance), @(self.speed), @(self.pace), self.motionType, @(self.session.databaseID), nil];
            success = [query execute];
            if (success) {
                self.databaseID = [serializedDB lastInsertID];
            }
        }
        else {
            Query * query = [[Query alloc] initWithDatabase:db string:@"UPDATE distances SET time = ?, distance = ?, speed = ?, pace = ?, motion = ?, session = ? WHERE locationid = ?", self.time, @(self.totalDistance), @(self.speed), @(self.pace), self.motionType, @(self.session.databaseID), @(self.databaseID), nil];
            success = [query execute];
        }
    }];
    return success;
}

- (NSDictionary*)serializedDictionaryWithFormatter:(NSISO8601DateFormatter *)formatter {
    return @{ @"time": [formatter stringFromDate:self.time],
              @"distance": @(self.totalDistance),
              @"speed": @(self.speed),
              @"pace": @(self.pace),
              @"motion": self.motionType
            };
}

@end