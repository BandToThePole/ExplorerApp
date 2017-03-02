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

- (instancetype)initWithQuery:(Query *)query {
    if (self = [super initWithQuery:query]) {
        self.time = [query dateColumn:2];
        self.kcalCount = [query integerColumn:3];
        NSLog(@"Instantiated query from database with %lu", self.kcalCount);
    }
    return self;
}

- (BOOL)save:(SerializedDatabase *)database {
    __block BOOL success = NO;
    [database serialTransaction:^(sqlite3 *db) {
        if (self.databaseID == 0) {
            Query * query = [[Query alloc] initWithDatabase:db string:@"INSERT INTO calories(time,session,kcalcount) VALUES(?,?,?)", self.time, @(self.session.databaseID), @(self.kcalCount), nil];
            success = [query execute];
            if (success) {
                self.databaseID = database.lastInsertID;
            }
        }
        else {
            Query * query = [[Query alloc] initWithDatabase:db string:@"UPDATE calories SET time=?, session=?, kcalcount=? WHERE calorieid = ?", self.time, @(self.session.databaseID), @(self.kcalCount), @(self.databaseID), nil];
            success = [query execute];
        }
    }];
    return success;
}

- (NSDictionary*)serializedDictionaryWithFormatter:(NSISO8601DateFormatter *)formatter {
    return @{ @"time": [formatter stringFromDate:self.time], @"total_calories_since_start": @(self.kcalCount) };
}

- (NSString*)stringValue {
    return [NSString stringWithFormat:@"%lu kcal", self.kcalCount];
}

@end
