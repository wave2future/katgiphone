//
//  TableViewController.m
//  KATG.com
//
//  Created by Doug Russell on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableViewController.h"
#import "WebViewController.h"
#import "TweetCell.h"


@implementation TableViewController

@synthesize list;

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TweetCell";
		
	TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[TweetCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	cell.lblTitle.text = [list objectAtIndex:indexPath.row];
	
	cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.92 green:(CGFloat).973 blue:(CGFloat)0.92 alpha:(CGFloat)1.0];
	UIColor *color2 = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.667 alpha:(CGFloat)1.0];
	if (indexPath.row%2 == 0) {
		cell.lblTitle.backgroundColor = color1;
		cell.lblFrom.backgroundColor = color1;
		cell.lblSince.backgroundColor = color1;
		cell.backgroundView.backgroundColor = color1;
	} else {
		cell.lblTitle.backgroundColor = color2;
		cell.lblFrom.backgroundColor = color2;
		cell.lblSince.backgroundColor = color2;
		cell.backgroundView.backgroundColor = color2;
	}
	
	cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(CGFloat)0.72 green:(CGFloat).773 blue:(CGFloat)0.72 alpha:(CGFloat)1.0];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
	NSString *urlAddress = [list objectAtIndex:indexPath.row];
	viewController.urlAddress = urlAddress;
	[[self navigationController] pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)dealloc {
	[list release];
    [super dealloc];
}


@end

