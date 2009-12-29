//
//  EventDetailViewController.m
//  KATG.com
//
//  Copyright 2009 Doug Russell
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

#import "EventDetailViewController.h"
#import "ModalWebViewController.h"

@implementation EventDetailViewController

@synthesize webView;
@synthesize titleLabel;
@synthesize dayLabel;
@synthesize dateLabel;
@synthesize timeLabel;
@synthesize event;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	NSString *htmlHeader = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta name=\"viewport\" content=\"width=device-width; initial-scale=0.8; maximum-scale=2.0; user-scalable=1;\" /><meta name=\"HandheldFriendly\" content=\"True\" /><style>* {font-family:helvetica;}</style></head><body><h3>";
	NSString *htmlFooter = @"</h3></body></html>";
	NSString *htmlString = [NSString stringWithFormat:@"%@%@%@",
							htmlHeader,
							[[event objectForKey:@"Details"] stringByReplacingOccurrencesOfString:@"Here's how to listen: <a href=\"../Live/HowToListen.aspx\" target=\"_blank\"><font face=\"Arial\" size=\"2\">http://www.keithandthegirl.com/Live/HowToListen.aspx</font></a>" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, [[event objectForKey:@"Details"] length])],
							htmlFooter];
	webView.backgroundColor = [UIColor clearColor];
	[webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://keithandthegirl.com/"]];
	
	[titleLabel setText:[event objectForKey:@"Title"]];
	[dayLabel setText:[event objectForKey:@"Day"]];
	[dateLabel setText:[event objectForKey:@"Date"]];
	[timeLabel setText:[event objectForKey:@"Time"]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{
	if (navigationType == UIWebViewNavigationTypeOther) {
		return YES;
	}
	
	ModalWebViewController *viewController = 
	[[ModalWebViewController alloc] initWithNibName:@"ModalWebView" bundle:nil];
	[viewController setUrlRequest:request];
	[viewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
	
	return NO;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)dealloc 
{
	[webView release];
	[event release];
    [super dealloc];
}

@end
