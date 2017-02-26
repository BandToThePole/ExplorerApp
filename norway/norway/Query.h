//
//  Query.h
//  norway
//
//  Created by Thomas Denney on 25/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializedDatabase.h"

@interface Query : NSObject

// Also prepares the statement
- (instancetype)initWithDatabase:(sqlite3*)database string:(NSString*)query, ... NS_REQUIRES_NIL_TERMINATION;

// Use for queries
- (BOOL)next;

// Use for updates
- (BOOL)execute;

- (NSInteger)columnIndex:(NSString*)name;

- (double)doubleColumn:(NSInteger)column;
- (NSInteger)integerColumn:(NSInteger)column;
- (NSDate*)dateColumn:(NSInteger)column;
- (NSString*)stringColumn:(NSInteger)column;

@end
