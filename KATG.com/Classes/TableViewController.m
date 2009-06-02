//
//  TableViewController.m
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

#import "TableViewController.h"
#import "WebViewController.h"
#import "TwtViewController.h"
#import "TweetCell.h"


@implementation TableViewController

@synthesize urlList;
@synthesize twtList;
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
	return [urlList count] + [twtList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TweetCell";
		
	TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[TweetCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	if (indexPath.row < [urlList count]) {
		cell.lblTitle.text = [urlList objectAtIndex:indexPath.row];
	} else if (indexPath.row >= [urlList count]) {
		cell.lblTitle.text = [[twtList objectAtIndex:indexPath.row - [urlList count]] objectForKey:@"user"];
	}
	
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
	if (indexPath.row < [urlList count]) {
		WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
		NSString *urlAddress = [urlList objectAtIndex:indexPath.row];
		viewController.urlAddress = urlAddress;
		[[self navigationController] pushViewController:viewController animated:YES];
		[viewController release];
	} else if (indexPath.row >= [urlList count]) {
		TwtViewController *viewController = [[TwtViewController alloc] initWithNibName:@"TableView" bundle:[NSBundle mainBundle]];
		NSString *urlAddress = [[twtList objectAtIndex:indexPath.row - [urlList count]] objectForKey:@"url"];
		viewController.searchString = urlAddress;
		[[self navigationController] pushViewController:viewController animated:YES];
		[viewController release];
	}
}

- (void)dealloc {
	[urlList release];
    [super dealloc];
}


@end

