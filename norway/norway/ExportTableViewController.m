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

@property NorwayDatabase * database;

@end

@implementation ExportTableViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate * ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.database = ad.database;
    self.database.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:RecordingSessionChanged object:nil];
    
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
        [vc setMessageBody:[NSString stringWithFormat:@"Total size is %zu bytes", (unsigned long)databaseData.length] isHTML:NO];
        [self presentViewController:vc animated:YES completion:nil];
    }
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (void)reload:(NSNotification*)note {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([SyncAccount isSignedIn]) {
        return 2;
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
    else if (section == 1) {
        return 2;
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
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Sync new";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"Sync all";
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
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                [SyncAccount setUsername:[alert.textFields[0] text] password:[alert.textFields[1] text] callback:^(BOOL success) {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    if (success) {
                        [self.tableView reloadData];
                    }
                    else {
                        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Sign in failed" message:@"Sorry, it was not possible to authenticate you." preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }];
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if (indexPath.row == 1) {
            [SyncAccount signOut];
            [self.tableView reloadData];
        }
    }
    else if (indexPath.section == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        if (indexPath.row == 0) {
            [self.database startSyncWithAllData:NO];
        }
        else if (indexPath.row == 1) {
            [self.database startSyncWithAllData:YES];
        }
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Account";
    }
    else if (section == 1) {
        return @"Sync";
    }
    else {
        return nil;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        NSInteger numberCanSync = [self.database numberCanSync];
        NSMutableString * footer = [NSMutableString new];
        if (numberCanSync == 0) {
            [footer appendFormat:@"There are no sessions that need syncing. "];
        }
        else if (numberCanSync == 1) {
            [footer appendFormat:@"There is one session that can be synced. "];
        }
        else {
            [footer appendFormat:@"There are %ld sessions that need syncing. ", (long)numberCanSync];
        }
        
        NSDate * lastSync = [NorwayDatabase lastSync];
        if (lastSync) {
            NSDateFormatter * formatter = [NSDateFormatter new];
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterLongStyle;
            
            NSNumberFormatter * numberFormatter = [NSNumberFormatter new];
            numberFormatter.locale = [NSLocale currentLocale];
            numberFormatter.usesGroupingSeparator = YES;
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSInteger byteCount = [NorwayDatabase lastSyncByteCount];
            
            [footer appendFormat:@"The last sync was at %@ and it contained %@ byte%@.", [formatter stringFromDate:lastSync], [numberFormatter stringFromNumber:@(byteCount)], byteCount == 1 ? @"" : @"s"];
        }
        else {
            [footer appendFormat:@"No data has been synced yet."];
        }
        return footer;
    }
    return nil;
}

#pragma mark - Sync delegate

- (void)syncFailedDueToLoginError {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView reloadData];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Login error" message:@"Couldn't submit data because of incorrect login details. Please sign out and enter them again" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)syncFailedDueToNetworkError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView reloadData];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Network error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)syncCompletedSuccessfully {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView reloadData];
}

@end
