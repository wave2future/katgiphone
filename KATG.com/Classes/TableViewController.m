//
//  TableViewController.m
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
		cell.lblTitle.text = [twtList objectAtIndex:indexPath.row - [urlList count]];
	}
	
	cell.lblTitle.backgroundColor = [UIColor clearColor];
	cell.lblFrom.backgroundColor = [UIColor clearColor];
	cell.lblSince.backgroundColor = [UIColor clearColor];
	
	if (indexPath.row%2 == 0) {
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackground60.png"]];
	} else {
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundDark60.png"]];
	}
	
	cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundSelected60.png"]];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [urlList count]) {
		//WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
		WebViewController *viewController = [[WebViewController alloc] init];
		NSString *urlAddress = [urlList objectAtIndex:indexPath.row];
		viewController.urlAddress = urlAddress;
		[[self navigationController] pushViewController:viewController animated:YES];
		[viewController release];
	} else if (indexPath.row >= [urlList count]) {
		TwtViewController *viewController = [[TwtViewController alloc] initWithNibName:@"TableView" bundle:[NSBundle mainBundle]];		
		NSString *user = [NSString stringWithFormat:@"http://twitter.com/statuses/user_timeline/%@.json", [twtList objectAtIndex:indexPath.row - [urlList count]]];
		viewController.searchString = user;
		[[self navigationController] pushViewController:viewController animated:YES];
		[viewController release];
	}
}

- (void)dealloc {
	[urlList release];
    [super dealloc];
}


@end

