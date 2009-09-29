//
//  WebViewController.m
//  KATG.com
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
