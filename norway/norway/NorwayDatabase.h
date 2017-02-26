//
//  NorwayDatabase.h
//  norway
//
//  Created by Thomas Denney on 26/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerializedDatabase.h"
#import "Query.h"

@interface NorwayDatabase : NSObject

// Creates tables on creation
- (instancetype)initWithSerialDatabase:(SerializedDatabase*)serialDB;

@property (readonly) SerializedDatabase * serialDB;

@end
