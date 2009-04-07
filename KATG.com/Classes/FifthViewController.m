//
//  FifthViewController.m
//  KATG.com
//
//  Created by Doug Russell on 4/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FifthViewController.h"


@implementation FifthViewController

@synthesize webView;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
//	NSString *urlAddress = @"http://www.keithandthegirl.com/forums/f22";
	NSString *urlAddress = @"http://reader.mac.com/mobile/v1/http%3A%2F%2Fwww.keithandthegirl.com%2Frss%2F";

	
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:urlAddress];
	
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	//Load the request in the UIWebView.
	[webView loadRequest:requestObj];
}

- (IBAction) goBack:(id)sender
{
	[webView goBack];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[webView release];
    [super dealloc];
}


@end
