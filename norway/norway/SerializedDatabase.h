//
//  SerializedDatabase.h
//  norway
//
//  Created by Thomas Denney on 24/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

extern NSString * SerializedDatabaseError;

@interface SerializedDatabase : NSObject

- (instancetype)initWithPath:(NSString*)path readOnly:(BOOL)readOnly error:(NSError**)error;

- (sqlite3_int64)lastInsertID;

@property (readonly) BOOL isReadOnly;

- (void)serialTransaction:(void(^)(sqlite3 * db))transaction;

// Should only be called in a serialTransaction block
- (BOOL)execute:(NSString*)query;

- (NSArray<NSString*>*)columnNames:(NSString*)tableName;

@end
