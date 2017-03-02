//
//  NorwayTests.m
//  NorwayTests
//
//  Created by Thomas Denney on 24/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NorwayDatabase.h"
#import "RecordingSession.h"
#import "HeartRate.h"
#import "Calories.h"
#import "Location.h"
#import "Distances.h"
#import "NSNumber+NWY.h"
#import "NSArray+NWY.h"

@interface NorwayTests : XCTestCase

@end

@implementation NorwayTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDatabaseCreation {
    NSError * error;
    
    SerializedDatabase * serialDB = [[SerializedDatabase alloc] initWithPath:@":memory:" readOnly:NO error:&error];
    XCTAssertNotNil(serialDB);

    NorwayDatabase * norwayDB = [[NorwayDatabase alloc] initWithSerialDatabase:serialDB];
    XCTAssertNotNil(norwayDB);

    [serialDB serialTransaction:^(sqlite3 *db) {
        Query * tables = [[Query alloc] initWithDatabase:db string:@"SELECT name FROM sqlite_master WHERE type='table'", nil];
        XCTAssertNotNil(tables);
        NSMutableSet * tableNames = [NSMutableSet new];
        while ([tables next]) {
            [tableNames addObject:[tables stringColumn:0]];
        }
        
        XCTAssert([tableNames containsObject:@"sessions"]);
        XCTAssert([tableNames containsObject:@"locations"]);
        XCTAssert([tableNames containsObject:@"heartrates"]);
        XCTAssert([tableNames containsObject:@"calories"]);
        XCTAssert([tableNames containsObject:@"distances"]);
    }];
    
    RecordingSession * session = [[RecordingSession alloc] init];
    XCTAssertNotNil(session);
    [session start];
    XCTAssert([session save:serialDB]);
    
    NSDate * heartRateDate = [session.startDate dateByAddingTimeInterval:1];
    
    NSISO8601DateFormatter * df = [NSISO8601DateFormatter new];
    
    for (int i = 0; i < 10; i++) {
        HeartRate * hr = [[HeartRate alloc] initWithTime:heartRateDate bpm:65 + i];
        [session addHeartRate:hr];
        XCTAssertNotNil([hr serializedDictionaryWithFormatter:df]);
        // For initial insertion
        XCTAssert([hr save:serialDB]);
        // Test update
        XCTAssert([hr save:serialDB]);
        
        Calories * kcal = [[Calories alloc] initWithTime:heartRateDate totalCalories:i * 1000];
        XCTAssertNotNil([kcal serializedDictionaryWithFormatter:df]);
        [session addCalories:kcal];
        XCTAssert([kcal save:serialDB]);
        XCTAssert([kcal save:serialDB]);
        
        Location * loc = [[Location alloc] initWithTime:heartRateDate lat:0 long:0];
        XCTAssertNotNil([loc serializedDictionaryWithFormatter:df]);
        [session addLocation:loc];
        XCTAssert([loc save:serialDB]);
        XCTAssert([loc save:serialDB]);
        
        Distances * distance = [[Distances alloc] initWithTime:heartRateDate distance:i speed:0 pace:0 motionType:@"running"];
        XCTAssertNotNil(distance);
        [session addDistance:distance];
        XCTAssert([loc save:serialDB]);
        XCTAssert([loc save:serialDB]);
        
        heartRateDate = [heartRateDate dateByAddingTimeInterval:1];
    }
    
    XCTAssertNotNil([session serializedDictionaryWithFormatter:df]);
    
    [session end];
    XCTAssert([session save:serialDB]);
    
    XCTAssertNotNil([norwayDB serializeSessions:[norwayDB allSessions]]);
}

- (void)testDatabaseDiskCreation {
    SerializedDatabase * serialDB = [[SerializedDatabase alloc] initWithPath:[NorwayDatabase databasePath] readOnly:NO error:nil];
    XCTAssertNotNil(serialDB);
}

- (void)testNumberTypes {
    XCTAssert([@(42) nwy_isInteger]);
    XCTAssert([@(42.0) nwy_isFloatingPoint]);
    XCTAssert([@(42.0f) nwy_isFloatingPoint]);
    XCTAssert([[NSNumber numberWithDouble:42] nwy_isFloatingPoint]);
    XCTAssert([[NSNumber numberWithFloat:42] nwy_isFloatingPoint]);
    XCTAssert([[NSNumber numberWithInteger:42] nwy_isInteger]);
    XCTAssert([[NSNumber numberWithInt:42] nwy_isInteger]);
}

- (void)testMapping {
    NSArray * original = @[@(0), @(1), @(2), @(3)];
    NSArray * doubled = [original nwy_map:^id(id x) {
        return @([x integerValue] * 2);
    }];
    
    XCTAssertEqual(original.count, doubled.count);
    
    for (NSInteger i = 0; i < original.count; i++) {
        XCTAssertEqual([original[i] integerValue] * 2, [doubled[i] integerValue]);
    }
}

@end
