//
//  EventsViewController.m
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

#import "EventsViewController.h"
#import "Event.h"
#import "CustomCell.h"
#import "TouchXML.h"
#import "DetailViewController.h"
#import "grabRSSFeed.h"

#define ROW_HEIGHT 80.0


@implementation EventsViewController

@synthesize navigationController;
@synthesize list;
@synthesize feedEntries;
@synthesize activityIndicator;

//*******************************************************
//* pollFeed
//*
//* Create and run live show feed xml
//*******************************************************
- (void) pollFeed {
	if (feedEntries.count == 0) {
		// Create the feed string
		NSString *feedAddress = @"http://www.keithandthegirl.com/feed/event/?order=datereverse";
		NSString *xPath = @"//Event";
		// Call the grabRSSFeed function with the above
		// string as a parameter
		grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:(NSString *)xPath];
		feedEntries = [feed entries];
		[feed release];
	}
	
	//[feedEntries count]
	int feedEntryIndex = [feedEntries count] - 1;
	
	// Evaluate the contents of feed for classification and add results into list
	NSString *eventType = nil;
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_3_0
	
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle: NSDateFormatterLongStyle];
	[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
	[formatter setDateFormat: @"MM/dd/yyyy HH:mm"];
	NSTimeZone *EST = [NSTimeZone timeZoneWithName:(NSString *)@"America/New_York"];
	[formatter setTimeZone:(NSTimeZone *)EST];
	
	NSDateFormatter * reFormatter = [[NSDateFormatter alloc] init];
	[reFormatter setDateStyle: NSDateFormatterLongStyle];
	[reFormatter setFormatterBehavior: NSDateFormatterBehavior10_4];
	[reFormatter setDateFormat: @"hh:mm aa"];
	
	NSDateFormatter * reFormatterator = [[NSDateFormatter alloc] init];
	[reFormatterator setDateStyle: NSDateFormatterLongStyle];
	[reFormatterator setFormatterBehavior: NSDateFormatterBehavior10_4];
	[reFormatterator setDateFormat: @"EEE, MM/dd"];
	
	while ( 0 <= feedEntryIndex ) {
		
		NSString *feedTitle = [[feedEntries objectAtIndex: feedEntryIndex] 
							   objectForKey: @"Title"];
		
		NSString *feedDetails = [[feedEntries objectAtIndex: feedEntryIndex] 
								 objectForKey: @"Details"];
		
		NSString *feedTime = [[feedEntries objectAtIndex: feedEntryIndex] 
							  objectForKey: @"StartDate"];
		
#elif __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_0
		
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle: NSDateFormatterLongStyle];
	[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
	[formatter setDateFormat: @"MM/dd/yyyy HH:mm zzz"];
	
	NSDateFormatter * reFormatter = [[NSDateFormatter alloc] init];
	[reFormatter setDateStyle: NSDateFormatterLongStyle];
	[reFormatter setFormatterBehavior: NSDateFormatterBehavior10_4];
	NSTimeZone *local = [NSTimeZone localTimeZone];
	[reFormatter setTimeZone:local];
	[reFormatter setDateFormat: @"hh:mm aa"];
	
	NSDateFormatter * reFormatterator = [[NSDateFormatter alloc] init];
	[reFormatterator setDateStyle: NSDateFormatterLongStyle];
	[reFormatterator setFormatterBehavior: NSDateFormatterBehavior10_4];
	[reFormatterator setTimeZone:local];
	[reFormatterator setDateFormat: @"EEE, MM/dd"];
	
	while ( 0 <= feedEntryIndex ) {
		
		NSString *feedTitle = [[feedEntries objectAtIndex: feedEntryIndex] 
							   objectForKey: @"Title"];
		
		NSString *feedDetails = [[feedEntries objectAtIndex: feedEntryIndex] 
								 objectForKey: @"Details"];
		
		NSString *feedTime = [[feedEntries objectAtIndex: feedEntryIndex] 
							  objectForKey: @"StartDate"];
		
		NSTimeZone *EST = [NSTimeZone timeZoneWithName:(NSString *)@"America/New_York"];
		
		if ([EST isDaylightSavingTime]) {
			feedTime = [feedTime stringByAppendingString:@" EDT"];
		} else {
			feedTime = [feedTime stringByAppendingString:@" EST"];
		}
		
#endif
		
		NSDate *eventTime = [formatter dateFromString: feedTime];
		
		NSString *feedTimeString = nil;
		NSString *feedDateString = nil;
		if (eventTime != nil) {
			feedTimeString = [reFormatter stringFromDate:eventTime];
			feedDateString = [reFormatterator stringFromDate:eventTime];
		} else {
			feedTimeString = @"Unknown";
			feedTimeString = @"Unknown";
		}
		
		// Determines if event is live show
		BOOL match = ([feedTitle rangeOfString:@"Live Show" options:NSCaseInsensitiveSearch].location != NSNotFound);
		
		if (match) {
			eventType = @"show";
		} else {
			eventType = @"event";
		}
		
		Event *Ev = [[Event alloc] initWithTitle:feedTitle publishTime:feedTimeString publishDate:feedDateString type:eventType detail:feedDetails];
		[list addObject:Ev];
		
		[Ev release];
		
		feedEntryIndex = feedEntryIndex - 1;
	}
	
	if ([list count] == 0) {
		Event *Ev = [[Event alloc] initWithTitle:@"No Internet Connection" publishTime:@"12:00 AM" publishDate:@"WED 04/15" type:@"The Show" detail:@"Without an internet connection this app will not function normally. Connect to wifi or a cellular data service."];
		[list addObject:Ev];
	}
	
	[self.activityIndicator stopAnimating];
	
	[self.tableView reloadData];
}

//*******************************************************
//* viewDidLoad:
//*
//* Set row height, you could add buttons to the
//* navigation controller here.
//*
//*******************************************************
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Events";
	
	NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString * feedFilePath = [documentsPath stringByAppendingPathComponent: @"feed.save"];
	NSMutableArray *feedPack = [[NSMutableArray alloc] initWithCapacity:2];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: feedFilePath]) {
		[feedPack addObjectsFromArray: [NSMutableArray arrayWithContentsOfFile: feedFilePath]];
	
		NSDate *then = [feedPack objectAtIndex:1];
		int timeSince = -[then timeIntervalSinceNow];
		if (timeSince < 600) {
			feedEntries = [feedPack objectAtIndex:0];
		}
	}
	
    self.tableView.rowHeight = ROW_HEIGHT;
	
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
	
	list = [[NSMutableArray alloc] init];
	
	[self.activityIndicator startAnimating];
	[ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: nil ];
}

- (void)autoPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self pollFeed];
	[ pool release ];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//*******************************************************
//* tableView:numberOfRowsInSection
//*
//*  Customize the number of rows in the table view
//*
//*******************************************************
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}

//*******************************************************
//* tableView:cellForRowAtIndexPath
//*
//* Customize the appearance of table view cells.
//* Assign icons to event types
//*
//*******************************************************
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CustomCell";
	
	CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[CustomCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	cell.lblTitle.text = [[list objectAtIndex:indexPath.row] title];
	cell.lblPublish.text = [[list objectAtIndex:indexPath.row] publishTime];
	cell.lblPublishDate.text = [[list objectAtIndex:indexPath.row] publishDate];
	cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.92 green:(CGFloat).973 blue:(CGFloat)0.92 alpha:(CGFloat)1.0];
	UIColor *color2 = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.667 alpha:(CGFloat)1.0];
	if (indexPath.row%2 == 0) {
		cell.lblTitle.backgroundColor = color1;
		cell.lblPublish.backgroundColor = color1;
		cell.lblPublishDate.backgroundColor = color1;
		cell.backgroundView.backgroundColor = color1;
	} else {
		cell.lblTitle.backgroundColor = color2;
		cell.lblPublish.backgroundColor = color2;
		cell.lblPublishDate.backgroundColor = color2;
		cell.backgroundView.backgroundColor = color2;
	}
	
	cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(CGFloat)0.72 green:(CGFloat).773 blue:(CGFloat)0.72 alpha:(CGFloat)1.0];
	
	NSString *type = [[list objectAtIndex:indexPath.row] type];
	if ( [type isEqualToString:@"show"] ) {
		cell.imgSquare.image = [UIImage imageNamed:@"LiveShowIconTrans.png"];
	} else if ( [type isEqualToString:@"event"] ) {
		cell.imgSquare.image = [UIImage imageNamed:@"EventIconTrans.png"];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

//*******************************************************
//* tableView:didSelectRowAtIndexPath
//*
//*  Establishes a view controller using the
//*  DetailViewController and passes it variable.
//*  When a row is selected the DetailView.xib is
//*  pushed.
//*
//*******************************************************
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DetailViewController *viewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	viewController.TitleTemp = [[list objectAtIndex:indexPath.row] title];
	viewController.TimeTemp = [[list objectAtIndex:indexPath.row] publishTime];
	viewController.DateTemp = [[list objectAtIndex:indexPath.row] publishDate];
	viewController.BodyTemp = [[list objectAtIndex:indexPath.row] detail];
	[[self navigationController] pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)dealloc {
	[navigationController release];
    [list release];
    [super dealloc];
}


@end

