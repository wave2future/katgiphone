//
//  WebViewController.m
//  KATG.com
//
//  Copyright 2008 Doug Russell
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "WebViewController.h"


@implementation WebViewController

//@synthesize navigationController;
@synthesize webView;    // Set up webview for TweetViewController to pass too
@synthesize toolBar;
@synthesize urlAddress; // Variable for TweetViewController to pass URL address

- (void)loadView {
	[super loadView];
	
	self.navigationItem.title = urlAddress;
	
	CGRect rect = CGRectMake(0, 0, 320, 360);
	view = [[UIView alloc] initWithFrame:rect];
	self.view = view;
	[view setBackgroundColor:[UIColor blackColor]];
	
	rect.size.height -= 30;
	webView = [[UIWebView alloc] initWithFrame:rect];
	[webView setDelegate:self];
	webView.scalesPageToFit = YES;
	webView.userInteractionEnabled = YES;
	webView.multipleTouchEnabled = YES;
	[view addSubview:webView];
		
	rect.size.height -= 290;
	rect.origin.y += 330;
	toolBar = [[UIToolbar alloc] initWithFrame:rect];
	UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:webView action:@selector(stopLoading)];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:webView action:@selector(reload)];
	UIBarButtonItem *goBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:webView action:@selector(goBack)];
	UIBarButtonItem *goForward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:webView action:@selector(goForward)];
	[toolBar setItems:[NSArray arrayWithObjects:stop, refresh, goBack, goForward, nil]];
	[toolBar setTintColor:[UIColor colorWithRed:(CGFloat)0.776 green:(CGFloat).875 blue:(CGFloat)0.776 alpha:(CGFloat)1.0]];
	[view addSubview:toolBar];
	
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:urlAddress];
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	//Load the request in the UIWebView.
	[webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[view release];
	[toolBar release];
	[webView release];
	[urlAddress release];
    [super dealloc];
}


@end
