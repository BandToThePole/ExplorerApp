//
//  Calories.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "DatabaseObject.h"

@class RecordingSession;

@interface Calories : DatabaseObject

- (instancetype)initWithTime:(NSDate*)time totalCalories:(NSInteger)kcalCount;

@property (weak) RecordingSession * session;
@property NSDate * time;
@property NSInteger kcalCount;

@end
