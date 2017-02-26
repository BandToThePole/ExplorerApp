//
//  RecordingSession.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "RecordingSession.h"
#import "Query.h"
#import "NSArray+NWY.h"

@interface RecordingSession ()

@property NSMutableArray<HeartRate*>* heartDataMutable;
@property NSMutableArray<Calories*>* caloriesMutable;
@property NSMutableArray<Location*>* locationsMutable;

@end

@implementation RecordingSession

- (instancetype)init {
    if (self = [super init]) {
        self.heartDataMutable = [NSMutableArray new];
        self.caloriesMutable = [NSMutableArray new];
        self.locationsMutable = [NSMutableArray new];
        
        self.startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
        self.endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    }
    return self;
}

- (instancetype)initWithQuery:(Query *)query {
    if (self = [super initWithQuery:query]) {
        self.heartDataMutable = [NSMutableArray new];
        self.caloriesMutable = [NSMutableArray new];
        self.locationsMutable = [NSMutableArray new];
        
        self.startDate = [query dateColumn:2];
        self.endDate = [query dateColumn:3];
    }
    return self;
}

- (BOOL)save:(SerializedDatabase *)serialDB {
    __block BOOL success = NO;
    [serialDB serialTransaction:^(sqlite3 *db) {
        if (self.databaseID == 0) {
            Query * query = [[Query alloc] initWithDatabase:db string:@"INSERT INTO sessions(start, end) VALUES(?,?)", @(self.startDate.timeIntervalSinceReferenceDate), @(self.endDate.timeIntervalSinceReferenceDate), nil];
            success = [query execute];
            if (success) {
                self.databaseID = [serialDB lastInsertID];
            }
        }
        else {
            Query * query = [[Query alloc] initWithDatabase:db string:@"UPDATE sessions SET start=?,end=? WHERE sessionid = ?", self.startDate, self.endDate, @(self.databaseID), nil];
            success = [query execute];
        }
    }];
    return success;
}

- (void)start {
    self.startDate = [NSDate date];
}

- (void)end {
    self.endDate = [NSDate date];
}

- (void)addHeartRate:(HeartRate *)heartRateDatum {
    heartRateDatum.session = self;
    [self.heartDataMutable addObject:heartRateDatum];
}

- (void)addCalories:(Calories *)caloriesDatum {
    caloriesDatum.session = self;
    [self.caloriesMutable addObject:caloriesDatum];
}

- (void)addLocation:(Location *)locationDatum {
    locationDatum.session = self;
    [self.locationsMutable addObject:locationDatum];
}

- (NSArray<HeartRate*>*)heartData {
    return self.heartDataMutable;
}

- (NSArray<Calories*>*)calories {
    return self.caloriesMutable;
}

- (NSArray<Location*>*)locations {
    return self.locationsMutable;
}

- (NSDictionary*)serializedDictionaryWithFormatter:(NSISO8601DateFormatter *)formatter {
    return @{ @"start": [formatter stringFromDate:self.startDate],
              @"end": [formatter stringFromDate:self.endDate],
              // This would be much nicer in Swift (laughing crying face emoji)
              @"locations": [self.locations nwy_map:^id(id x) {
                  return [x serializedDictionaryWithFormatter:formatter];
              }],
              @"heart_rate": [self.heartData nwy_map:^id(id x) {
                  return [x serializedDictionaryWithFormatter:formatter];
              }],
              @"calories": [self.calories nwy_map:^id(id x) {
                  return [x serializedDictionaryWithFormatter:formatter];
              }] };
}

@end
