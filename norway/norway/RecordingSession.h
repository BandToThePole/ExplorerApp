//
//  RecordingSession.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "DatabaseObject.h"

#import "HeartRate.h"
#import "Calories.h"
#import "Location.h"
#import "Distance.h"

extern NSString * const RecordingSessionChanged;

@interface RecordingSession : DatabaseObject

@property NSDate * startDate;
@property NSDate * endDate;

- (void)start;

- (void)addHeartRate:(HeartRate*)heartRateDatum;
- (void)addCalories:(Calories*)caloriesDatum;
- (void)addLocation:(Location*)locationDatum;
- (void)addDistance:(Distance*)distance;

- (void)end;

- (void)markSynced;

@property (readonly) BOOL synced;
@property (readonly) NSString * guid;
@property (readonly) BOOL canSync;

@property (readonly) NSArray<HeartRate*>* heartData;
@property (readonly) NSArray<Calories*>* calories;
@property (readonly) NSArray<Location*>* locations;
@property (readonly) NSArray<Distance*>* distances;

@end
