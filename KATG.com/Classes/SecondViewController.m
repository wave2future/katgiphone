//
//  SecondViewController.m
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

#import "SecondViewController.h"
#import "KATG_comAppDelegate.h"
#import "Event.h"
#import "CustomCell.h"
#import "TouchXML.h"
#import "DetailViewController.h"
#import "grabRSSFeed.h"

#define ROW_HEIGHT 80.0

@implementation SecondViewController

//*******************************************************
//* awakeFromNib:
//*
//* Set title in navigation bar, establish list array for
//* events and poll xml feed
//*
//*******************************************************
- (void)awakeFromNib {
	
	self.navigationItem.title = @"Events";
	
    list = [[NSMutableArray alloc] init];
	
}

//*******************************************************
//* pollFeed
//*
//* Create and run live show feed xml
//*******************************************************
- (void) pollFeed
{
	// Create the feed string
    NSString *feedAddress = @"http://www.keithandthegirl.com/feed/event/?order=datereverse";
	NSString *xPath = @"//Event";
    // Call the grabRSSFeed function with the above
    // string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:(NSString *)xPath];
	feedEntries = [feed entries];
	[feed release];
	
	//[feedEntries count]
	int feedEntryIndex = [feedEntries count] - 1;
	
	// Evaluate the contents of feed for classification and add results into list
	NSString *eventType = nil;
		
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
	 
	while ( 0 <= feedEntryIndex ) {
		
		NSString *feedTitle = [[feedEntries objectAtIndex: feedEntryIndex] 
							   objectForKey: @"Title"];
		
		NSString *feedDetails = [[feedEntries objectAtIndex: feedEntryIndex] 
								 objectForKey: @"Details"];
		
		NSString *feedTime = [[feedEntries objectAtIndex: feedEntryIndex] 
							  objectForKey: @"StartDate"];
		
		NSDate *eventTime = [formatter dateFromString: feedTime];
				
		NSString *feedTimeString = nil;
		if (eventTime != nil) {
			feedTimeString = [reFormatter stringFromDate:eventTime];
		} else {
			feedTimeString = @"Unknown";
		}
						
		// Determines if event is live show
		BOOL match = ([feedTitle rangeOfString:@"Live Show" options:NSCaseInsensitiveSearch].location != NSNotFound);
		
		
		if (match) {
			eventType = @"show";
		} else {
			eventType = @"event";
		}
		
		Event *Ev = [[Event alloc] initWithTitle:feedTitle publishDate:feedTimeString type:eventType detail:feedDetails];
		[list addObject:Ev];
		
		[Ev release];
		
		feedEntryIndex = feedEntryIndex - 1;
	}
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
    
    self.tableView.rowHeight = ROW_HEIGHT;
	
	[self pollFeed];
	
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
    cell.lblPublish.text = [[list objectAtIndex:indexPath.row] publishDate];
	
    NSString *type = [[list objectAtIndex:indexPath.row] type];
    if ( [type isEqualToString:@"show"] ) {
        cell.imgSquare.image = [UIImage imageNamed:@"showSquare.png"];
    } else if ( [type isEqualToString:@"event"] ) {
        cell.imgSquare.image = [UIImage imageNamed:@"eventSquare.png"];
    } else if ( [type isEqualToString:@"other"] ) {
        cell.imgSquare.image = [UIImage imageNamed:@"otherSquare.png"];
    }
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
	viewController.DateTemp = [[list objectAtIndex:indexPath.row] publishDate];
	viewController.BodyTemp = [[list objectAtIndex:indexPath.row] detail];
	[[self navigationController] pushViewController:viewController animated:YES];
	[viewController release];
}


- (void)dealloc {
    [list release];
    [super dealloc];
}


@end

