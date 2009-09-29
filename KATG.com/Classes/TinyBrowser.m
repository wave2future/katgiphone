//
//  TinyBrowser.m
//  KATG.com
//
//  Created by Doug Russell on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TinyBrowser.h"

@implementation TinyBrowser

@synthesize delegate;
@synthesize webView;
@synthesize toolBar;
@synthesize urlAddress;

- (void)loadView {
	[super loadView];
	
	self.navigationItem.title = urlAddress;
	
	CGRect rect = CGRectMake(0, 0, 320, 460);
	view = [[UIView alloc] initWithFrame:rect];
	self.view = view;
	[view setBackgroundColor:[UIColor blackColor]];
	
	rect.size.height = 410;
	webView = [[UIWebView alloc] initWithFrame:rect];
	[webView setDelegate:self];
	webView.scalesPageToFit = YES;
	webView.userInteractionEnabled = YES;
	webView.multipleTouchEnabled = YES;
	[view addSubview:webView];
	
	rect.size.height = 50;
	rect.origin.y = 410;
	toolBar = [[UIToolbar alloc] initWithFrame:rect];
	UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:webView action:@selector(stopLoading)];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:webView action:@selector(reload)];
	UIBarButtonItem *goBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:webView action:@selector(goBack)];
	UIBarButtonItem *goForward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:webView action:@selector(goForward)];
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	[toolBar setItems:[NSArray arrayWithObjects:stop, refresh, goBack, goForward, space, done, nil]];
	[toolBar setTintColor:[UIColor colorWithRed:(CGFloat)0.776 green:(CGFloat).875 blue:(CGFloat)0.776 alpha:(CGFloat)1.0]];
	[view addSubview:toolBar];
	
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:urlAddress];
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	//Load the request in the UIWebView.
	[webView loadRequest:requestObj];
}

- (void)done {
	[self.delegate tinyBrowserDidFinish:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[delegate release];
	[view release];
	[toolBar release];
	[webView release];
	[urlAddress release];
    [super dealloc];
}


@end