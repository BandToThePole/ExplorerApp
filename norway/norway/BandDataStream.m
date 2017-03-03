//
//  BandDataStream.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "BandDataStream.h"

@interface BandDataStream ()<CLLocationManagerDelegate>

@property MSBClient * client;
@property SerializedDatabase * database;
@property RecordingSession * session;
@property NSOperationQueue * streamQueue;
@property CLLocationManager * locationManager;

@end

@implementation BandDataStream

- (instancetype)initWithBand:(MSBClient *)band database:(SerializedDatabase *)db recordingSession:(RecordingSession *)session {
    self = [super init];
    if (self) {
        self.client = band;
        self.database = db;
        self.session = session;
        self.streamQueue = [NSOperationQueue new];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        // TODO: Stream?
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // TODO: Maybe ask for permission some other time?
        [self.locationManager requestAlwaysAuthorization];
    }
    return self;
}

- (void)_streamHeartRate {
    [self.client.sensorManager startHeartRateUpdatesToQueue:self.streamQueue errorRef:nil withHandler:^(MSBSensorHeartRateData *heartRateData, NSError *error) {
        HeartRate * hr = [[HeartRate alloc] initWithTime:[NSDate date] bpm:heartRateData.heartRate];
        [self.session addHeartRate:hr];
        [hr save:self.database];
    }];
}

- (void)_streamCalories {
    [self.client.sensorManager startCaloriesUpdatesToQueue:self.streamQueue errorRef:nil withHandler:^(MSBSensorCaloriesData *caloriesData, NSError *error) {
        Calories * kcal = [[Calories alloc] initWithTime:[NSDate date] totalCalories:caloriesData.calories];
        [self.session addCalories:kcal];
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
        [distance save:self.database];
    }];
}

- (void)_streamLocation {
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    for (CLLocation * location in locations) {
        Location * loc = [[Location alloc] initWithTime:location.timestamp lat:location.coordinate.latitude long:location.coordinate.longitude];
        [self.session addLocation:loc];
        [loc save:self.database];
    }
}

- (void)begin {
    [self.session start];
    [self.session save:self.database];
    
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
    [self _streamLocation];
}

- (void)end {
    [self.client.sensorManager stopHeartRateUpdatesErrorRef:nil];
    [self.client.sensorManager stopCaloriesUpdatesErrorRef:nil];
    [self.client.sensorManager stopDistanceUpdatesErrorRef:nil];
    [self.locationManager stopUpdatingLocation];
    
    [self.session end];
    [self.session save:self.database];
}

@end
