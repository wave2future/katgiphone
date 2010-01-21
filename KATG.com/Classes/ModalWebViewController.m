//
//  ModalWebViewController.m
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

#import "ModalWebViewController.h"

@implementation ModalWebViewController

@synthesize webView;
@synthesize toolbar;
@synthesize doneButton;
@synthesize activityIndicator;
@synthesize urlRequest;
@synthesize disableDone;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	if (disableDone)
	{
		[doneButton setEnabled:NO];
	}
	[webView loadRequest:urlRequest];
}

- (IBAction)dismissModalViewController:(id)sender 
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[activityIndicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityIndicator stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityIndicator startAnimating];
}

- (IBAction)openInSafari:(id)sender
{
	UIActionSheet *actionSheet = 
	[[UIActionSheet alloc] initWithTitle:@"" 
								delegate:self 
					   cancelButtonTitle:@"Cancel" 
				  destructiveButtonTitle:nil 
					   otherButtonTitles:@"Open in Safari", nil];
	[actionSheet showFromToolbar:toolbar];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		NSURL *url = [[webView request] URL];
		if ([[UIApplication sharedApplication] canOpenURL:url]) {
			[[UIApplication sharedApplication] openURL:url];
		}
	}
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc 
{
	[webView release];
	[urlRequest release];
	[toolbar release];
	[doneButton release];
	[activityIndicator release];
    [super dealloc];
}


@end
