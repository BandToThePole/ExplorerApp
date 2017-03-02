//
//  DatabaseObject.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "DatabaseObject.h"

@implementation DatabaseObject

- (instancetype)initWithQuery:(Query *)query {
    self = [super init];
    if (self) {
        self.databaseID = [query integerColumn:0];
    }
    return self;
}

- (BOOL)save:(SerializedDatabase *)serialDB {
    return YES;
}

- (NSDictionary*)serializedDictionaryWithFormatter:(NSISO8601DateFormatter *)formatter {
    return @{};
}

- (NSString*)stringValue {
    return @"";
}

@end
