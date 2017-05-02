//
//  HelpViewController.m
//  norway
//
//  Created by Thomas Denney on 02/03/2017.
//  Copyright © 2017 thomasdenney. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.hidden = YES;
    self.webView.delegate = self;
    NSString * htmlFilePath = [[NSBundle mainBundle] pathForResource:@"doc" ofType:@"html"];
    NSURL * htmlFileURL = [NSURL fileURLWithPath:htmlFilePath];
    NSURLRequest * htmlFileURLRequest = [NSURLRequest requestWithURL:htmlFileURL];
    [self.webView loadRequest:htmlFileURLRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    webView.hidden = NO;
}

@end
