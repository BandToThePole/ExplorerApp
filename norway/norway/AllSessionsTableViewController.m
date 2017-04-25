//
//  AllSessionsTableViewController.m
//  norway
//
//  Created by Thomas Denney on 02/03/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "AllSessionsTableViewController.h"
#import "AppDelegate.h"
#import "NorwayDatabase.h"
#import "RecordingSession.h"
#import "StringTableViewController.h"
#import "NSArray+NWY.h"
#import "MapViewController.h"

@interface AllSessionsTableViewController ()

@property NorwayDatabase * database;
@property NSArray<RecordingSession*>* sessions;
@property NSDateFormatter * formatter;

@end

@implementation AllSessionsTableViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate * ad = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.database = ad.database;
    
    [self reloadData];
    
    self.formatter = [NSDateFormatter new];
    self.formatter.dateStyle = NSDateFormatterMediumStyle;
    self.formatter.timeStyle = NSDateFormatterMediumStyle;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRecorded:) name:RecordingSessionChanged object:nil];
    
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

- (void)sessionRecorded:(NSNotification*)note {
    [self reloadData];
}

- (void)reloadData {
    self.sessions = [self.database.allSessions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]]];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sessions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dateCell" forIndexPath:indexPath];
    RecordingSession * session = self.sessions[indexPath.row];
    cell.textLabel.text = [self.formatter stringFromDate:session.startDate];
    if (session.synced) {
        cell.imageView.image = [UIImage imageNamed:@"cloud_done"];
    }
    else if (session.canSync) {
        cell.imageView.image = [UIImage imageNamed:@"cloud_todo"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"cloud_cant"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIAlertController * dataTypeSelect = [UIAlertController alertControllerWithTitle:@"Select data" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    RecordingSession * session = self.sessions[indexPath.row];
    
    [dataTypeSelect addAction:[UIAlertAction actionWithTitle:@"Total distance" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showDataForSession:session withKey:@"distances" title:action.title];
    }]];
    
    [dataTypeSelect addAction:[UIAlertAction actionWithTitle:@"Total calories" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showDataForSession:session withKey:@"calories" title:action.title];
    }]];
    
    [dataTypeSelect addAction:[UIAlertAction actionWithTitle:@"Heart rate" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showDataForSession:session withKey:@"heartData" title:action.title];
    }]];
    
    [dataTypeSelect addAction:[UIAlertAction actionWithTitle:@"Location" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showDataForSession:session withKey:@"locations" title:action.title];
    }]];
    
    [dataTypeSelect addAction:[UIAlertAction actionWithTitle:@"Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MapViewController * mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"mapVC"];
        mvc.locations = session.locations;
        [self.navigationController pushViewController:mvc animated:YES];
    }]];
    
    [dataTypeSelect addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:dataTypeSelect animated:YES completion:nil];
}

- (void)showDataForSession:(RecordingSession*)session withKey:(NSString*)key title:(NSString*)title {
    StringTableViewController * stvc = [self.storyboard instantiateViewControllerWithIdentifier:@"sessionDataVC"];
    stvc.title = title;
    NSArray * objs = [[session valueForKey:key] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]];
    NSDateFormatter * df = [NSDateFormatter new];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.timeStyle = NSDateFormatterLongStyle;
    stvc.strings = [objs nwy_map:^id(id x) { return [x stringValue]; }];
    stvc.subtitles = [objs nwy_map:^id(id x) { return [df stringFromDate:[x time]]; }];
    [self.navigationController pushViewController:stvc animated:YES];
}

@end
