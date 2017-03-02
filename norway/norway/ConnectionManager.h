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

extern NSString * const ConnectionManagerConnectedBand;
extern NSString * const ConnectionManagerDisconnectedBand;

@interface ConnectionManager : NSObject<MSBClientManagerDelegate>

- (MSBClient*)connectedBand;

- (NSArray<MSBClient*>*)allBands;

@property (nonatomic) NSString * defaultConnectionString;
@property (readonly) NSSet<MSBClient*>* waitingClients;

- (void)connectDefault;
- (void)connect:(MSBClient*)client;

@end
