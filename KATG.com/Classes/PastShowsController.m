//
//  PastShowsController.m
//  KATG.com
//
//  Copyright 2008 Doug Russell
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

#import "PastShowsController.h"
#import "ShowCell.h"
#import	"Show.h"
#import "ShowDetailController.h"
#import "grabRSSFeed.h"

#define ROW_HEIGHT 60.0

static BOOL ShouldStream;

@implementation PastShowsController

@synthesize navigationController, list, listProxy, filteredList, activityIndicator, feedEntries, feedAddress, indexPaths, localWiFiConnectionStatus;

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
	listProxy = [[NSMutableArray alloc] initWithCapacity:1000];
	filteredList = [[NSMutableArray alloc] initWithCapacity:1000];
	feedEntries = [[NSMutableArray alloc] initWithCapacity:1000];
	
	feedAddress = @"http://app.keithandthegirl.com/Api/Feed/Show-List-Everything-Compact/";
	
	[self createNotificationForTermination];
	
	[self.activityIndicator startAnimating];
	[NSThread detachNewThreadSelector:@selector(autoPool) toTarget:self withObject:feedAddress];
}

-(void)viewDidAppear:(BOOL)animated {
	// This prevents repeatedly adding Episode List Loading when there's no internet connection
	if (list.count > 0) {
		if ([[[list objectAtIndex:0] title] isEqualToString:@"No Internet Connection"]) {
			return;
		}
	}
	if (list.count == 0) {
		Show *Sh = [[Show alloc] initWithTitle:@"Episode list loading ..." withNumber:@"" withGuests:@"Click Here for most recent episode"];
		[listProxy addObject:Sh];
		[Sh release];
		
		NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
		NSString * feedFilePath = [documentsPath stringByAppendingPathComponent: @"pastshowsfeed.plist"];
		
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath: feedFilePath]) {
			[feedEntries addObjectsFromArray:[NSArray arrayWithContentsOfFile:feedFilePath]];
			
			for (NSDictionary *feedEntry in feedEntries) {
				NSString *showNumber = [feedEntry objectForKey: @"N"];
				NSString *showTitle  = [feedEntry objectForKey: @"T"];
				NSString *showGuests = [feedEntry objectForKey: @"G"];
				if ([showGuests isEqualToString:@"NULL"]) { showGuests = @"No Guests"; }
				NSString *showID	 = [feedEntry objectForKey: @"I"];
				
				NSString *show = [NSString stringWithFormat:@"%@ - %@", showNumber, showTitle];
				
				Show *Sh = [[Show alloc] initWithTitle:show withNumber:showID withGuests:showGuests];
				[listProxy addObject:Sh];
				[Sh release];
			}
		}
		
		[list removeAllObjects];
		[list addObjectsFromArray:listProxy];
		[listProxy removeAllObjects];
		
		[self.tableView reloadData];
	}
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
	
	if (listProxy.count != 0) {
		[listProxy removeAllObjects];
	}
	
	for (NSDictionary *feedEntry in feedEntries) {
		NSString *showNumber = [feedEntry objectForKey: @"N"];
		NSString *showTitle  = [feedEntry objectForKey: @"T"];
		NSString *showGuests = [feedEntry objectForKey: @"G"];
		if ([showGuests isEqualToString:@"NULL"]) { showGuests = @"No Guests"; }
		NSString *showID	 = [feedEntry objectForKey: @"I"];
		
		NSString *show = [NSString stringWithFormat:@"%@ - %@", showNumber, showTitle];
		
		Show *Sh = [[Show alloc] initWithTitle:show withNumber:showID withGuests:showGuests];
		[listProxy addObject:Sh];
		[Sh release];
	}
	
	if ([listProxy count] == 0) {
		Show *Sh = [[Show alloc] initWithTitle:@"No Internet Connection" withNumber:@"" withGuests:@""];
		[listProxy addObject:Sh];
		[Sh release];
	}
	
	[list removeAllObjects];
	[list addObjectsFromArray:listProxy];
	[listProxy removeAllObjects];
	
	[self.activityIndicator stopAnimating];
	
	[self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
}

- (void)reloadTableView {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	ShowDetailController *viewController = [[ShowDetailController alloc] initWithNibName:@"ShowView" bundle:[NSBundle mainBundle]];
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		viewController.showNumber = [[filteredList objectAtIndex:indexPath.row] number];
	}
	else
	{
		viewController.showNumber = [[list objectAtIndex:indexPath.row] number];
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

- (void)createNotificationForTermination { 
	//NSLog(@"createNotificationTwo"); 
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleTerminationNotification:) 
	 name:@"ApplicationWillTerminate" 
	 object:nil]; 
}

-(void)handleTerminationNotification:(NSNotification *)pNotification {
	NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	NSString * feedFilePath = [documentsPath stringByAppendingPathComponent: @"pastshowsfeed.plist"];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: feedFilePath]) {
		[fm removeItemAtPath: feedFilePath error:NULL];
	}
	
	[feedEntries writeToFile:feedFilePath atomically:YES];
}

- (void)dealloc {
	[list release];
	[listProxy release];
	[activityIndicator release];
	[feedEntries release];
	[feedAddress release];
	[indexPaths release];
	[userDefaults release];
    [super dealloc];
}

@end