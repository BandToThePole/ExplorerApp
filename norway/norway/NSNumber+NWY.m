//
//  NSNumber+NWY.m
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "NSNumber+NWY.h"

@implementation NSNumber (NWY)

- (BOOL)nwy_isFloatingPoint {
    if ([self isKindOfClass:[NSDecimalNumber class]]) {
        return YES;
    }
    
    CFNumberType nType = CFNumberGetType((CFNumberRef)self);
    
    return nType == kCFNumberFloat32Type || nType == kCFNumberFloat64Type || nType == kCFNumberFloatType || nType == kCFNumberDoubleType || nType == kCFNumberCGFloatType;
}

- (BOOL)nwy_isInteger {
    return ![self nwy_isFloatingPoint];
}

@end
