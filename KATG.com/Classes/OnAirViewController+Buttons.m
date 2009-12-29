//
//  OnAirViewController+Buttons.m
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

#import "OnAirViewController+Buttons.h"

@implementation OnAirViewController (Buttons)

- (IBAction)callButtonPressed:(id)sender 
{
	NSURL *url= [NSURL URLWithString:@"tel:+16465028682"];
	NSString *osVersion = [[UIDevice currentDevice] systemVersion];
	if ([osVersion doubleValue] >= 3.1) {
		// On 3.1 and up use webview to dial
		UIWebView *webview = [[UIWebView alloc] initWithFrame:[callButton frame]];
		webview.alpha = 0.0;
		[webview loadRequest:[NSURLRequest requestWithURL:url]];
		[self.view insertSubview:webview belowSubview:callButton];
		[webview release];
	}
	else {
		// On 3.0 dial as usual
		[[UIApplication sharedApplication] openURL: url];          
	}
}

- (IBAction)infoButtonPressed:(id)sender 
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Keith and The Girl"
						  message:@"This is for anyone into hearing and learning about the Keith and The Girl show on the go. Listen live, check upcoming live events, watch KATGtv video episodes, see show notes and pictures, and much more. Take a look around, and enjoy." 
						  delegate:nil
						  cancelButtonTitle:@"Continue" 
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
