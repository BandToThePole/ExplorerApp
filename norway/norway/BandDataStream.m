//
//  BandDataStream.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "BandDataStream.h"

@interface BandDataStream ()

@property MSBClient * client;
@property SerializedDatabase * database;
@property RecordingSession * session;
@property NSOperationQueue * streamQueue;

@end

@implementation BandDataStream

- (instancetype)initWithBand:(MSBClient *)band database:(SerializedDatabase *)db recordingSession:(RecordingSession *)session {
    self = [super init];
    if (self) {
        self.client = band;
        self.database = db;
        self.session = session;
        self.streamQueue = [NSOperationQueue new];
    }
    return self;
}

- (void)_streamHeartRate {
    [self.client.sensorManager startHeartRateUpdatesToQueue:self.streamQueue errorRef:nil withHandler:^(MSBSensorHeartRateData *heartRateData, NSError *error) {
        HeartRate * hr = [[HeartRate alloc] initWithTime:[NSDate date] bpm:heartRateData.heartRate];
        [self.session addHeartRate:hr];
        NSLog(@"%lu BPM", hr.bpm);
        [hr save:self.database];
    }];
}

- (void)_streamCalories {
    [self.client.sensorManager startCaloriesUpdatesToQueue:self.streamQueue errorRef:nil withHandler:^(MSBSensorCaloriesData *caloriesData, NSError *error) {
        Calories * kcal = [[Calories alloc] initWithTime:[NSDate date] totalCalories:caloriesData.calories];
        [self.session addCalories:kcal];
        NSLog(@"%lu kcal", kcal.kcalCount);
        [kcal save:self.database];
    }];
}

- (void)_streamDistance {
    [self.client.sensorManager startDistanceUpdatesToQueue:self.streamQueue errorRef:nil withHandler:^(MSBSensorDistanceData *distanceData, NSError *error) {
        
        NSString * motion = @"";
        switch (distanceData.motionType) {
            case MSBSensorMotionTypeUnknown:
                motion = @"";
                break;
            case MSBSensorMotionTypeIdle:
                motion = @"idle";
                break;
            case MSBSensorMotionTypeWalking:
                motion = @"walk";
                break;
            case MSBSensorMotionTypeJogging:
                motion = @"jogging";
                break;
            case MSBSensorMotionTypeRunning:
                motion = @"running";
                break;
        }
        
        Distance * distance = [[Distance alloc] initWithTime:[NSDate date] distance:distanceData.totalDistance speed:distanceData.speed pace:distanceData.pace motionType:motion];
        [self.session addDistance:distance];
        NSLog(@"%lu km?", distance.totalDistance);
        [distance save:self.database];
    }];
}

- (void)begin {
    [self.session start];
    [self.session save:self.database];
    NSLog(@"Saved self with %d", (int)self.session.databaseID);
    
    if ([self.client.sensorManager heartRateUserConsent] != MSBUserConsentGranted) {
        [self.client.sensorManager requestHRUserConsentWithCompletion:^(BOOL userConsent, NSError *error) {
            if (userConsent) {
                [self _streamHeartRate];
            }
        }];
    }
    else {
        [self _streamHeartRate];
    }
    
    [self _streamCalories];
    [self _streamDistance];
}

- (void)end {
    [self.client.sensorManager stopHeartRateUpdatesErrorRef:nil];
    [self.client.sensorManager stopCaloriesUpdatesErrorRef:nil];
    [self.client.sensorManager stopDistanceUpdatesErrorRef:nil];
    
    [self.session end];
    [self.session save:self.database];
}

@end
