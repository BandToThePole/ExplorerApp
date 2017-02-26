//
//  ViewController.h
//  norway
//
//  Created by Thomas Denney on 24/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@interface ViewController : UIViewController<ConnectionManagerDelegate>

@property ConnectionManager * connectionManager;

@end

