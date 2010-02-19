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

#define kFeedAddress @"http://app.keithandthegirl.com/Api/Feed/Show-List-Everything-Compact/"
//#define kFeedAddress @"http://getitdownonpaper.com/KATG/ShortList"
#define kXPath @"//S"

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
		_dataPath =
		[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
											  NSUserDomainMask, 
											  YES) lastObject] retain];
		_userDefaults = [NSUserDefaults standardUserDefaults];
		_shows = [[NSArray alloc] init];
    }
    return self;
}
- (void)stopShowsThread 
{
	[pollingPool drain]; pollingPool = nil;
	[pollingThread cancel];
	[pollingThread release]; pollingThread = nil;
}
- (void)dealloc 
{
	delegate = nil;
	[self stopShowsThread];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_dataPath release];
	[_shows release];
	[super dealloc];
}
#pragma mark -
#pragma mark Reachability
#pragma mark -
- (void)_reachabilityChanged:(NSNotification* )note
{
	Reachability *curReach = [note object];
	//NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
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
	NSString *path = [_dataPath stringByAppendingPathComponent:kShowsPlist];
	NSArray *shws = [NSArray arrayWithContentsOfFile:path];
	if (shws == nil && [shouldStream intValue] != 0) {
		shws = [NSArray arrayWithObject:[self _loadingDictionary]];
	} else if (shws == nil && [shouldStream intValue] == 0) {
		shws = [NSArray arrayWithObject:[self _noConnectionDictionary]];
	}
	if ([shouldStream intValue] != 0) {
		pollingThread = [[NSThread alloc] initWithTarget:self 
												selector:@selector(_pollShowsFeed) 
												  object:nil];
		[pollingThread start];
	}
	else
	{
		if ([(NSObject *)[self delegate] respondsToSelector:@selector(pastShowsModelDidFinish)])
		{
			[[self delegate] pastShowsModelDidFinish];
		}
	}
	return shws;
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
	return shws;
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
	if ([(NSObject *)[self delegate] respondsToSelector:@selector(pastShowsModelDidFinish)])
	{
		[[self delegate] pastShowsModelDidFinish];
	}
}
- (void)buildList:(NSMutableArray *)feedEntries 
{
	NSMutableArray *_showsProxy = [NSMutableArray arrayWithCapacity:[feedEntries count]];
	for (NSDictionary *feedEntry in feedEntries) {
		NSString *showNumber = [feedEntry objectForKey: @"N"];
		if (!showNumber) showNumber = @"";
		NSString *showTitle  = [feedEntry objectForKey: @"T"];
		if (!showTitle) showTitle = @"";
		NSString *showGuests = [feedEntry objectForKey: @"G"];
		if (!showGuests || [showGuests isEqualToString:@"NULL"]) showGuests = @"No Guests";
		NSString *showID = [feedEntry objectForKey: @"I"];
		if (!showID) showID = @"";
		NSString *showType = [feedEntry objectForKey:@"TV"];
		if (!showType) showType = @"0";
		NSString *showNotes = [feedEntry objectForKey:@"SN"];
		if (!showNotes) showNotes = @"0";
		NSString *showPics = [feedEntry objectForKey:@"P"];
		if (!showPics) showPics = @"0";
		NSString *showNumberTitle = [NSString stringWithFormat:@"%@ - %@", showNumber, showTitle];
		if (!showNumberTitle) showNumberTitle = @"";
		
		NSDictionary *show = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
																	showNumberTitle,
																	showTitle,
																	showNumber,
																	showGuests,
																	showID, 
																	showType,
																	showNotes, 
																	showPics, nil]
														   forKeys:[NSArray arrayWithObjects:
																	@"Show",
																	@"Title",
																	@"Number",
																	@"Guests",
																	@"ID", 
																	@"Type",
																	@"hasNotes", 
																	@"hasPics", nil]];
		[_showsProxy addObject:show];
		[show release];
	}
	if ([_showsProxy count] > [_shows count]) {
		[_shows release];
		_shows = [[NSArray alloc] initWithArray:_showsProxy];
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

@end
