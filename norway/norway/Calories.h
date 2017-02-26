//
//  Calories.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializedDatabase.h"
#import "Query.h"

@class RecordingSession;

@interface Calories : NSObject

- (instancetype)initWithTime:(NSDate*)time totalCalories:(NSInteger)kcalCount;

@property NSInteger databaseID;
@property (weak) RecordingSession * session;
@property NSDate * time;
@property NSInteger kcalCount;

- (BOOL)save:(SerializedDatabase*)database;

@end
