//
//  RecordSessionViewController.m
//  norway
//
//  Created by Thomas Denney on 02/03/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "RecordSessionViewController.h"
#import "AppDelegate.h"
#import "ConnectionManager.h"
#import "RecordingSession.h"
#import "BandDataStream.h"

@interface RecordSessionViewController ()

@property ConnectionManager * connectionManager;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property RecordingSession * session;
@property BandDataStream * stream;

@end

@implementation RecordSessionViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.connectionManager = [(AppDelegate*)[[UIApplication sharedApplication] delegate] connectionManager];
    
    [self checkForBand];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bandConnected:) name:ConnectionManagerConnectedBand object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bandDisconnected:) name:ConnectionManagerDisconnectedBand object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkForBand {
    if (self.connectionManager.connectedBand) {
        self.startButton.enabled = YES;
        self.stopButton.enabled = NO;
        self.statusLabel.text = [NSString stringWithFormat:@"Ready to record from %@", self.connectionManager.connectedBand.name];
    }
    else {
        self.startButton.enabled = NO;
        self.stopButton.enabled = NO;
        self.statusLabel.text = @"No band connected, please go to Connections";
    }
}

- (IBAction)startTapped:(id)sender {
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    
    AppDelegate * ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.session = [[RecordingSession alloc] init];
    [self.session save:ad.database.serialDB];
    self.stream = [[BandDataStream alloc] initWithBand:self.connectionManager.connectedBand database:ad.database.serialDB recordingSession:self.session];
    
    [self.stream begin];
    
    self.statusLabel.text = [NSString stringWithFormat:@"Started recording data at %@", self.session.startDate];
}

- (IBAction)stopTapped:(id)sender {
    [self.stream end];
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    
    self.statusLabel.text = [NSString stringWithFormat:@"Stopped recording data at %@", self.session.endDate];
}

- (void)bandConnected:(NSNotification*)note {
    // TODO: Check for active recording session
    [self checkForBand];
}

- (void)bandDisconnected:(NSNotification*)note {
    // TODO: As above
    [self checkForBand];
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
