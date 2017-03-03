//
//  MapViewController.h
//  norway
//
//  Created by Thomas Denney on 03/03/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Location.h"

@interface MapViewController : UIViewController

@property (nonatomic) NSArray<Location*> * locations;

@end
