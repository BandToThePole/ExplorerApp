//
//  ConnectionManager.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [MSBClientManager sharedManager].delegate = self;
    }
    return self;
}

- (void)connectAny {
    MSBClient * client = [[MSBClientManager sharedManager].attachedClients firstObject];
    if (client) {
        [[MSBClientManager sharedManager] connectClient:client];
        NSLog(@"Attempt to connect to %@", client.name);
    }
}

- (void)clientManager:(MSBClientManager *)clientManager clientDidConnect:(MSBClient *)client {
    [self.delegate connectionManager:self connectedBand:client];
}

- (void)clientManager:(MSBClientManager *)clientManager clientDidDisconnect:(MSBClient *)client {
    NSLog(@"%@ disconnected", client);
}

- (void)clientManager:(MSBClientManager *)clientManager client:(MSBClient *)client didFailToConnectWithError:(NSError *)error {
    NSLog(@"%@ failed to connect with error %@", client, error.localizedDescription);
}

@end
