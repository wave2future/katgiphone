//
//  OnAirViewController+ParserDelegate.m
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

#import "OnAirViewController+ParserDelegate.h"

@implementation OnAirViewController (ParserDelegate) 

- (void)parsingDidCompleteSuccessfully:(GrabXMLFeed *)parser 
{
	NSMutableArray *feedEntries = [NSMutableArray arrayWithArray:[parser feedEntries]];
	int feedEntryIndex = 0;
	NSString *feedStatusString;
	NSString *feedStatus = nil;
	if ([feedEntries count] > 0) {
		feedStatusString = [[feedEntries objectAtIndex: feedEntryIndex] objectForKey: @"OnAir"];
		int feedStatusInt = [feedStatusString intValue];
		feedStatusString = nil;
		if(feedStatusInt == 0) {
			feedStatus = @"Not Live";
		} else if(feedStatusInt == 1) {
			feedStatus = @"Live";
		} else {
			feedStatus = @"Unknown";
		}
		[self performSelectorOnMainThread:@selector(setLiveShowStatusLabelText:) 
							   withObject:feedStatus 
							waitUntilDone:NO];
	} else {
		return;
	}
}

- (void)timer 
{
	[NSTimer scheduledTimerWithTimeInterval:60.0 
									 target:self 
								   selector:@selector(updateNextShowCountdown)  
								   userInfo:nil 
									repeats:YES];
}

@end
