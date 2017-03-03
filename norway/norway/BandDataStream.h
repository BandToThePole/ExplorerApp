//
//  BandDataStream.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>
#import <CoreLocation/CoreLocation.h>
#import "RecordingSession.h"

@interface BandDataStream : NSObject

- (instancetype)initWithBand:(MSBClient*)band database:(SerializedDatabase*)db recordingSession:(RecordingSession*)session;

@property (readonly) MSBClient * client;
@property (readonly) SerializedDatabase * database;
@property (readonly) RecordingSession * session;

- (void)begin;
- (void)end;

@end
