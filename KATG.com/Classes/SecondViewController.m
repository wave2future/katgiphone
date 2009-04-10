//
//  SecondViewController.m
//  KATG.com
//
//  Created by Doug Russell on 4/5/09.
//  Copyright Radio Dysentery 2009. All rights reserved.
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

#define ROW_HEIGHT 100.0

@implementation SecondViewController

-(void) grabRSSFeed:(NSString *)feedAddress {
	
    // Initialize the feedEntries MutableArray that we declared in the header
    feedEntries = [[NSMutableArray alloc] init];	
	
    // Convert the supplied URL string into a usable URL object
    NSURL *url = [NSURL URLWithString: feedAddress];
	
    // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
    // object that actually grabs and processes the RSS data
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"//Event" error:nil];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		
        // Create a temporary MutableDictionary to store the items fields in, which will eventually end up in feedEntries
        NSMutableDictionary *feedItem = [[NSMutableDictionary alloc] init];
		
        // Create a counter variable as type "int"
        int counter;
		
        // Loop through the children of the current  node
        for(counter = 0; counter < [resultElement childCount]; counter++) {
			
            // Add each field to the feedItem Dictionary with the node name as key and node value as the value
            [feedItem setObject:[[resultElement childAtIndex:counter] stringValue] forKey:[[resultElement childAtIndex:counter] name]];
        }
		
        // Add the feedItem to the global feedEntries Array so that the view can access it.
        [feedEntries addObject:[feedItem copy]];
    }
}

- (void)awakeFromNib {
    list = [[NSMutableArray alloc] init];
    
	// Create the feed string
    NSString *feedAddress = @"http://whywontyoudie.com/work/KATGEvents.xml";
    // Call the grabRSSFeed function with the above
    // string as a parameter
    [self grabRSSFeed:feedAddress];
	
	//[feedEntries count]
	int feedEntryIndex = [feedEntries count];
	int counter = 0;
	
	NSString *eventType = nil;
	
	while ( counter < feedEntryIndex ) {
		
		NSString *feedDetails = [[feedEntries objectAtIndex: counter] objectForKey: @"Details"];
		NSString *Details = feedDetails;
		
		NSString *feedTimeString = [[feedEntries objectAtIndex: counter] objectForKey: @"Date"];
		
		BOOL match = ([feedDetails rangeOfString:@"Live Show" options:NSCaseInsensitiveSearch].location != NSNotFound);
		
		if (match) {
			eventType = @"show";
		} else {
			eventType = @"event";
		}
		
		Event *Ev = [[Event alloc] initWithTitle:Details publishDate:feedTimeString type:eventType];
		[list addObject:Ev];
		
		[Ev release];
		
		counter = counter + 1;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = ROW_HEIGHT;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}


// Customize the appearance of table view cells.
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}


- (void)dealloc {
    [list release];
    [super dealloc];
}


@end

