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

#import "OnAirViewController+FeedStatus.h"

@implementation OnAirViewController (FeedStatus)

- (void)pollStatusFeed 
{
	// Create the feed string
	NSString *feedAddress = @"http://www.keithandthegirl.com/feed/show/live";
	// Select the xPath to parse against
	NSString *xPath = @"//root";
	// Instantiate GrabXMLFeed
	GrabXMLFeed *parser = 
	[[GrabXMLFeed alloc] initWithFeed:feedAddress xPath:xPath];
	// Set parser delegate
	[parser setDelegate:self];
	// Set instance number
	[parser setInstanceNumber:1];
	// Start parser
	[parser parse];
}

- (void)setLiveShowStatusLabelText:(NSString *)text 
{
	if ([NSThread isMainThread]) {
		[liveShowStatusLabel setText:text];
	} else {
		[self performSelectorOnMainThread:@selector(setLiveShowStatusLabelText:) 
							   withObject:text 
							waitUntilDone:NO];
	}
}

@end
