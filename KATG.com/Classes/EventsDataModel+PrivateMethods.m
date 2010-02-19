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

#define kFeedAddress @"http://www.keithandthegirl.com/feed/event/"
#define kXPath @"//Event"

#import "EventsDataModel+PrivateMethods.h"
#import "Reachability.h"
#import "GrabXMLFeed.h"
#import "EventOperation.h"

@implementation EventsDataModel (PrivateMethods)

#pragma mark -
#pragma mark Setup/Cleanup
#pragma mark -
- (id)init 
{
    if (self = [super init]) 
	{
		[self _registerNotifications];
		_dataPath =
		[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
											  NSUserDomainMask, 
											  YES) lastObject] retain];
		[self _setupEventQueue];
		
    }
    return self;
}
- (void)_registerNotifications
{
	// Respond to changes in reachability
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(_reachabilityChanged:) 
	 name:kReachabilityChangedNotification 
	 object:nil];
	// When app is closed attempt to release object
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(_attemptRelease) 
	 name:UIApplicationWillTerminateNotification 
	 object:nil];
}
-(void)_setupEventQueue 
{ // set up operations queue for processing events after parsing
	_eventQueue = [[NSOperationQueue alloc] init];
	[_eventQueue setMaxConcurrentOperationCount:[[NSProcessInfo processInfo] activeProcessorCount] + 1];
	_eventsProxy = [[NSMutableArray alloc] init];
}
- (void)_attemptRelease 
{ // call super class (NSObject *) release because this is a singleton
	[super release];
}
- (void)dealloc 
{ // Cleanup
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_eventQueue cancelAllOperations];
	[_eventQueue release]; _eventQueue = nil;
	[_dataPath release];
	[_events release];
	[_eventsProxy release];
	[_pollingPool drain]; _pollingPool = nil;
	[super dealloc];
}
#pragma mark -
#pragma mark Shows
#pragma mark -
- (NSArray *)_getEvents 
{ // load events array
	// Try to load events array from disk
	NSString *path = [_dataPath stringByAppendingPathComponent:kEventsPlist];
	NSArray *evnts = [[NSArray alloc] initWithContentsOfFile:path];
	// If events array fails to load from disc and a connection is available
	if (!evnts && [shouldStream intValue] != 0 && shouldStream != nil) 
	{ 	// set events to loading dictionary
		evnts = [NSArray arrayWithObject:[self _loadingDictionary]];
	} // If events array fails to load from disc and a connection isn't available
	else if (!evnts && ([shouldStream intValue] == 0 || shouldStream == nil)) 
	{ // set events to no connection dictionary
		evnts = [NSArray arrayWithObject:[self _noConnectionDictionary]];
	}
	// if a connection is available
	if ([shouldStream intValue] != 0) 
	{ // if not already polling or waiting for a connection
		if (!_polling && !_pollOnConnection) 
		{ // start thread to get events from server
			[NSThread detachNewThreadSelector:@selector(_pollEventsFeed) 
									 toTarget:self 
								   withObject:nil];
		}
		// this should probably be in the braces with the thread,
		// don't remember why it's heres
		_polling = YES;
	} 
	else 
	{ // if connection is not available
		_pollOnConnection = YES;
	}
	return evnts;
}
- (NSArray *)_getEventsFromDisk 
{
	NSString *path = [_dataPath stringByAppendingPathComponent:kEventsPlist];
	NSArray *evnts = [NSArray arrayWithContentsOfFile:path];
	if (!evnts) {
		evnts = [self _getEvents];
	}
	return evnts;
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
	_pollingPool = [[NSAutoreleasePool alloc] init];
	NSString *feedAddress = kFeedAddress;
	// Select the xPath to parse against
	NSString *xPath = kXPath;
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

@end
