//
//  ConnectionManagerViewControllerTableViewController.m
//  norway
//
//  Created by Thomas Denney on 02/03/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "ConnectionManagerViewControllerTableViewController.h"
#import "ConnectionManager.h"
#import "AppDelegate.h"

@interface ConnectionManagerViewControllerTableViewController ()

@property ConnectionManager * connectionManager;

@end

@implementation ConnectionManagerViewControllerTableViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    self.connectionManager = [(AppDelegate*)[[UIApplication sharedApplication] delegate] connectionManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedBand:) name:ConnectionManagerConnectedBand object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectedBand:) name:ConnectionManagerDisconnectedBand object:nil];
     
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.connectionManager.allBands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSBClient * client = self.connectionManager.allBands[indexPath.row];
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bandNameCell" forIndexPath:indexPath];
    
    if ([self.connectionManager.waitingClients containsObject:client]) {
        UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = indicator;
        [indicator startAnimating];
    }
    else {
        cell.accessoryView = nil;
        cell.accessoryType = client.isDeviceConnected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    
    cell.textLabel.text = client.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MSBClient * client = self.connectionManager.allBands[indexPath.row];
    [self.connectionManager connect:client];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)refresh:(id)sender {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData]; // Should get the most recent list of bands
}

- (void)connectedBand:(NSNotification*)note {
    [self.tableView reloadData];
    // TODO: Just reload correct row
}

- (void)disconnectedBand:(NSNotification*)note{
    [self.tableView reloadData];
}

@end
