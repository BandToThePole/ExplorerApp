//
//  Location.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "DatabaseObject.h"

#import <MapKit/MapKit.h>

@class RecordingSession;

@interface Location : DatabaseObject<MKAnnotation>

// TODO: Use iOS locations APIs instead

- (instancetype)initWithTime:(NSDate*)date lat:(double)latitude long:(double)longitude;

@property (weak) RecordingSession * session;
@property NSDate * time;
@property double latitude;
@property double longitude;

@end
