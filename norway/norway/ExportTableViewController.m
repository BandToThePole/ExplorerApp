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

#import "SyncAccount.h"

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
        NSDictionary * dict = [NorwayDatabase serializeSessions:array];
        NSData * databaseData = [NorwayDatabase encodeDictionary:dict zlibCompress:YES];
        //NSLog(@"JSON: %@", [[NSString alloc]  initWithData:databaseData encoding:NSUTF8StringEncoding]);
        [vc addAttachmentData:databaseData mimeType:@"application/json" fileName:@"alldata.json.zlib"];
        [vc setMessageBody:[NSString stringWithFormat:@"Total size is %zu bytes", databaseData.length] isHTML:NO];
        [self presentViewController:vc animated:YES completion:nil];
    }
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([SyncAccount isSignedIn]) {
        return 1;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([SyncAccount isSignedIn]) {
            return 2;
        }
        else {
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    if (indexPath.section == 0) {
        if ([SyncAccount isSignedIn]) {
            if (indexPath.row == 0) {
                cell.textLabel.text = [SyncAccount username];
            }
            else if (indexPath.row == 1) {
                cell.textLabel.textColor = [UIColor redColor];
                cell.textLabel.text = @"Sign out";
            }
        }
        else {
            cell.textLabel.text = @"Sign in";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (![SyncAccount isSignedIn] && indexPath.row == 0) {
            // Sign in action
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Login" message:@"Enter username and password" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Username";
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Password";
                textField.secureTextEntry = YES;
            }];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                // No op
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Sign in" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [SyncAccount setUsername:[alert.textFields[0] text] passwword:[alert.textFields[1] text]];
                [self.tableView reloadData];
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if (indexPath.row == 1) {
            [SyncAccount signOut];
            [self.tableView reloadData];
        }
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Account";
}

@end
