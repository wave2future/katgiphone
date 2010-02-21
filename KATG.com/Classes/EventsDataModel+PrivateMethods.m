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
		
		_formatter = [[NSDateFormatter alloc] init];
		[_formatter setDateStyle: NSDateFormatterLongStyle];
		[_formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[_formatter setDateFormat: @"MM/dd/yyyy HH:mm zzz"];
		NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"US"];
		[_formatter setLocale:us];
		[us release];
		
		_dayFormatter = [[NSDateFormatter alloc] init];
		[_dayFormatter setDateStyle: NSDateFormatterLongStyle];
		[_dayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[_dayFormatter setDateFormat: @"EEE"];
		[_dayFormatter setLocale:[NSLocale currentLocale]];
		
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateStyle: NSDateFormatterLongStyle];
		[_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[_dateFormatter setDateFormat: @"MM/dd"];
		[_dateFormatter setLocale:[NSLocale currentLocale]];
		
		_timeFormatter = [[NSDateFormatter alloc] init];
		[_timeFormatter setDateStyle: NSDateFormatterLongStyle];
		[_timeFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[_timeFormatter setDateFormat: @"h:mm aa"];
		[_timeFormatter setLocale:[NSLocale currentLocale]];
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
- (void)_cleanup
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_eventQueue cancelAllOperations];
	[_eventQueue release]; _eventQueue = nil;
	[_formatter release]; _formatter = nil;
	[_dayFormatter release]; _dayFormatter = nil;
	[_dateFormatter release]; _dateFormatter = nil;
	[_timeFormatter release]; _timeFormatter = nil;
	[_pollingPool drain]; _pollingPool = nil;
}
- (void)dealloc 
{
	[self _cleanup];
	[_dataPath release];
	[_events release];
	[_eventsProxy release];
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
	// Attempt to load events array from disk
	NSString *path = [_dataPath stringByAppendingPathComponent:kEventsPlist];
	NSArray *evnts = [NSArray arrayWithContentsOfFile:path];
	return evnts;
}
- (NSDictionary *)_loadingDictionary 
{ // dictionary to inform user event data is being loaded
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
