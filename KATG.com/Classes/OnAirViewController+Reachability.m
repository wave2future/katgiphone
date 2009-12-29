//
//  OnAirViewController+Reachability.m
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

#import "OnAirViewController+Reachability.h"
#import "Reachability.h"

@implementation OnAirViewController (Reachability)

- (void)setupReachability
{
	shouldStream = [delegate shouldStream];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reachabilityChanged:) 
												 name:kReachabilityChangedNotification 
											   object:nil];
}

- (void)reachabilityChanged:(NSNotification* )note
{
	if (streamer) {
		[audioButton.layer removeAllAnimations];
		[streamer stop];
	}
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateReachability:curReach];
}

- (void)updateReachability:(Reachability*)curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus) {
		case NotReachable:
		{
			shouldStream = [NSNumber numberWithInt:0];
			break;
		}
		case ReachableViaWWAN:
		{
			shouldStream = [NSNumber numberWithInt:2];
			break;
		}
		case ReachableViaWiFi:
		{
			shouldStream = [NSNumber numberWithInt:3];
			break;
		}
	}
	if (shouldStream > 0) {
		if (playOnConnection) {
			[self audioButtonPressed:self];
			playOnConnection = NO;
		}
	}
}

@end
