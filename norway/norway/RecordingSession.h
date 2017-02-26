//
//  RecordingSession.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SerializedDatabase.h"
#import "HeartRate.h"
#import "Calories.h"
#import "Location.h"

@interface RecordingSession : NSObject

- (BOOL)save:(SerializedDatabase*)serialDB;

// 0 if not yet saved
@property NSInteger databaseID;
@property NSDate * startDate;
@property NSDate * endDate;

- (void)start;

- (void)addHeartRate:(HeartRate*)heartRateDatum;
- (void)addCalories:(Calories*)caloriesDatum;
- (void)addLocation:(Location*)locationDatum;

- (void)end;

@property (readonly) NSArray<HeartRate*>* heartData;
@property (readonly) NSArray<Calories*>* calories;
@property (readonly) NSArray<Location*>* locations;

@end
