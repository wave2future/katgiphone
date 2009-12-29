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

#import "PastShowsTableViewController.h"
#import "PastShowsTableCellView.h"
#import "PastShowsDetailViewController.h"
#import "Reachability.h"

#define ROW_HEIGHT 80.0

@implementation PastShowsTableViewController

@synthesize delegate;
@synthesize navigationController;
@synthesize list;
@synthesize filteredList;

#pragma mark -
#pragma mark Setup
#pragma mark -

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self.tableView setRowHeight:ROW_HEIGHT];
	self.searchDisplayController.searchResultsTableView.rowHeight = ROW_HEIGHT;
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	shouldStream = [delegate shouldStream];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(_reachabilityChanged:) 
												 name:kReachabilityChangedNotification 
											   object:nil];
	
	PastShowsDataModel *model = [PastShowsDataModel sharedPastShowsDataModel];
	[model setDelegate:self];
	[model setShouldStream:shouldStream];
	list = [model shows];
	filteredList = [[NSMutableArray alloc] initWithCapacity:1000];
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
#pragma mark Cleanup
#pragma mark -

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[navigationController release];
	[list release];
    [super dealloc];
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
        [[cell showTitleLabel] setText:[[filteredList objectAtIndex:indexPath.row] objectForKey:@"Show"]];
		[[cell showGuestsLabel] setText:[[filteredList objectAtIndex:indexPath.row] objectForKey:@"Guests"]];
		
		if ([[[filteredList objectAtIndex:indexPath.row] objectForKey:@"Number"] intValue] < 30) {
			[[cell showTypeImageView] setImage:[UIImage imageNamed:@"katgtv.png"]];
		} else {
			[[cell showTypeImageView] setImage:[UIImage imageNamed:@"LiveShowIconTrans.png"]];
		}
		[[cell showNotesImageView] setImage:[UIImage imageNamed:@"notes.png"]];
		[[cell showPicsImageView] setImage:[UIImage imageNamed:@"pics.png"]];
    }
	else
	{
        [[cell showTitleLabel] setText:[[list objectAtIndex:indexPath.row] objectForKey:@"Show"]];
		[[cell showGuestsLabel] setText:[[list objectAtIndex:indexPath.row] objectForKey:@"Guests"]];
		
		if ([[[list objectAtIndex:indexPath.row] objectForKey:@"Number"] intValue] < 30) {
			[[cell showTypeImageView] setImage:[UIImage imageNamed:@"katgtv.png"]];
		} else {
			[[cell showTypeImageView] setImage:[UIImage imageNamed:@"LiveShowIconTrans.png"]];
		}
		[[cell showNotesImageView] setImage:[UIImage imageNamed:@"notes.png"]];
		[[cell showPicsImageView] setImage:[UIImage imageNamed:@"pics.png"]];
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
	
	[self.navigationController pushViewController:viewController animated:YES];
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
	list = shows;
	[self reloadTableView];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	// Update the filtered array based on the search text and scope.
	[self.filteredList removeAllObjects]; // First clear the filtered array.
	
	// Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	for (NSDictionary *show in list)
	{
		NSInteger buttonIndex = self.searchDisplayController.searchBar.selectedScopeButtonIndex;
		NSRange	result1 = NSMakeRange(NSNotFound, 0);
		if (buttonIndex == 0 || buttonIndex == 3) {
			result1 = [[show objectForKey:@"Title"] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		}
		NSRange	result2 = NSMakeRange(NSNotFound, 0);
		if (buttonIndex == 1 || buttonIndex == 3) {
			result2 = [[show objectForKey:@"Number"] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
		}
		NSRange	result3 = NSMakeRange(NSNotFound, 0);
		if (buttonIndex == 2 || buttonIndex == 3) {
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

