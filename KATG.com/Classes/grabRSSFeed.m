//
//  grabRSSFeed.m
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

#import "grabRSSFeed.h"
#import "TouchXML.h"

@implementation grabRSSFeed


// Creates the object with primary key and title is brought into memory.
- (id)initWithFeed:(NSString *)feedAddress XPath:(NSString *)xPath {
	
	// Initialize the feedEntries MutableArray that we declared in the header
    feedEntries = [[NSMutableArray alloc] init];
	
    // Convert the supplied URL string into a usable URL object
    NSURL *url = [NSURL URLWithString: feedAddress];
	
	// Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
	// object that actually grabs and processes the RSS data
	
	CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
	//CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithData:receivedData options:0 error:nil] autorelease];

	
	// Create a new Array object to be used with the looping of the results from the rssParser
	NSArray *resultNodes = NULL;
	
	// Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed	
	resultNodes = [rssParser nodesForXPath:xPath error:nil];
	
	// Loop through the resultNodes to access each items actual data
	for (CXMLElement *resultElement in resultNodes) {
		
		// Create a temporary MutableDictionary to store the items fields in, which will eventually end up in feedEntries
		NSMutableDictionary *feedItem = [[NSMutableDictionary alloc] init];
		
		// Create a counter variable as type "int"
		int counter;
		
		// Loop through the children of the current  node
		for(counter = 0; counter < [resultElement childCount]; counter++) {
			
			NSString *strVal = [[resultElement childAtIndex:counter] stringValue];
			
			if (strVal == nil) {
				strVal = @"NULL";
			}
			
			// Add each field to the feedItem Dictionary with the node name as key and node value as the value
			[feedItem setObject:strVal forKey:[[resultElement childAtIndex:counter] name]];
	}
	
	// Add the feedItem to the global feedEntries Array so that the view can access it.
	[feedEntries addObject:[feedItem copy]];
	}
	
	return self;

}

- (id)entries {
	return feedEntries;
}

@end