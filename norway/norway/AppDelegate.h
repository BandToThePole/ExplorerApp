//
//  AppDelegate.h
//  norway
//
//  Created by Thomas Denney on 24/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NorwayDatabase.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property NorwayDatabase * database;

@property (strong, nonatomic) UIWindow *window;

@end

