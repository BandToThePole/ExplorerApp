//
//  NSArray+NWY.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NWY)

- (NSArray*)nwy_map:(id(^)(id))f;

@end
