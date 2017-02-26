//
//  NSArray+NWY.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "NSArray+NWY.h"

@implementation NSArray (NWY)

- (NSArray*)nwy_map:(id (^)(id))f {
    NSMutableArray * m = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self) {
        [m addObject:f(obj)];
    }
    return m;
}

@end
