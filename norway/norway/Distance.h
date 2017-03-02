//
//  Distances.h
//  norway
//
//  Created by Thomas Denney on 02/03/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "DatabaseObject.h"

@class RecordingSession;

@interface Distance : DatabaseObject

- (instancetype)initWithTime:(NSDate *)date distance:(NSUInteger)distance speed:(double)speed pace:(double)pace motionType:(NSString*)motionType;

@property (weak) RecordingSession * session;
@property NSDate * time;

@property NSUInteger totalDistance;
@property double speed;
@property double pace;
@property NSString * motionType;

@end
