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
#import "ShowCell.h"
#import	"Show.h"
#import "ShowDetailController.h"
#import "grabRSSFeed.h"

#define ROW_HEIGHT 60.0

static BOOL ShouldStream;

@implementation PastShowsController

@synthesize navigationController, list, filteredList, activityIndicator, feedEntries, feedAddress, indexPaths, localWiFiConnectionStatus;

#pragma mark View
- (void)viewDidLoad {
	//NSLog(@"Past Show View Did Load");
	[super viewDidLoad];
	// Set title in Navigation Bar
	self.navigationItem.title = @"Past Shows";
	// Set individual cell height
	self.tableView.rowHeight = ROW_HEIGHT;
	self.searchDisplayController.searchResultsTableView.rowHeight = ROW_HEIGHT;
	// Create a 'right hand button' that is a activity Indicator
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[self.activityIndicator sizeToFit];
	self.activityIndicator.autoresizingMask =
	(UIViewAutoresizingFlexibleLeftMargin |
	 UIViewAutoresizingFlexibleRightMargin |
	 UIViewAutoresizingFlexibleTopMargin |
	 UIViewAutoresizingFlexibleBottomMargin);
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	loadingView.target = self;
	self.navigationItem.rightBarButtonItem = loadingView;
	// Check user defaults to see if streaming is enabled over the cellular data network
	userDefaults = [NSUserDefaults standardUserDefaults];
	[[Reachability sharedReachability] setHostName:@"keithandthegirl.com"];
	self.localWiFiConnectionStatus	= [[Reachability sharedReachability] localWiFiConnectionStatus];
	if (self.localWiFiConnectionStatus == NotReachable) {
		if ([userDefaults boolForKey:@"StreamPSOverCell"]) {
			ShouldStream = YES;
		} else {
			ShouldStream = NO;
		}
	} else if (self.localWiFiConnectionStatus == ReachableViaWiFiNetwork) {
		ShouldStream = YES;
	}
	// Iniate list to hold show data, set feed address, start activity indicator and break off thread to poll show feed
	list = [[NSMutableArray alloc] initWithCapacity:1000];
	filteredList = [[NSMutableArray alloc] initWithCapacity:1000];
	feedEntries = [[NSMutableArray alloc] initWithCapacity:1000];
	
	Show *Sh = [[Show alloc] initWithTitle:@"Episode list loading ..." withNumber:@"" withGuests:@"Click Here for most recent episode"];
	[list addObject:Sh];
	[Sh release];
	
	[self.tableView reloadData];
	
	//feedAddress = @"http://app.keithandthegirl.com/Feed/Show/Default.ashx?records=25";
	feedAddress = @"http://getitdownonpaper.com/katg/Shows.xml";
	
	[self.activityIndicator startAnimating];
	[NSThread detachNewThreadSelector:@selector(autoPool) toTarget:self withObject:feedAddress];
}

#pragma mark Feed
- (void)autoPool {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self pollFeed];
	[pool release];
}

- (void) pollFeed {
	// Create the feed string
	NSString *xPath = @"//S";
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
		[list removeLastObject];
	}
	
	for (NSDictionary *feedEntry in feedEntries) {
		NSString *showNumber = [feedEntry objectForKey: @"N"];
		NSString *showTitle  = [feedEntry objectForKey: @"T"];
		NSString *showGuests = [feedEntry objectForKey: @"G"];
		
		NSString *show = [NSString stringWithFormat:@"%@ - %@", showNumber, showTitle];
		
		Show *Sh = [[Show alloc] initWithTitle:show withNumber:showNumber withGuests:showGuests];
		[list addObject:Sh];
		[Sh release];
	}
	
	if ([list count] == 0) {
		Show *Sh = [[Show alloc] initWithTitle:@"No Internet Connection" withNumber:@"" withGuests:@""];
		[list addObject:Sh];
		[Sh release];
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
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [filteredList count];
    }
	else
	{
        return [list count];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ShowCell";
	
	ShowCell *cell = (ShowCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[ShowCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		cell.lblTitle.text = [[filteredList objectAtIndex:indexPath.row] title];
		cell.lblGuests.text = [[filteredList objectAtIndex:indexPath.row] guests];
	}
	else
	{
        cell.lblTitle.text = [[list objectAtIndex:indexPath.row] title];
		cell.lblGuests.text = [[list objectAtIndex:indexPath.row] guests];
    }
	
	UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.776 green:(CGFloat).875 blue:(CGFloat)0.776 alpha:(CGFloat)1.0];
	UIColor *color2 = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.627 alpha:(CGFloat)1.0];
	
	if (indexPath.row%2 == 0) {
		cell.lblTitle.backgroundColor = color1;
		cell.lblGuests.backgroundColor = color1;
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackground60.png"]];
	} else {
		cell.lblTitle.backgroundColor = color2;
		cell.lblGuests.backgroundColor = color2;
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundDark60.png"]];
	}
	
	cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundSelected60.png"]];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowDetailController *viewController = [[ShowDetailController alloc] initWithNibName:@"ShowView" bundle:[NSBundle mainBundle]];
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		viewController.feedAddress = [NSString stringWithFormat:@"http://app.keithandthegirl.com/Feed/Show/Default.ashx?Number=%@", [[filteredList objectAtIndex:indexPath.row] number]];
	}
	else
	{
		viewController.feedAddress = [NSString stringWithFormat:@"http://app.keithandthegirl.com/Feed/Show/Default.ashx?Number=%@", [[list objectAtIndex:indexPath.row] number]];
    }
	if (ShouldStream) {
		[viewController setStream:YES];
	}
	[[self navigationController] pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredList removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (Show *sh in list)
	{
		NSRange result1 = [sh.title rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		NSRange result2 = [sh.guests rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];

		if ((result1.location != NSNotFound && result1.length != 0) || (result2.location != NSNotFound && result2.length != 0)) {
			[self.filteredList addObject:sh];
		}
	}
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	self.searchDisplayController.searchResultsTableView.rowHeight = ROW_HEIGHT;
	
    [self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	self.searchDisplayController.searchResultsTableView.rowHeight = ROW_HEIGHT;
	
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (void)dealloc {
	[list release];
	[activityIndicator release];
	[feedEntries release];
	[feedAddress release];
	[indexPaths release];
	[userDefaults release];
    [super dealloc];
}

@end