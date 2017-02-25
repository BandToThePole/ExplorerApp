//
//  NorwayTests.m
//  NorwayTests
//
//  Created by Thomas Denney on 24/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SerializedDatabase.h"
#import "Query.h"

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
    [serialDB serialTransaction:^(sqlite3 *db) {
        Query * create = [[Query alloc] initWithDatabase:db string:@"CREATE TABLE IF NOT EXISTS sessions (id INTEGER PRIMARY KEY AUTOINCREMENT)", nil];
        XCTAssertNotNil(create);
        XCTAssert([create execute]);
    }];
}

@end
