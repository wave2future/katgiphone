//
//  PastShowsController.m
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

#import "PastShowsController.h"
#import "grabRSSFeed.h"
#import "ShowCell.h"
#import "ShowDetailController.h"
#import	"Show.h"

#define ROW_HEIGHT 60.0


@implementation PastShowsController

@synthesize navigationController;
@synthesize list;
@synthesize activityIndicator;
@synthesize feedEntries;
@synthesize feedAddress;
@synthesize indexPaths;
@synthesize localWiFiConnectionStatus;

#pragma mark View
- (void)viewDidLoad {
	NSLog(@"Past Show View Did Load");
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
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	[[Reachability sharedReachability] setHostName:@"keithandthegirl.com"];
	self.localWiFiConnectionStatus	= [[Reachability sharedReachability] localWiFiConnectionStatus];
	
	if (self.localWiFiConnectionStatus == NotReachable) {
		if ([userDefaults boolForKey:@"StreamPSOverCell"]) {
			feedAddress = @"http://app.keithandthegirl.com/Feed/Show/Default.ashx?records=25";
			[self.activityIndicator startAnimating];
			[ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: feedAddress ];
		} else {
			Show *Sh = [[Show alloc] initWithTitle:@"Past Shows Disabled" publishDate:@"April 15th" link:@"" detail:@""];
			[list addObject:Sh];
		}
	} else if (self.localWiFiConnectionStatus == ReachableViaWiFiNetwork) {
		feedAddress = @"http://app.keithandthegirl.com/Feed/Show/Default.ashx?records=25";
		[self.activityIndicator startAnimating];
		[ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: feedAddress ];
	}
}

#pragma mark Feed
- (void)autoPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self pollFeed];
	[ pool release ];
}

- (void) pollFeed {
	// Create the feed string
	NSString *xPath = @"//Show";
    // Call the grabRSSFeed function with the above
    // string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:(NSString *)xPath];
	[feedEntries removeAllObjects];
	feedEntries = [[NSMutableArray alloc] initWithArray:[feed entries]];
	[feed release];
	
	int feedEntryIndex = [feedEntries count] - 1;
	
	if (list.count != 0) {
		[list removeLastObject];
	}
	
	int i = 0;
		
	while ( i < feedEntryIndex ) {
		
		NSString *showNumber = [[feedEntries objectAtIndex: i] 
							   objectForKey: @"Number"];
		
		NSString *showDate = [[feedEntries objectAtIndex: i] 
							   objectForKey: @"PostedDate"];
		
		NSString *showTitle = [[feedEntries objectAtIndex: i] 
							  objectForKey: @"Title"];
		
		//NSString *showDescription = [[feedEntries objectAtIndex: i] 
		//					  objectForKey: @"Description"];
		
		//NSString *showThread = [[feedEntries objectAtIndex: i] 
		//						 objectForKey: @"ForumThread"];
		
		NSString *showURL = [[feedEntries objectAtIndex: i] 
								 objectForKey: @"FileUrl"];
		
		NSString *showDetails = [[feedEntries objectAtIndex: i] 
								 objectForKey: @"Detail"];
		
		NSString *show = [ [showNumber stringByAppendingString:@" "] stringByAppendingString:showTitle];
		
		Show *Sh = [[Show alloc] initWithTitle:show publishDate:showDate link:showURL detail:showDetails];
		[list addObject:Sh];
		
		[Sh release];
		
		i += 1;
	}
	
	if ([list count] == 0) {
		Show *Sh = [[Show alloc] initWithTitle:@"No Internet Connection" publishDate:@"April 15th" link:@"" detail:@""];
		[list addObject:Sh];
	} else {
		Show *Sh = [[Show alloc] initWithTitle:@"Load More Episodes" publishDate:@"April 15th" link:@"" detail:@""];
		[list addObject:Sh];
	}
	
	[self.activityIndicator stopAnimating];
	
	[self.tableView reloadData];
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
    if (![[[list objectAtIndex:indexPath.row] title] isEqualToString:@"Load More Episodes"]) {
		static NSString *CellIdentifier = @"ShowCell";
		
		ShowCell *cell = (ShowCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[ShowCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Set up the cell...
		cell.lblTitle.text = [[list objectAtIndex:indexPath.row] title];
		
		UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.776 green:(CGFloat).875 blue:(CGFloat)0.776 alpha:(CGFloat)1.0];
		UIColor *color2 = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.627 alpha:(CGFloat)1.0];
		
		if (indexPath.row%2 == 0) {
			cell.lblTitle.backgroundColor = color1;
			cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackground60.png"]];
		} else {
			cell.lblTitle.backgroundColor = color2;
			cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundDark60.png"]];
		}
		
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundSelected60.png"]];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	} else {
		static NSString *CellIdentifier = @"ShowCell";
		
		ShowCell *cell = (ShowCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[ShowCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Set up the cell...
		cell.lblTitle.text = [[list objectAtIndex:indexPath.row] title];
		
		UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.776 green:(CGFloat).875 blue:(CGFloat)0.776 alpha:(CGFloat)1.0];
		UIColor *color2 = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.667 alpha:(CGFloat)1.0];
		
		if (indexPath.row%2 == 0) {
			cell.lblTitle.backgroundColor = color1;
			cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackground60.png"]];
		} else {
			cell.lblTitle.backgroundColor = color2;
			cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundDark60.png"]];
		}
		
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundSelected60.png"]];
		
		return cell;
	}
}

 // Override to support row selection in the table view.
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	 if (![[[list objectAtIndex:indexPath.row] title] isEqualToString:@"Load More Episodes"] &&
		 ![[[list objectAtIndex:indexPath.row] title] isEqualToString:@"No Internet Connection"]) {
		 ShowDetailController *viewController = [[ShowDetailController alloc] initWithNibName:@"ShowView" bundle:[NSBundle mainBundle]];
		 viewController.TitleTemp = [[list objectAtIndex:indexPath.row] title];
		 viewController.LinkTemp = [[list objectAtIndex:indexPath.row] link];
		 viewController.BodyTemp = [[list objectAtIndex:indexPath.row] detail];
		 [[self navigationController] pushViewController:viewController animated:YES];
		 [viewController release];
	 } else if ([[[list objectAtIndex:indexPath.row] title] isEqualToString:@"Load More Episodes"]) {
		 [self.activityIndicator startAnimating];
		 NSNumber *showNumber = [[feedEntries objectAtIndex: [feedEntries count] - 1] objectForKey: @"Number"];
		 feedAddress = @"http://app.keithandthegirl.com/Feed/Show/Default.ashx?startlist=";
		 feedAddress = [feedAddress stringByAppendingString:[NSString stringWithFormat: @"%@", showNumber]];
		 feedAddress = [feedAddress stringByAppendingString:@"&records=100"];
		 indexPaths = [NSArray arrayWithObject:indexPath];
		 [ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: feedAddress ];
	 }
 }

#pragma mark System

- (void)viewDidDisappear:(BOOL)animated {
	NSLog(@"Past Shows View Did Dissapear");
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
	NSLog(@"Past Shows View Did Unload");
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	[list removeAllObjects];
	
	Show *Sh = [[Show alloc] initWithTitle:@"Low Memory Warning" publishDate:@"April 15th" link:@"" detail:@"This view has been released to free up memory."];
	[list addObject:Sh];
	[Sh release];
	[self.tableView reloadData];
	
	NSLog(@"Past Shows View Did Receive Memory Warning");
}

- (void)dealloc {
    [super dealloc];
}

@end


