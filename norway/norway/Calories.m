//
//  Calories.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "Calories.h"
#import "RecordingSession.h"

@implementation Calories

- (instancetype)initWithTime:(NSDate *)time totalCalories:(NSInteger)kcalCount {
    if (self = [super init]) {
        self.time = time;
        self.kcalCount = kcalCount;
    }
    return self;
}

- (BOOL)save:(SerializedDatabase *)database {
    __block BOOL success = NO;
    [database serialTransaction:^(sqlite3 *db) {
        if (self.databaseID == 0) {
            Query * query = [[Query alloc] initWithDatabase:db string:@"INSERT INTO calories(time,session,count) VALUES(?,?,?)", self.time, @(self.session.databaseID), @(self.kcalCount), nil];
            success = [query execute];
            if (success) {
                self.databaseID = database.lastInsertID;
            }
        }
        else {
            Query * query = [[Query alloc] initWithDatabase:db string:@"UPDATE calories SET time=?, session=?, count=? WHERE calorieid = ?", self.time, @(self.session.databaseID), @(self.kcalCount), @(self.databaseID), nil];
            success = [query execute];
        }
    }];
    return success;
}

@end
