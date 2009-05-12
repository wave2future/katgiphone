//
//  PastShowsController.m
//  KATG.com
//
//  Created by Doug Russell on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PastShowsController.h"
#import "XMLReader.h"
#import "ShowCell.h"
#import "ShowDetailController.h"


#define ROW_HEIGHT 60.0

@implementation PastShowsController

@synthesize navigationController;
@synthesize list;
@synthesize activityIndicator;

#pragma mark View
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 
	 self.navigationItem.title = @"Past Shows";
	 
	 self.tableView.rowHeight = ROW_HEIGHT;
	 
	 list = [[NSMutableArray alloc] init];
	 
	 // Create a 'right hand button' that is a activity Indicator
	 CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	 self.activityIndicator = [[UIActivityIndicatorView alloc]
							   initWithFrame:frame];
	 [self.activityIndicator sizeToFit];
	 self.activityIndicator.autoresizingMask =
	 (UIViewAutoresizingFlexibleLeftMargin |
	  UIViewAutoresizingFlexibleRightMargin |
	  UIViewAutoresizingFlexibleTopMargin |
	  UIViewAutoresizingFlexibleBottomMargin);
	 
	 UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] 
									 initWithCustomView:self.activityIndicator];
	 loadingView.target = self;
	 self.navigationItem.rightBarButtonItem = loadingView;
	 
	 [self.activityIndicator startAnimating];
	 [ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: nil ];
	 
}

#pragma mark Feed
- (void)autoPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self pollFeed];
	[ pool release ];
}

- (void) pollFeed {
	NSError *parseError = nil;
	
	NSString *feedURLString = @"http://keithandthegirl.com/rss";
	//NSString *feedURLString = @"http://whywontyoudie.com/feed.xml";
	
	XMLReader *streamingParser = [[XMLReader alloc] init];
    self.list = [streamingParser parseXMLFileAtURL:[NSURL URLWithString:feedURLString] parseError:&parseError];
    [streamingParser release];
	
	if ([list count] == 0) {
		//Event *Ev = [[Event alloc] initWithTitle:@"No Internet Connection" publishTime:@"12:00 AM" publishDate:@"WED 04/15" type:@"The Show" detail:@"Without an internet connection this app will not function normally. Connect to wifi or a cellular data service."];
		//[list addObject:Ev];
	}
	
	[self.activityIndicator stopAnimating];
	
	[self.tableView reloadData];
}



#pragma mark System

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ShowCell";
	
	ShowCell *cell = (ShowCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[ShowCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	cell.lblTitle.text = [[list objectAtIndex:indexPath.row] title];
	
	cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.92 green:(CGFloat).973 blue:(CGFloat)0.92 alpha:(CGFloat)1.0];
	UIColor *color2 = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.667 alpha:(CGFloat)1.0];
	if (indexPath.row%2 == 0) {
		cell.lblTitle.backgroundColor = color1;
		
		cell.backgroundView.backgroundColor = color1;
	} else {
		cell.lblTitle.backgroundColor = color2;
		
		cell.backgroundView.backgroundColor = color2;
	}
	
	cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(CGFloat)0.72 green:(CGFloat).773 blue:(CGFloat)0.72 alpha:(CGFloat)1.0];
	
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

 // Override to support row selection in the table view.
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 ShowDetailController *viewController = [[ShowDetailController alloc] initWithNibName:@"ShowView" bundle:[NSBundle mainBundle]];
	 viewController.TitleTemp = [[list objectAtIndex:indexPath.row] title];
	 viewController.LinkTemp = [[list objectAtIndex:indexPath.row] link];
	 viewController.BodyTemp = [[list objectAtIndex:indexPath.row] detail];
	 [[self navigationController] pushViewController:viewController animated:YES];
	 [viewController release];
 }


- (void)dealloc {
    [super dealloc];
}


@end


