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

NSString * const RecordingSessionChanged = @"recordingSessionChanged";

@interface RecordingSession ()

@property NSMutableArray<HeartRate*>* heartDataMutable;
@property NSMutableArray<Calories*>* caloriesMutable;
@property NSMutableArray<Location*>* locationsMutable;
@property NSMutableArray<Distance*>* distancesMutable;

@end

@implementation RecordingSession

- (instancetype)init {
    if (self = [super init]) {
        self.heartDataMutable = [NSMutableArray new];
        self.caloriesMutable = [NSMutableArray new];
        self.locationsMutable = [NSMutableArray new];
        self.distancesMutable = [NSMutableArray new];
        
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
        self.distancesMutable = [NSMutableArray new];
        
        self.startDate = [query dateColumn:2];
        self.endDate = [query dateColumn:3];
    }
    return self;
}

- (BOOL)save:(SerializedDatabase *)serialDB {
    __block BOOL success = NO;
    [serialDB serialTransaction:^(sqlite3 *db) {
        if (self.databaseID == 0) {
            Query * query = [[Query alloc] initWithDatabase:db string:@"INSERT INTO sessions(start, end) VALUES(?,?)", self.startDate, self.endDate, nil];
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
    //TODO: Make more explicit with start/end
    [[NSNotificationCenter defaultCenter] postNotificationName:RecordingSessionChanged object:self];
}

- (void)end {
    self.endDate = [NSDate date];
    [[NSNotificationCenter defaultCenter] postNotificationName:RecordingSessionChanged object:self];
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

- (void)addDistance:(Distance*)distance {
    distance.session = self;
    [self.distancesMutable addObject:distance];
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

- (NSArray<Distance*>*)distances {
    return self.distancesMutable;
}

- (NSDictionary*)serializedDictionaryWithFormatter:(NSISO8601DateFormatter *)formatter sinceDate:(NSDate *)date {
    return @{ @"start": [formatter stringFromDate:self.startDate],
              @"end": [formatter stringFromDate:self.endDate],
              // This would be much nicer in Swift (laughing crying face emoji)
              @"locations": [[self coalesce:self.locations] nwy_map:^id(id x) {
                  return [x serializedDictionaryWithFormatter:formatter sinceDate:date];
              }],
              @"heart_rate": [[self coalesce:self.heartData] nwy_map:^id(id x) {
                  return [x serializedDictionaryWithFormatter:formatter sinceDate:date];
              }],
              @"calories": [[self coalesce:self.calories] nwy_map:^id(id x) {
                  return [x serializedDictionaryWithFormatter:formatter sinceDate:date];
              }],
              @"distances": [[self coalesce:self.distances] nwy_map:^id(id x) {
                  return [x serializedDictionaryWithFormatter:formatter sinceDate:date];
              }]
            };
}

- (NSArray<DatabaseObject*>*)coalesce:(NSArray<DatabaseObject*>*)objects {
    NSMutableArray<DatabaseObject*> * newArray = [NSMutableArray new];
    for (DatabaseObject * object in objects) {
        if (newArray.count == 0 || ![[newArray lastObject] canCoalesceWith:object]) {
            [newArray addObject:object];
        }
    }
    return newArray;
}

@end
