//
//  HeartRate.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DatabaseObject.h"

@class RecordingSession;

@interface HeartRate : DatabaseObject

- (instancetype)initWithTime:(NSDate*)time bpm:(NSUInteger)bpm;

@property NSInteger heartRate;
@property (weak) RecordingSession * session;
@property NSDate * time;
@property NSUInteger bpm;

@end
