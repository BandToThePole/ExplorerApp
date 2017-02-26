//
//  ConnectionManager.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>

@class ConnectionManager;

@protocol ConnectionManagerDelegate <NSObject>

- (void)connectionManager:(ConnectionManager*)manager connectedBand:(MSBClient*)band;

@end

@interface ConnectionManager : NSObject<MSBClientManagerDelegate>

- (void)connectAny;

@property id<ConnectionManagerDelegate> delegate;

@end
