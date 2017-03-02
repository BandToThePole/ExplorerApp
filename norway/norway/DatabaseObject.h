//
//  DatabaseObject.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializedDatabase.h"
#import "Query.h"

@interface DatabaseObject : NSObject

- (instancetype)initWithQuery:(Query*)query;

@property NSInteger databaseID;

- (BOOL)save:(SerializedDatabase*)serialDB;
- (NSDictionary*)serializedDictionaryWithFormatter:(NSISO8601DateFormatter*)formatter;

- (NSString*)stringValue;

@end
