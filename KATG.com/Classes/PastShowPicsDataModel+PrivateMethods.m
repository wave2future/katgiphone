//
//  PastShowPicsDataModel+PrivateMethods.m
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

#import "PastShowPicsDataModel+PrivateMethods.h"
#import "Reachability.h"
#import "GrabXMLFeed.h"

#define kFeedAddress @"http://app.keithandthegirl.com/Api/Feed/Pictures-By-Show/?ShowId=%@"
#define kXPath @"//picture"

@implementation PastShowPicsDataModel (PrivateMethods)
#pragma mark -
#pragma mark Setup/Cleanup
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
		_userDefaults = [NSUserDefaults standardUserDefaults];
		_picsProxyParser = [[NSMutableArray alloc] init];
		_picsProxyImages = [[NSMutableArray alloc] init];
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
	[_pics release];
	[_picsProxyParser release];
	[_picsProxyImages release];
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
#pragma mark Pics
#pragma mark -
- (NSArray *)_getPics:(NSString *)ID
{
	NSString *path = 
	[_dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"pics_%@.plist", ID]];
	NSArray *pics = [NSArray arrayWithContentsOfFile:path];
	if (pics == nil && [shouldStream intValue] != 0) {
		pics = [self _loadingArray];
	} else if (pics == nil && [shouldStream intValue] == 0) {
		pics = [self _noConnectionArray];
	}
	if (shouldStream != 0) {
		pollingThread = [[NSThread alloc] initWithTarget:self selector:@selector(_pollShowFeed:) object:ID];
		[pollingThread start];
	}
	return [pics retain];
}
- (NSArray *)_loadingArray 
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Loading" 
													 ofType:@"png"];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	NSDictionary *pic = 
	[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
										 @"",
										 @"",
										 @"", 
										 imageData, nil]
								forKeys:[NSArray arrayWithObjects:
										 @"URL",
										 @"Title",
										 @"Description", 
										 @"Data", nil]];
	return [NSArray arrayWithObject:pic];
}
- (NSArray *)_noConnectionArray 
{
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"NoConnection.png"];
	return [NSArray arrayWithObject:[UIImage imageWithContentsOfFile:path]];
}
- (void)_pollShowFeed:(NSString *)ID 
{
	pollingPool = [[NSAutoreleasePool alloc] init];
	NSString *feedAddress = [NSString stringWithFormat:kFeedAddress, ID];
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
	[self performSelectorOnMainThread:@selector(downloadThumbs) 
						   withObject:nil 
						waitUntilDone:NO];
	[self stopShowsThread];
}
- (void)buildList:(NSMutableArray *)feedEntries 
{
	if (_picsProxyParser.count != 0) {
		[_picsProxyParser removeAllObjects];
	}
	for (NSDictionary *feedEntry in feedEntries) {
		NSString *picURL = [feedEntry objectForKey: @"url"];
		NSString *picTitle  = [feedEntry objectForKey: @"title"];
		NSString *picDescription = [feedEntry objectForKey: @"description"];
		if ([picTitle isEqualToString:@"NULL"]) { picTitle = @""; }
		if ([picDescription isEqualToString:@"NULL"]) { picDescription = @""; }
		NSString *path = [[NSBundle mainBundle] pathForResource:@"Loading" 
														 ofType:@"png"];
		NSData *imageData = [NSData dataWithContentsOfFile:path];
		
		NSDictionary *pic = 
		[[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
											   picURL,
											   picTitle,
											   picDescription, 
											   imageData, nil]
									  forKeys:[NSArray arrayWithObjects:
											   @"URL",
											   @"Title",
											   @"Description", 
											   @"Data", nil]];
		[_picsProxyParser addObject:pic];
		[pic release];
	}
	if ([_picsProxyParser count] > [_pics count]) {
		[_pics release];
		_pics = (NSArray *)[_picsProxyParser copy];
		[[self delegate] pastShowPicsDataModelDidChange:_pics];	
		//[self performSelectorOnMainThread:@selector(writeShowsToFile) withObject:nil waitUntilDone:NO];
		[_picsProxyParser removeAllObjects];
	}
}
- (void)writeShowsToFile 
{
	//NSString *path = [_dataPath stringByAppendingPathComponent:@"shows.plist"];
	//[_pics writeToFile:path atomically:YES];
}
- (void)downloadThumbs
{
	if (_picsProxyImages.count != 0) 
	{
		[_picsProxyImages removeAllObjects];
	}
	[_picsProxyImages addObjectsFromArray:_pics];
	
	for (int n = 0; n < [_picsProxyImages count]; n++)
	{
		NSDictionary *pic = 
		[_picsProxyImages objectAtIndex:n];
		NSError *error;
		NSData *data = 
		[NSData dataWithContentsOfURL:
		 [NSURL URLWithString:[pic objectForKey:@"URL"]] 
							  options:NSUncachedRead 
								error:&error];
		if (data)
		{
			NSDictionary *dictionary = 
			[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
												 [pic objectForKey:@"URL"],
												 [pic objectForKey:@"Title"],
												 [pic objectForKey:@"Description"], 
												 data, nil]
										forKeys:[NSArray arrayWithObjects:
												 @"URL",
												 @"Title",
												 @"Description", 
												 @"Data", nil]];
			[_picsProxyImages replaceObjectAtIndex:n withObject:dictionary];
			[_pics release];
			_pics = (NSArray *)[_picsProxyImages copy];
			[[self delegate] pastShowPicsDataModelDidChange:_pics];	
			
		} 
		else 
		{
			// Handle error;
			NSLog([error description]);
		}
	}
	
	NSLog(@"");
}
- (void)stopShowsThread 
{
	[pollingPool release];
	pollingPool = nil;
	[pollingThread cancel];
	[pollingThread release];
	pollingThread = nil;
}
@end
