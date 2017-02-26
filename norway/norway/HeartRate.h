//
//  HeartRate.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializedDatabase.h"

@class RecordingSession;

@interface HeartRate : NSObject

- (instancetype)initWithTime:(NSDate*)time bpm:(NSUInteger)bpm;

@property NSInteger databaseID;
@property NSInteger heartRate;
@property (weak) RecordingSession * session;
@property NSDate * time;
@property NSUInteger bpm;

- (BOOL)save:(SerializedDatabase*)serialDB;

@end
