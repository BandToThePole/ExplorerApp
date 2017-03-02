//
//  ViewController.m
//  norway
//
//  Created by Thomas Denney on 24/02/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "ViewController.h"
#import "BandDataStream.h"
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>

@interface ViewController ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property RecordingSession * session;
@property BandDataStream * stream;
@property MSBClient * client;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
  /*  self.connectionManager = appDelegate.connectionManager;
    self.connectionManager.delegate = self;
    [self.connectionManager connectAny];*/
    self.statusLabel.text = @"Connecting";
    self.startButton.enabled = self.stopButton.enabled = NO;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connectionManager:(ConnectionManager *)manager connectedBand:(MSBClient *)band {
    self.statusLabel.text = [NSString stringWithFormat:@"Connected to %@", band.name];
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.client = band;
}

- (IBAction)startAction:(id)sender {
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    
    AppDelegate * ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.session = [[RecordingSession alloc] init];
    [self.session save:ad.database.serialDB];
    self.stream = [[BandDataStream alloc] initWithBand:self.client database:ad.database.serialDB recordingSession:self.session];
    
    [self.stream begin];
}

- (IBAction)stopAction:(id)sender {
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    
    [self.stream end];
}

- (IBAction)sendAction:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
        vc.mailComposeDelegate = self;
        NSLog(@"Created delegate");
        AppDelegate * ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSArray * array = [ad.database allSessions];
        NSLog(@"Array %@", array);
        NSDictionary * dict = [ad.database serializeSessions:array];
        NSLog(@"Dict: %@", dict);
        // TODO: Don't actually pretty print...
        NSData * databaseData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"JSON: %@", [[NSString alloc] initWithData:databaseData encoding:NSUTF8StringEncoding]);
        [vc addAttachmentData:databaseData mimeType:@"application/json" fileName:@"alldata.json"];
        [self presentViewController:vc animated:YES completion:nil];
    }

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
