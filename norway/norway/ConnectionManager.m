//
//  ConnectionManager.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "ConnectionManager.h"

NSString * const ConnectionManagerConnectedBand = @"connectedBand";
NSString * const ConnectionManagerDisconnectedBand = @"disconnectedBand";

@interface ConnectionManager ()

@property NSMutableSet<MSBClient*>* waitingClientsMutable;
@property NSMutableSet<MSBClient*>* connectedBands;

@end

@implementation ConnectionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [MSBClientManager sharedManager].delegate = self;
        self.waitingClientsMutable = [NSMutableSet new];
        self.connectedBands = [NSMutableSet new];
    }
    return self;
}

- (void)clientManager:(MSBClientManager *)clientManager clientDidConnect:(MSBClient *)client {
    if (client) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ConnectionManagerConnectedBand object:client];
        [self.waitingClientsMutable removeObject:client];
        [self.connectedBands addObject:client];
    }
}

- (void)clientManager:(MSBClientManager *)clientManager clientDidDisconnect:(MSBClient *)client {
    if (client) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ConnectionManagerDisconnectedBand object:client];
        [self.waitingClientsMutable removeObject:client];
        [self.connectedBands addObject:client];
    }
}

- (void)clientManager:(MSBClientManager *)clientManager client:(MSBClient *)client didFailToConnectWithError:(NSError *)error {
    if (client) {
        [self.waitingClientsMutable removeObject:client];
        [self.connectedBands removeObject:client];
    }
}

- (NSArray<MSBClient*>*)allBands {
    return [[MSBClientManager sharedManager] attachedClients];
}

- (NSString*)defaultConnectionString {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"connection"];
}

- (void)setDefaultConnectionString:(NSString *)defaultConnectionString {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:defaultConnectionString forKey:@"connection"];
    [defaults synchronize];
}

- (void)connectDefault {
    if (self.defaultConnectionString) {
        MSBClient * client = [[MSBClientManager sharedManager] clientWithConnectionIdentifier:[[NSUUID alloc] initWithUUIDString:self.defaultConnectionString]];
        [self connect:client];
    }
}

- (void)connect:(MSBClient *)client {
    if (client) {
        [self.waitingClientsMutable addObject:client];
        [[MSBClientManager sharedManager] connectClient:client];
        self.defaultConnectionString = client.connectionIdentifier.UUIDString;
    }
}

- (NSSet<MSBClient*>*)waitingClients {
    return self.waitingClientsMutable;
}

- (MSBClient*)connectedBand {
    //TODO: Return from connected set?
    for (MSBClient * band in self.allBands) {
        if (band.isDeviceConnected) {
            return band;
        }
    }
    return nil;
}

@end
