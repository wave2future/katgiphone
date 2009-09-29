//
//  linkList.m
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

#import "linkList.h"
#import "TinyBrowser.h"
#import "grabRSSFeed.h"

BOOL inApp1, inApp2, inApp3, inApp4;

@implementation linkList

@synthesize button1, button2, button3, button4, infoButton;

- (void)viewDidLoad {
	list = [[NSMutableArray alloc] initWithCapacity:4];
	feedEntries = [[NSMutableArray alloc] initWithCapacity:4];
	[self pollFeed];
	[self setButtonImages];
}

- (void) pollFeed {
	NSString *feedAddress = @"http://keithandthegirl.com/API/App/Links.xml";
	// Create the feed string
	NSString *xPath = @"//Button";
	// Call the grabRSSFeed function with the above string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:xPath];
	// if feedEntries is not empty, empty it
	if (feedEntries.count != 0) {
		[feedEntries removeAllObjects];
	}
	// Fill feedEntries with the results of parsing the show feed
	[feedEntries addObjectsFromArray:[feed entries]];
	[feed release];
	
	if (list.count != 0) {
		[list removeAllObjects];
	}
	
	NSDictionary *feedEntry = [feedEntries objectAtIndex:0];
	[button1 setTitle:[feedEntry objectForKey:@"Title"] forState:UIControlStateNormal];
	url1 = [feedEntry objectForKey:@"URL"];
	if ([[feedEntry objectForKey:@"InApp"] isEqualToString:@"YES"]) {
		inApp1 = YES;
	}
	
	feedEntry = [feedEntries objectAtIndex:1];
	[button2 setTitle:[feedEntry objectForKey:@"Title"] forState:UIControlStateNormal];
	url2 = [feedEntry objectForKey:@"URL"];
	if ([[feedEntry objectForKey:@"InApp"] isEqualToString:@"YES"]) {
		inApp2 = YES;
	}
	
	feedEntry = [feedEntries objectAtIndex:2];
	[button3 setTitle:[feedEntry objectForKey:@"Title"] forState:UIControlStateNormal];
	url3 = [feedEntry objectForKey:@"URL"];
	if ([[feedEntry objectForKey:@"InApp"] isEqualToString:@"YES"]) {
		inApp3 = YES;
	}
	
	feedEntry = [feedEntries objectAtIndex:3];
	[button4 setTitle:[feedEntry objectForKey:@"Title"] forState:UIControlStateNormal];
	url4 = [feedEntry objectForKey:@"URL"];
	if ([[feedEntry objectForKey:@"InApp"] isEqualToString:@"YES"]) {
		inApp4 = YES;
	}
}

- (IBAction)pressedButton1:(id)sender {
	if (inApp1) {
		TinyBrowser *viewController = [[TinyBrowser alloc] init];
		viewController.urlAddress = url1;
		viewController.delegate = self;
		viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:viewController animated:YES];
		[viewController release];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url1]];
	}
}

- (IBAction)pressedButton2:(id)sender {
	if (inApp2) {
		TinyBrowser *viewController = [[TinyBrowser alloc] init];
		viewController.urlAddress = url2;
		viewController.delegate = self;
		viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:viewController animated:YES];
		[viewController release];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url1]];
	}
}

- (IBAction)pressedButton3:(id)sender {
	if (inApp3) {
		TinyBrowser *viewController = [[TinyBrowser alloc] init];
		viewController.urlAddress = url3;
		viewController.delegate = self;
		viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:viewController animated:YES];
		[viewController release];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url1]];
	}
}

- (IBAction)pressedButton4:(id)sender {
	if (inApp4) {
		TinyBrowser *viewController = [[TinyBrowser alloc] init];
		viewController.urlAddress = url4;
		viewController.delegate = self;
		viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:viewController animated:YES];
		[viewController release];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url1]];
	}
}

- (void)setButtonImages {
	UIImage *feedButtonImage = [UIImage imageNamed:@"feedButtonNormal.png"];
	UIImage *normal = [feedButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	UIImage *feedButtonHighlightedImage = [UIImage imageNamed:@"feedButtonPressed.png"];
	UIImage *highlight = [feedButtonHighlightedImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	[button1 setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button1 setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
	[button2 setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button2 setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
	[button3 setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button3 setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
	[button4 setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button4 setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
}

- (IBAction)infoSheet {
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Thanks and Credit"
						  message:@"The following people contributed directly or through content:\n • Keith Malley\n • Chemda\n • Michael Khalili\n • Hypercrypt (Klaus Dudas, Assistant Developer)\n • The Grundle (Barry Mendelson)\n • Londan Ash (Ashley Mills)\n • Picard (John Leschinski)\n • Subsonix (Marcus Newman)\n • Mapes\n • Aptmunich\n • RegexKitLite Copyright © 2008-2009, John Engelhart" 
						  delegate:nil
						  cancelButtonTitle:@"Continue" 
						  otherButtonTitles:nil];
	[alert show];
	[alert autorelease];
}

- (void)tinyBrowserDidFinish:(TinyBrowser *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];	
}

- (void)dealloc {
	[button1 release];
	[button2 release];
	[button3 release];
	[infoButton release];
    [super dealloc];
}


@end
