//
//  OnAirViewController+NextShowTime.m
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

#import "OnAirViewController+NextShowTime.h"

@implementation OnAirViewController (NextShowTime)

// setup events data model singleton
- (void)getEventsData 
{
	timeSince = NSIntegerMax; // used to calculate time til next show
	//respond to changes in event data
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(eventsDataModelDidChangeNotification:)
	 name:@"EventsModelDidChange" 
	 object:nil];
	// Events data model singleton with initial connection status,
	// using notification instead of delegation because OnAir
	// and Events controllers will both want to know about changes
	EventsDataModel *model = [EventsDataModel sharedEventsDataModel];
	[model setShouldStream:shouldStream];
	[model startNotifier];
	[[model events] autorelease];
}

- (void)eventsDataModelDidChangeNotification:(NSNotification *)notification 
{
	NSArray *events = [notification object];
	for (NSDictionary *event in events) {
		if ([[event objectForKey:@"ShowType"] boolValue]) 
		{
			NSDate *time = [event objectForKey:@"DateTime"];
			NSInteger since = [time timeIntervalSinceNow];
			if (since < timeSince && since > 0)
			{
				timeSince = [time timeIntervalSinceNow];
				NSInteger d = timeSince / 86400;
				NSInteger h = timeSince / 3600 - d * 24;
				NSInteger m = timeSince / 60 - d * 1440 - h * 60;
				[self setNextLiveShowCountdownLabelText:
				 [NSString stringWithFormat:@"%02d : %02d : %02d", d, h , m]];
			}
		}
	}
}

- (void)updateNextShowCountdown 
{
	timeSince -= 60;
	NSInteger d = timeSince / 86400;
	NSInteger h = timeSince / 3600 - d * 24;
	NSInteger m = timeSince / 60 - d * 1440 - h * 60;
	[self setNextLiveShowCountdownLabelText:
	 [NSString stringWithFormat:@"%02d : %02d : %02d", d, h , m]];
}

- (void)setNextLiveShowCountdownLabelText:(NSString *)text
{
	if ([NSThread isMainThread]) 
	{
		[nextLiveShowCountdownLabel setText:text];
	} 
	else 
	{
		[self performSelectorOnMainThread:@selector(setNextLiveShowCountdownLabelText:) 
							   withObject:text 
							waitUntilDone:NO];
	}
}

@end
