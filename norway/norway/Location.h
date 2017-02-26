//
//  Location.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializedDatabase.h"
#import "Query.h"

@class RecordingSession;

@interface Location : NSObject

// TODO: Use iOS locations APIs instead

- (instancetype)initWithTime:(NSDate*)date lat:(double)latitude long:(double)longitude;

@property NSInteger databaseID;
@property (weak) RecordingSession * session;
@property NSDate * time;
@property double latitude;
@property double longitude;

- (BOOL)save:(SerializedDatabase*)serializedDB;

@end
