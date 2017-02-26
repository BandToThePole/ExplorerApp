//
//  Query.m
//  norway
//
//  Created by Thomas Denney on 25/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "Query.h"
#import "NSNumber+NWY.h"

@interface Query () {
    sqlite3_stmt * _statement;
}

@property NSString * queryString;
@property NSArray * queryParams;
@property NSDictionary * columns;

@end

@implementation Query

- (instancetype)initWithDatabase:(sqlite3 *)database string:(NSString *)query, ... {
    if (self = [super init]) {
        self.queryString = query;
        int status = sqlite3_prepare_v2(database, query.UTF8String, -1, &_statement, NULL) == SQLITE_OK;
        if (!status) {
            NSLog(@"Error creating query %s", sqlite3_errmsg(database));
            return nil;
        }
        
        // TODO: Check status
        
        NSMutableArray * params = [NSMutableArray new];
        va_list args;
        va_start(args, query);
        id arg = nil;
        while ((arg = va_arg(args, id))) {
            [params addObject:arg];
            if ([arg isKindOfClass:[NSNumber class]]) {
                NSNumber * num = arg;
                if ([num nwy_isFloatingPoint]) {
                    sqlite3_bind_double(_statement, (int)params.count, num.doubleValue);
                }
                else {
                    sqlite3_bind_int64(_statement, (int)params.count, num.integerValue);
                }
            }
            else if ([arg isKindOfClass:[NSDate class]]) {
                NSDate * date = arg;
                sqlite3_bind_double(_statement, (int)params.count, date.timeIntervalSinceReferenceDate);
            }
            else if ([arg isKindOfClass:[NSString class]]) {
                NSString * str = arg;
                sqlite3_bind_text(_statement, (int)params.count, str.UTF8String, -1, SQLITE_TRANSIENT);
            }
            
        }
        va_end(args);
        self.queryParams = params;
    }
    return self;
}

- (void)dealloc {
    sqlite3_finalize(_statement);
}

- (void)execute:(sqlite3 *)database {
    
}

- (BOOL)execute {
    int result = sqlite3_step(_statement);
//    NSLog(@"%s", sqlite3_errmsg(sqlite3_db))
    return result == SQLITE_ROW || result == SQLITE_DONE;
}

- (BOOL)next {
    return sqlite3_step(_statement) == SQLITE_ROW;
}

- (NSInteger)columnIndex:(NSString *)name {
    if (!self.columns) {
        NSMutableDictionary * columns = [NSMutableDictionary new];
        int colCount = sqlite3_column_count(_statement);
        for (int i = 0; i < colCount; i++) {
            NSString * colName = [NSString stringWithUTF8String:sqlite3_column_name(_statement, i)];
            columns[colName.lowercaseString] = @(i);
        }
    }
    return [self.columns objectForKey:name.lowercaseString] ? [[self.columns objectForKey:name.lowercaseString] integerValue] : -1;
}

- (double)doubleColumn:(NSInteger)column {
    return sqlite3_column_double(_statement, (int)column);
}

- (NSInteger)integerColumn:(NSInteger)column {
    return (NSInteger)sqlite3_column_int64(_statement, (int)column);
}

- (NSDate*)dateColumn:(NSInteger)column {
    return [NSDate dateWithTimeIntervalSinceReferenceDate:sqlite3_column_double(_statement, (int)column)];
}

- (NSString*)stringColumn:(NSInteger)column {
    if (sqlite3_column_type(_statement, (int)column) == SQLITE_NULL) {
        return nil;
    }
    return [NSString stringWithUTF8String:(const char*)sqlite3_column_text(_statement, (int)column)];
}

@end
