//
//  PastShowsDataModel+PrivateMethods.m
//  KATG.com
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

#import "PastShowsDataModel+PrivateMethods.h"
#import "Reachability.h"
#import "GrabXMLFeed.h"

@implementation PastShowsDataModel (PrivateMethods)

#pragma mark -
#pragma mark Setup
#pragma mark -
- (id)init 
{
    if (self = [super init]) 
	{
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
		_userDefaults = [NSUserDefaults standardUserDefaults];
		_showsProxy = [[NSMutableArray alloc] init];
		_shows = [[NSArray alloc] init];
    }
    return self;
}
- (void)_attemptRelease 
{
	[super release];
}
- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if ([pollingThread isExecuting]) {
		[self stopShowsThread];
	}
	delegate = nil;
	[_dataPath release];
	[_shows release];
	[_showsProxy release];
	[super dealloc];
}
#pragma mark -
#pragma mark Reachability
#pragma mark -
- (void)_reachabilityChanged:(NSNotification* )note
{
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self _updateReachability:curReach];
}
- (void)_updateReachability:(Reachability*)curReach
{
	BOOL streamPref = [_userDefaults boolForKey:@"StreamPSOverCell"];
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus) {
		case NotReachable:
		{
			shouldStream = [NSNumber numberWithInt:0];
			break;
		}
		case ReachableViaWWAN:
		{
			if (streamPref) {
				shouldStream = [NSNumber numberWithInt:2];
			} else {
				shouldStream = [NSNumber numberWithInt:1];
			}
			break;
		}
		case ReachableViaWiFi:
		{
			shouldStream = [NSNumber numberWithInt:3];
			break;
		}
	}
}
#pragma mark -
#pragma mark Shows
#pragma mark -
- (NSArray *)_getShows 
{
	NSString *path = [_dataPath stringByAppendingPathComponent:@"shows.plist"];
	NSArray *shws = [NSArray arrayWithContentsOfFile:path];
	if (shws == nil && [shouldStream intValue] != 0) {
		shws = [NSArray arrayWithObject:[self _loadingDictionary]];
	} else if (shws == nil && [shouldStream intValue] == 0) {
		shws = [NSArray arrayWithObject:[self _noConnectionDictionary]];
	}
	if (shouldStream != 0) {
		pollingThread = [[NSThread alloc] initWithTarget:self 
												selector:@selector(_pollShowsFeed) 
												  object:nil];
		[pollingThread start];
	}
	return [shws retain];
}
- (NSArray *)_getShowsFromDisk
{
	NSString *path = [_dataPath stringByAppendingPathComponent:@"shows.plist"];
	NSArray *shws = [NSArray arrayWithContentsOfFile:path];
	if (shws == nil && [shouldStream intValue] != 0) {
		shws = [NSArray arrayWithObject:[self _loadingDictionary]];
	} else if (shws == nil && [shouldStream intValue] == 0) {
		shws = [NSArray arrayWithObject:[self _noConnectionDictionary]];
	}
	return [shws retain];
}
- (NSDictionary *)_loadingDictionary 
{
	NSDictionary *show = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
															  @"Loading Episode List",
															  @"",
															  @"",
															  @"",
															  @"", nil]
													 forKeys:[NSArray arrayWithObjects:
															  @"Show",
															  @"Title",
															  @"Number",
															  @"Guests",
															  @"ID", nil]];
	return show;
}
- (NSDictionary *)_noConnectionDictionary 
{
	NSDictionary *show = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
															  @"No Internet Connection",
															  @"",
															  @"",
															  @"",
															  @"", nil]
													 forKeys:[NSArray arrayWithObjects:
															  @"Show",
															  @"Title",
															  @"Number",
															  @"Guests",
															  @"ID", nil]];
	return show;
}
- (void)_pollShowsFeed 
{
	pollingPool = [[NSAutoreleasePool alloc] init];
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
- (void)parsingDidCompleteSuccessfully:(GrabXMLFeed *)parser 
{	
	NSMutableArray *feedEntries = [[parser feedEntries] copy];
	[self buildList:feedEntries];
	[feedEntries release];
	[parser release];
	[self stopShowsThread];
}
- (void)buildList:(NSMutableArray *)feedEntries 
{
	if (_showsProxy.count != 0) {
		[_showsProxy removeAllObjects];
	}
	for (NSDictionary *feedEntry in feedEntries) {
		NSString *showNumber = [feedEntry objectForKey: @"N"];
		NSString *showTitle  = [feedEntry objectForKey: @"T"];
		NSString *showGuests = [feedEntry objectForKey: @"G"];
		if ([showGuests isEqualToString:@"NULL"]) { showGuests = @"No Guests"; }
		NSString *showID	 = [feedEntry objectForKey: @"I"];
		
		NSString *showNumberTitle = [NSString stringWithFormat:@"%@ - %@", showNumber, showTitle];
		
		NSDictionary *show = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
																	showNumberTitle,
																	showTitle,
																	showNumber,
																	showGuests,
																	showID, nil]
														   forKeys:[NSArray arrayWithObjects:
																	@"Show",
																	@"Title",
																	@"Number",
																	@"Guests",
																	@"ID", nil]];
		[_showsProxy addObject:show];
		[show release];
	}
	if ([_showsProxy count] > [_shows count]) {
		[_shows release];
		_shows = (NSArray *)[_showsProxy copy];
		[[self delegate] pastShowsDataModelDidChange:_shows];	
		[self performSelectorOnMainThread:@selector(writeShowsToFile) withObject:nil waitUntilDone:NO];
		[_showsProxy removeAllObjects];
	}
}
- (void)writeShowsToFile 
{
	NSString *path = [_dataPath stringByAppendingPathComponent:@"shows.plist"];
	[_shows writeToFile:path atomically:YES];
}
- (void)stopShowsThread 
{
	[pollingPool drain];
	[pollingThread cancel];
	[pollingThread release];
	pollingThread = nil;
}

@end
