//
//  OnAirViewController+FeedStatus.m
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

#define kFeedAddress @"http://www.keithandthegirl.com/feed/show/live"
#define kXPath @"//root"

#import "OnAirViewController+FeedStatus.h"

@implementation OnAirViewController (FeedStatus)

// Launch thread to check shoutcast feed status
- (void)pollStatusFeed 
{
	[NSThread detachNewThreadSelector:@selector(pollStatusFeedThread) 
							 toTarget:self 
						   withObject:nil];
}
// Setup parser for shout cast feed status
- (void)pollStatusFeedThread
{
	feedPool = 
	[[NSAutoreleasePool alloc] init];
	// Create the feed URL string
	NSString *feedAddress = kFeedAddress;
	// Select the xPath to parse against
	NSString *xPath = kXPath;
	// Instantiate GrabXMLFeed
	GrabXMLFeed *parser = 
	[[GrabXMLFeed alloc] initWithFeed:feedAddress xPath:xPath];
	// Set parser delegate
	[parser setDelegate:self];
	// Set instance number, 
	// used by delegate methods to discern parser instances, not necessary here
	//[parser setInstanceNumber:1];
	// Start parser
	[parser parse];
}
// Parser delegate when document is fully parsed
- (void)parsingDidCompleteSuccessfully:(GrabXMLFeed *)parser 
{
	// cast feedEntries into an immutable array
	NSArray *feedEntries = (NSArray *)[[parser feedEntries] copy];
	int feedEntryIndex = 0;
	NSString *feedStatusString;
	NSString *feedStatus = nil;
	if ([feedEntries count] > 0) // Make sure feedEntries isn't empty 
	{
		// Feedentries is an array of dictionaries
		// the dictionary keys are the xml node values
		feedStatusString = 
		[[feedEntries objectAtIndex:feedEntryIndex] objectForKey: @"OnAir"];
		int feedStatusInt = [feedStatusString intValue];
		switch (feedStatusInt) {
			case 0:
				feedStatus = @"Not Live";
				break;
			case 1:
				feedStatus = @"Live";
				break;
			default:
				feedStatus = @"Unknown";
				break;
		}
		// Set live show status label on main thread (UIKit is not threadsafe)
		[self performSelectorOnMainThread:@selector(setLiveShowStatusLabelText:)
							   withObject:feedStatus 
							waitUntilDone:NO];
	}
	// Release parser and drain threads autorelease pool
	[parser release];
	[feedPool drain];
}
// Set live show status label
- (void)setLiveShowStatusLabelText:(NSString *)text 
{
	if ([NSThread isMainThread]) // (UIKit is not threadsafe)
	{
		[liveShowStatusLabel setText:text];
	} 
	else // if not on main thread place message on runloop for main thread
	{
		[self performSelectorOnMainThread:@selector(setLiveShowStatusLabelText:) 
							   withObject:text 
							waitUntilDone:NO];
	}
}

@end
