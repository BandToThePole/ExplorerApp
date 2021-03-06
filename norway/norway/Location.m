//
//  Location.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "Location.h"
#import "RecordingSession.h"

@implementation Location

- (instancetype)initWithTime:(NSDate *)date lat:(double)latitude long:(double)longitude {
    if (self = [super init]) {
        self.time = date;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

- (instancetype)initWithQuery:(Query *)query {
    self = [super initWithQuery:query];
    if (self) {
        self.time = [query dateColumn:2];
        self.latitude = [query doubleColumn:3];
        self.longitude = [query doubleColumn:4];
    }
    return self;
}

- (BOOL)save:(SerializedDatabase *)serializedDB {
    __block BOOL success;
    [serializedDB serialTransaction:^(sqlite3 *db) {
        if (self.databaseID == 0) {
            Query * query = [[Query alloc] initWithDatabase:db string:@"INSERT INTO locations(time,lat,long,session) VALUES (?,?,?,?)", self.time, @(self.latitude), @(self.longitude), @(self.session.databaseID), nil];
            success = [query execute];
            if (success) {
                self.databaseID = (NSInteger)[serializedDB lastInsertID];
            }
        }
        else {
            Query * query = [[Query alloc] initWithDatabase:db string:@"UPDATE locations SET time = ?, lat = ?, long = ?,session = ? WHERE locationid = ?", self.time, @(self.latitude), @(self.longitude), @(self.session.databaseID), @(self.databaseID), nil];
            success = [query execute];
        }
    }];
    return success;
}

- (NSDictionary*)serializedDictionaryWithFormatter:(NSDateFormatter *)formatter sinceDate:(NSDate *)date {
    return @{ @"dt": @((NSInteger)round([self.time timeIntervalSinceDate:date])), @"lat": @(self.latitude), @"long": @(self.longitude) };
}

- (NSString*)stringValue {
    return [NSString stringWithFormat:@"%f,%f", self.latitude, self.longitude];
}

- (BOOL)canCoalesceWith:(DatabaseObject *)other {
    Location * otherLoc = (Location*)other;
    return [other isKindOfClass:[self class]] && otherLoc.latitude == self.latitude && otherLoc.longitude == self.longitude;
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coord;
    coord.longitude = self.longitude;
    coord.latitude = self.latitude;
    return coord;
}

@end
