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

/**
 * Should be implemented by subclasses (Objective-C has a *very* weak type system compared to Scala so I can't force the `other` parameter to be of the same type as the subtype - I do abuse the very weak type system in other places though)
 */
- (BOOL)canCoalesceWith:(DatabaseObject*)other;

@end
