//
//  SerializedDatabase.m
//  norway
//
//  Created by Thomas Denney on 24/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "SerializedDatabase.h"
#import "Query.h"

NSString * SerializedDatabaseError = @"SerializedDatabaseError";

@interface SerializedDatabase () {
    sqlite3 * _db;
    dispatch_queue_t _queue;
}

@property BOOL isReadOnly;

@end

@implementation SerializedDatabase

-(instancetype)initWithPath:(NSString *)path readOnly:(BOOL)readOnly error:(NSError *__autoreleasing *)error {
    if (self = [super init]) {
        self.isReadOnly = readOnly;
        BOOL success = NO;
        if (readOnly) {
            success = sqlite3_open_v2(path.UTF8String, &_db, SQLITE_OPEN_READONLY, NULL) == SQLITE_OK;
        }
        else {
            success = sqlite3_open(path.UTF8String, &_db) == SQLITE_OK;
        }
        
        if (!success) {
            *error = [NSError errorWithDomain:SerializedDatabaseError code:1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:sqlite3_errmsg(_db)]}];
            sqlite3_close(_db);
            return nil;
        }
        
        _queue = dispatch_queue_create("org.thomasdenney.serialdb.norway", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_db);
    _db = NULL;
}

- (sqlite3_int64)lastInsertID {
    // TODO: Verify whether this needs to be done in serial (IIRC it doesn't need to be)
    return sqlite3_last_insert_rowid(_db);
}

- (void)serialTransaction:(void (^)(sqlite3*))transaction {
    dispatch_sync(_queue, ^{
        transaction(_db);
    });
}

- (BOOL)execute:(NSString *)query {
    return [[[Query alloc] initWithDatabase:_db string:query, nil] execute];
}

- (NSArray<NSString*>*)columnNames:(NSString*)tableName {
    NSMutableArray<NSString*> * names = [NSMutableArray new];
    [self serialTransaction:^(sqlite3 *db) {
        Query * q = [[Query alloc] initWithDatabase:db string:[NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName], nil];
        while ([q next]) {
            [names addObject:[q stringColumn:1]]; // cid, name, type, notnull, dflt_value, pk
        }
    }];
    return names;
}

@end
