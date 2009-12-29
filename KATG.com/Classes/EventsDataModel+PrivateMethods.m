//
//  EventsDataModel+PrivateMethods.m
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

#import "EventsDataModel+PrivateMethods.h"
#import "Reachability.h"
#import "GrabXMLFeed.h"
#import "EventOperation.h"

@implementation EventsDataModel (PrivateMethods)

#pragma mark -
#pragma mark Setup
#pragma mark -

- (id)init 
{
    if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(_reachabilityChanged:) 
													 name:kReachabilityChangedNotification 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(_attemptRelease) 
													 name:UIApplicationWillTerminateNotification 
												   object:nil];
		_dataPath =
		[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
											  NSUserDomainMask, 
											  YES) lastObject] retain];
		[self _setupEventQueue];
    }
    return self;
}

-(void)_setupEventQueue 
{
	_eventQueue = [[NSOperationQueue alloc] init];
	[_eventQueue setMaxConcurrentOperationCount:[[NSProcessInfo processInfo] activeProcessorCount] + 1];
	_eventsProxy = [[NSMutableArray alloc] init];
}

#pragma mark -
#pragma mark Shows
#pragma mark -
- (NSArray *)_getEvents 
{
	NSString *path = [_dataPath stringByAppendingPathComponent:EVENTSPLIST];
	NSArray *evnts = [NSArray arrayWithContentsOfFile:path];
	if (evnts == nil && [shouldStream intValue] != 0 && shouldStream != nil) {
		evnts = [NSArray arrayWithObject:[self _loadingDictionary]];
	} else if (evnts == nil && ([shouldStream intValue] == 0 || shouldStream == nil)) {
		evnts = [NSArray arrayWithObject:[self _noConnectionDictionary]];
	}
	if (shouldStream != 0) {
		[self performSelectorOnMainThread:@selector(_pollEventsFeed) 
							   withObject:nil 
							waitUntilDone:NO];
	} else {
		_pollOnConnection = YES;
	}
	return [evnts retain];
}

- (NSArray *)_getEventsFromDisk 
{
	NSString *path = [_dataPath stringByAppendingPathComponent:EVENTSPLIST];
	NSArray *evnts = [NSArray arrayWithContentsOfFile:path];
	if (evnts == nil) {
		evnts = [self _getEvents];
	}
	return [evnts retain];
}

- (NSDictionary *)_loadingDictionary 
{
	NSDictionary *event;
	event = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
												 @"Loading Events",
												 @"",
												 @"",
												 [NSDate date],
												 @"",
												 @"",
												 @"", 
												 @"", nil]
										forKeys:[NSArray arrayWithObjects:
												 @"Title",
												 @"EventId",
												 @"Details",
												 @"DateTime",
												 @"Day",
												 @"Date",
												 @"Time", 
												 @"", nil]];
	return event;
}

- (NSDictionary *)_noConnectionDictionary 
{
	NSDictionary *event;
	event = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
												 @"No Internet Connection",
												 @"",
												 @"",
												 [NSDate date],
												 @"",
												 @"",
												 @"", 
												 @"", nil]
										forKeys:[NSArray arrayWithObjects:
												 @"Title",
												 @"EventId",
												 @"Details",
												 @"DateTime",
												 @"Day",
												 @"Date",
												 @"Time", 
												 @"ShowType", nil]];
	return event;
}

- (void)_pollEventsFeed 
{
	NSString *feedAddress = FEEDADDRESS;
	// Select the xPath to parse against
	NSString *xPath = XPATH;
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

#pragma mark -
#pragma mark Cleanup
#pragma mark -

- (void)_attemptRelease 
{
	[self release];
	self = nil;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_eventQueue cancelAllOperations];
	[_eventQueue release];
	_eventQueue = nil;
	[_dataPath release];
	[_events release];
	[_eventsProxy release];
	[super dealloc];
}

@end
