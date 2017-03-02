//
//  ExportTableViewController.m
//  norway
//
//  Created by Thomas Denney on 02/03/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "ExportTableViewController.h"
#import "AppDelegate.h"

#import <MessageUI/MessageUI.h>

@interface ExportTableViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation ExportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)emailDumpTapped:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
        vc.mailComposeDelegate = self;
        
        AppDelegate * ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSArray * array = [ad.database allSessions];
        NSDictionary * dict = [ad.database serializeSessions:array];
        
        // TODO: Don't actually pretty print...
        NSData * databaseData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"JSON: %@", [[NSString alloc]  initWithData:databaseData encoding:NSUTF8StringEncoding]);
        [vc addAttachmentData:databaseData mimeType:@"application/json" fileName:@"alldata.json"];
        [self presentViewController:vc animated:YES completion:nil];
    }
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}



@end
