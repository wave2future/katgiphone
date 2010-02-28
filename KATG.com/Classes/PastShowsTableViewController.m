//
//  PastShowsTableViewController.m
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

#define ROW_HEIGHT 80.0

#import "PastShowsTableViewController.h"
#import "PastShowsTableCellView.h"
#import "PastShowsDetailViewController.h"
#import "Reachability.h"

@implementation PastShowsTableViewController

@synthesize delegate;
@synthesize activityIndicator;
@synthesize list, filteredList;

#pragma mark -
#pragma mark Setup/Cleanup
#pragma mark -
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[self.tableView setRowHeight:ROW_HEIGHT];
	[self addActivityIndicator];
	self.searchDisplayController.searchResultsTableView.rowHeight = ROW_HEIGHT;
	userDefaults = [NSUserDefaults standardUserDefaults];
	shouldStream = [delegate shouldStream];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(_reachabilityChanged:) 
												 name:kReachabilityChangedNotification 
											   object:nil];
	model = [PastShowsDataModel sharedPastShowsDataModel];
	[model setDelegate:self];
	[model setShouldStream:shouldStream];
	list = [[model shows] retain];
	filteredList = [[NSMutableArray alloc] initWithCapacity:1000];
}
- (void)addActivityIndicator
{
	// Create a 'right hand button' that is a activity Indicator
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	self.activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithFrame:frame];
	[self.activityIndicator sizeToFit];
	self.activityIndicator.autoresizingMask =
	(UIViewAutoresizingFlexibleLeftMargin |
	 UIViewAutoresizingFlexibleRightMargin |
	 UIViewAutoresizingFlexibleTopMargin |
	 UIViewAutoresizingFlexibleBottomMargin);
	UIBarButtonItem *loadingView = 
	[[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	loadingView.target = self;
	[[self navigationItem] setRightBarButtonItem:loadingView];
	[activityIndicator release];
	[loadingView release];
	[self.activityIndicator startAnimating];
}
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	/*[list release];
	list = [[NSArray alloc] init];
	[self reloadTableView];*/
}
- (void)dealloc 
{
	delegate = nil;
	[model setDelegate:nil];
	[model release];
	model = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[activityIndicator removeFromSuperview];
	[list release];
	[filteredList release];
    [super dealloc];
}
#pragma mark Reachability
- (void)_reachabilityChanged:(NSNotification* )note
{
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self _updateReachability:curReach];
}
- (void)_updateReachability:(Reachability*)curReach
{
	BOOL streamPref = [userDefaults boolForKey:@"StreamPSOverCell"];
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus) {
		case NotReachable:
		{
			shouldStream = [NSNumber numberWithInt:0];
			break;
		}
		case ReachableViaWWAN:
		{
			if (streamPref) {
				shouldStream = [NSNumber numberWithInt:2];
			} else {
				shouldStream = [NSNumber numberWithInt:1];
			}
			break;
		}
		case ReachableViaWiFi:
		{
			shouldStream = [NSNumber numberWithInt:3];
			break;
		}
	}
}
#pragma mark -
#pragma mark Table view methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [filteredList count];
    }
	else
	{
        return [list count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"PastShowsTableCell";
    static NSString *CellNib = @"PastShowsTableCellView";
	
    PastShowsTableCellView *cell = (PastShowsTableCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
        cell = (PastShowsTableCellView *)[nib objectAtIndex:0];
    }
	
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        cell = [self decorateCell:cell withArray:filteredList withIndexPath:indexPath];
    }
	else
	{
		cell = [self decorateCell:cell withArray:list withIndexPath:indexPath];
    }
	
    return cell;
}
- (PastShowsTableCellView *)decorateCell:(PastShowsTableCellView *)cell withArray:(NSArray *)aList withIndexPath:(NSIndexPath *)indexPath
{
	NSString *titleString = [[aList objectAtIndex:indexPath.row] objectForKey:@"Show"];
	if (titleString)
	{
		CGSize size =
		[titleString sizeWithFont:[UIFont systemFontOfSize:17] 
				constrainedToSize:CGSizeMake(cell.showTitleLabel.frame.size.width, 60)];
		if (size.height > 36)
		{
			cell.showTitleLabel.font = [UIFont systemFontOfSize:14];
			cell.showTitleLabel.numberOfLines = 3;
		}
		[[cell showTitleLabel] setText:titleString];
	}
	NSString *guestsString = [[aList objectAtIndex:indexPath.row] objectForKey:@"Guests"];
	if (guestsString) [[cell showGuestsLabel] setText:guestsString];
	
	// This is some display nonsense that needs to be removed
	// and replaced with real logic
	if ([[[aList objectAtIndex:indexPath.row] objectForKey:@"Type"] boolValue]) {
		[[cell showTypeImageView] setImage:[UIImage imageNamed:@"katgtv.png"]];
	} else {
		[[cell showTypeImageView] setImage:[UIImage imageNamed:@"LiveShowIconTrans.png"]];
	}
	
	if ([[[aList objectAtIndex:indexPath.row] objectForKey:@"hasNotes"] boolValue])
	{
		[[cell showNotesImageView] setHidden:NO];
		[[cell showNotesImageView] setImage:[UIImage imageNamed:@"notes.png"]];
	}
	else 
	{
		[[cell showNotesImageView] setHidden:YES];
	}

	
	if ([[[aList objectAtIndex:indexPath.row] objectForKey:@"hasPics"] boolValue])
	{
		[[cell showPicsImageView] setHidden:NO];
		[[cell showPicsImageView] setImage:[UIImage imageNamed:@"pics.png"]];
	}
	else 
	{
		[[cell showPicsImageView] setHidden:YES];
	}
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	PastShowsDetailViewController *viewController = [[PastShowsDetailViewController alloc] initWithNibName:@"PastShowsDetailView" bundle:nil];
	[viewController setShouldStream:shouldStream];
	
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		[viewController setShow:[filteredList objectAtIndex:indexPath.row]];
	}
	else
	{
		[viewController setShow:[list objectAtIndex:indexPath.row]];
    }
	
	[[self navigationController] pushViewController:viewController animated:YES];
	[viewController release];
}
- (void)reloadTableView 
{
	if ([NSThread isMainThread]) {
		[self.tableView reloadData];
	} else {
		[self performSelectorOnMainThread:@selector(reloadTableView) 
							   withObject:nil 
							waitUntilDone:NO];
	}
}
- (void)pastShowsDataModelDidChange:(NSArray *)shows 
{
	[list release];
	list = [shows retain];
	[self reloadTableView];
}
- (void)pastShowsModelDidFinish
{
	[model setDelegate:nil];
	[model release];
	model = nil;
	[self stopActivityIndicator];
}
- (void)stopActivityIndicator
{
	if ([NSThread isMainThread])
	{
		[activityIndicator stopAnimating];
	}
	else {
		[self performSelectorOnMainThread:@selector(stopActivityIndicator) 
							   withObject:nil 
							waitUntilDone:NO];
	}

}
#define kAll 0
#define kTitle 1
#define kNumber 2
#define kGuests 3
- (void)filterContentForSearchText:(NSString*)searchText
{
	// Update the filtered array based on the search text and scope.
	[self.filteredList removeAllObjects]; // First clear the filtered array.
	
	// Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	for (NSDictionary *show in list)
	{
		NSInteger buttonIndex = self.searchDisplayController.searchBar.selectedScopeButtonIndex;
		NSRange	result1 = NSMakeRange(NSNotFound, 0);
		if (buttonIndex == kTitle || buttonIndex == kAll) {
			result1 = [[show objectForKey:@"Title"] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		}
		NSRange	result2 = NSMakeRange(NSNotFound, 0);
		if (buttonIndex == kNumber || buttonIndex == kAll) {
			result2 = [[show objectForKey:@"Number"] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		}
		NSRange	result3 = NSMakeRange(NSNotFound, 0);
		if (buttonIndex == kGuests || buttonIndex == kAll) {
			result3 = [[show objectForKey:@"Guests"] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		}
		
		BOOL one = (result1.location != NSNotFound && result1.length != 0);
		BOOL two = (result2.location != NSNotFound && result2.length != 0);
		BOOL thr = (result3.location != NSNotFound && result3.length != 0);
		BOOL tot =  (one || two || thr);
		
		if (tot) {
			[self.filteredList addObject:show];
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

@end

