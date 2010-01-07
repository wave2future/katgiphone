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
    if (self = [super init]) 
	{
		// Respond to changes in reachability
		[[NSNotificationCenter defaultCenter]
		 addObserver:self 
		 selector:@selector(_reachabilityChanged:) 
		 name:kReachabilityChangedNotification 
		 object:nil];
		// Defaults path for reading/writing data (documents directory)
		_dataPath =
		[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
											  NSUserDomainMask, 
											  YES) lastObject] retain];
		// 
		_picsProxyParser = [[NSMutableArray alloc] init];
		// 
		_picsProxyImages = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)_cancel
{
	if ([_pollingThread isExecuting]) 
	{
		[_pollingThread cancel];
	}
	if ([_imageThread isExecuting]) 
	{
		[_imageThread cancel];
	}
}
- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self _stopShowThread];
	[self _stopImageThread];
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
}
#pragma mark -
#pragma mark Pics
#pragma mark -
- (NSArray *)_getPics:(NSString *)ID
{
	// Store ID for later use (this is a clumsy way to do this
	_ID = [ID retain];
	// Path to Pics Plist with image data, title, description and URL
	NSString *path = 
	[_dataPath stringByAppendingPathComponent:
	 [NSString stringWithFormat:kPicsPlist, ID]];
	// Attempt to retrieve pic plist from disk
	NSArray *pics = [NSArray arrayWithContentsOfFile:path];
	// if pics does not exist on disk:
	if (!pics && [shouldStream intValue] != 0) 
	{
		// and user is connected
		// returning array with loading dictionary
		pics = [self _loadingArray];
		// then start thread to retrieve pics data
		_pollingThread = 
		[[NSThread alloc] initWithTarget:self 
								selector:@selector(_pollShowFeed:) 
								  object:ID];
		[_pollingThread start];
	} 
	else if (!pics && [shouldStream intValue] == 0) 
	{
		// and user is not connected
		// returning array with No Connection Dictionary
		pics = [self _noConnectionArray];
	}
	return [pics retain];
}
- (NSArray *)_loadingArray 
{
	NSURL *URL = 
	[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Loading"
														   ofType:@"png"]];
	NSData *imageData = 
	[NSData dataWithContentsOfURL:URL];
	NSDictionary *pic = 
	[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
										 [URL description],
										 @"Loading Images",
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
	NSURL *URL = 
	[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"NoConnection"
														   ofType:@"png"]];
	NSData *imageData = 
	[NSData dataWithContentsOfURL:URL];
	NSDictionary *pic = 
	[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
										 [URL description],
										 @"No Connection",
										 @"", 
										 imageData, nil]
								forKeys:[NSArray arrayWithObjects:
										 @"URL",
										 @"Title",
										 @"Description", 
										 @"Data", nil]];
	return [NSArray arrayWithObject:pic];
}
- (void)_pollShowFeed:(NSString *)ID 
{
	_pollingPool = [[NSAutoreleasePool alloc] init];
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
	if (![_pollingThread isCancelled]) [parser parse];
}
- (void)parsingDidCompleteForNode:(NSDictionary *)node parser:(GrabXMLFeed *)parser
{
	if ([_pollingThread isCancelled]) [parser cancel];
}
- (void)parsingDidCompleteSuccessfully:(GrabXMLFeed *)parser 
{
	if (![_pollingThread isCancelled])
	{
		NSMutableArray *feedEntries = [[parser feedEntries] copy];
		[parser release];
		[self _buildList:feedEntries];
		[feedEntries release];
		if (![_pollingThread isCancelled])
		{
			[self performSelectorOnMainThread:@selector(_downloadThumbs) 
								   withObject:nil 
								waitUntilDone:NO];
			[self _stopShowThread];
		}
	}
}
- (void)_buildList:(NSMutableArray *)feedEntries 
{
	if (_picsProxyParser.count != 0) 
	{
		[_picsProxyParser removeAllObjects];
	}
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Loading" 
													 ofType:@"png"];
	NSData *imageData = [[NSData alloc] initWithContentsOfFile:path]; 
	NSDictionary *pic;
	for (NSDictionary *feedEntry in feedEntries) 
	{
		NSString *picURL = [feedEntry objectForKey: @"url"];
		NSString *picTitle  = [feedEntry objectForKey: @"title"];
		NSString *picDescription = [feedEntry objectForKey: @"description"];
		if ([picTitle isEqualToString:@"NULL"]) picTitle = @"";
		if ([picDescription isEqualToString:@"NULL"]) picDescription = @"";
		pic = 
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
		[pic release]; pic = nil;
	}
	[imageData release]; imageData = nil;
	if ([_picsProxyParser count] > [_pics count]) 
	{
		[_pics release];
		_pics = (NSArray *)[_picsProxyParser copy];
		[[self delegate] pastShowPicsDataModelDidChange:_pics];
		[_picsProxyParser removeAllObjects];
	}
}
- (void)_writePicsToFile:(NSString *)ID 
{
	if ([NSThread isMainThread]) 
	{
		NSString *path = 
		[_dataPath stringByAppendingPathComponent:
		 [NSString stringWithFormat:kPicsPlist, ID]];
		[_pics writeToFile:path atomically:YES];
	} 
	else 
	{
		[self performSelectorOnMainThread:@selector(_writePicsToFile:)
							   withObject:ID 
							waitUntilDone:NO];
	}	
}
- (void)_stopShowThread 
{
	[_pollingPool drain]; _pollingPool = nil;
	[_pollingThread cancel];
	[_pollingThread release]; _pollingThread = nil;
}

@end
