//
//  MapViewController.m
//  norway
//
//  Created by Thomas Denney on 03/03/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLocations:self.locations];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLocations:(NSArray<Location *> *)locations {
    if (self.locations) [self.mapView removeAnnotations:_locations];
    _locations = locations;
    [self.mapView addAnnotations:self.locations];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
