//
//  linkList.m
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

#import "linkList.h"
#import "TinyBrowser.h"
#import "LinkCell.h"
#import "Links.h"
#import "grabRSSFeed.h"
#import "MREntitiesConverter.h"

@implementation linkList

@synthesize infoButton, tblView;

- (void)viewDidLoad {
	list = [[NSMutableArray alloc] initWithCapacity:4];
}

- (void)viewWillAppear:(BOOL)animated {
	[tblView setDelegate:self];
	tblView.rowHeight = 80;
	[self pollFeed];
}

- (void) pollFeed {
	if ([list count] == 0) {
		//NSString *feedAddress = @"http://keithandthegirl.com/API/App/Links.xml";
		NSString *feedAddress = @"http://getitdownonpaper.com/katg/Buttons.xml";
		
		NSString *xPath = @"//Button";
		// Call the grabRSSFeed function with the above string as a parameter
		grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:xPath];
		// 
		NSMutableArray *feedEntries = [[NSMutableArray alloc] initWithCapacity:4];
		// Fill feedEntries with the results of parsing the show feed
		[feedEntries addObjectsFromArray:[feed entries]];
		[feed release];
		
		for (NSDictionary *entry in feedEntries) {
			BOOL iA = NO;
			if ([[entry objectForKey:@"InApp"] isEqualToString:@"YES"]) {
				iA = YES;
			}
			Links *lnk = [[Links alloc] initWithTitle:[entry objectForKey:@"Title"] withURL:[entry objectForKey:@"URL"] withInApp:iA];
			[list addObject:lnk];
			[lnk release];
		}
		
		[tblView reloadData];
	} else {
		[tblView reloadData];
	}
}

- (IBAction)infoSheet {
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Thanks and Credit"
						  message:@"The following people contributed directly or through content:\n • Keith Malley\n • Chemda\n • Michael Khalili\n • Hypercrypt (Klaus Dudas, Assistant Developer)\n • The Grundle (Barry Mendelson)\n • Londan Ash (Ashley Mills)\n • Picard (John Leschinski)\n • Subsonix (Marcus Newman)\n • Mapes\n • Aptmunich\n • RegexKitLite Copyright © 2008-2009, John Engelhart" 
						  delegate:nil
						  cancelButtonTitle:@"Continue" 
						  otherButtonTitles:nil];
	[alert show];
	[alert autorelease];
}

- (void)tinyBrowserDidFinish:(TinyBrowser *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"LinkCell";
	
	LinkCell *cell = (LinkCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[LinkCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GreyLinkCell.png"]];
	
	cell.imgSquare.image = [UIImage imageNamed:@"LinkButton.png"];
	
	cell.lblTitle.text = [[list objectAtIndex:indexPath.row] title];
	cell.lblTitle.backgroundColor = [UIColor clearColor];
		
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL inApp = [[list objectAtIndex:indexPath.row] inApp];
	if (inApp) {
		TinyBrowser *viewController = [[TinyBrowser alloc] init];
		viewController.urlAddress = [[list objectAtIndex:indexPath.row] url];
		viewController.delegate = self;
		viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:viewController animated:YES];
		[viewController release];
	} else {
		NSString *URL = [[list objectAtIndex:indexPath.row] url];
		if ([URL rangeOfString:@"mailto:"].location != NSNotFound) {
			URL = [URL stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
			URL = [URL stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
		}
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	[list removeAllObjects];
	[tblView reloadData];
}

- (void)dealloc {
	[infoButton release];
	[tblView release];
	[list release];
    [super dealloc];
}

@end