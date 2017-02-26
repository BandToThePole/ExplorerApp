//
//  DatabaseObject.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "DatabaseObject.h"

@implementation DatabaseObject

- (BOOL)save:(SerializedDatabase *)serialDB {
    return YES;
}

- (NSDictionary*)serializedDictionaryWithFormatter:(NSDateFormatter *)formatter {
    return @{};
}

@end
