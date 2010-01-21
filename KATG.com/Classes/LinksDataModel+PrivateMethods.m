//
//  LinksDataModel+PrivateMethods.m
//  KATG.com
//
//  Created by Doug Russell on 1/20/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#define kFeedAddress @"http://keithandthegirl.com/API/App/Links.xml"
#define kXPath @"//Button"
#define kLinksPlist @"links.plist"

#import "LinksDataModel+PrivateMethods.h"
#import "Reachability.h"
#import "GrabXMLFeed.h"

@implementation LinksDataModel (PrivateMethods)

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
		_dataPath =
		[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
											  NSUserDomainMask, 
											  YES) lastObject] retain];
    }
    return self;
}
- (void)_cancel 
{
	if([_thread isExecuting])
	{
		[_thread cancel];
	}
}
- (void)_stopPollingThread 
{
	[_pool drain]; _pool = nil;
	[_thread cancel];
	[_thread release]; _thread = nil;
}
- (void)dealloc 
{
	delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self _stopPollingThread];
	[_dataPath release];
	[super dealloc];
}
- (void)_getLinks
{
	NSString *path = [_dataPath stringByAppendingPathComponent:kLinksPlist];
	NSArray *lnk = [NSArray arrayWithContentsOfFile:path];
	if (!lnk && [shouldStream intValue] != 0) 
	{
		lnk = [NSArray arrayWithObject:[self _loadingDictionary]];
	} 
	else if (!lnk && [shouldStream intValue] == 0) 
	{
		lnk = [NSArray arrayWithObject:[self _noConnectionDictionary]];
	}
	if ([shouldStream intValue] != 0) 
	{
		_thread = 
		[[NSThread alloc] initWithTarget:self 
								selector:@selector(_pollFeed) 
								  object:nil];
		[_thread start];
	}
	return [lnk retain];
}
- (NSDictionary *)_loadingDictionary 
{
	NSMutableDictionary *link = [NSMutableDictionary dictionary];
	if (link)
	{
		[link setObject:[NSNumber numberWithBool:YES] forKey:@"inApp"];
		[link setObject:@"Loading Buttons" forKey:@"title"];
		[link setObject:@"http://katg.com" forKey:@"url"];
	}
	return link;
}
- (NSDictionary *)_noConnectionDictionary 
{
	NSMutableDictionary *link = [NSMutableDictionary dictionary];
	if (link)
	{
		[link setObject:[NSNumber numberWithBool:YES] forKey:@"inApp"];
		[link setObject:@"Buttons Not Available" forKey:@"title"];
		[link setObject:@"http://katg.com" forKey:@"url"];
	}
	return link;
}
- (void)_pollFeed
{
	_pool = [[NSAutoreleasePool alloc] init];
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
	if (![_thread isCancelled])
	{
		NSMutableArray *feedEntries = [[parser feedEntries] copy];
		[self _buildLinks:feedEntries];
		[feedEntries release];
		[parser release];
	}
	[self _stopPollingThread];
}
- (void)_buildLinks:(NSMutableArray *)feedEntries 
{
	NSMutableArray *linksProxy = [[NSMutableArray alloc] init];
	if (linksProxy) 
	{
		for (NSDictionary *entry in feedEntries)
		{
			NSMutableDictionary *link = [[NSMutableDictionary alloc] init];
			if (link)
			{
				[link setObject:[NSNumber numberWithBool:[[entry objectForKey:@"InApp"] boolValue]]
						 forKey:@"inApp"];
				[link setObject:[entry objectForKey:@"Title"] forKey:@"title"];
				[link setObject:[entry objectForKey:@"URL"] forKey:@"url"];
				[linksProxy addObject:link];
				[link release];
			}
		}
	}
	[_links release]; _links = nil;
	_links = [[NSArray alloc] initWithArray:linksProxy];
	[linksProxy release];
	[[self delegate] linksDataModelDidChange:_links];
	[self _writeLinksToFile];
}
- (void)_writeLinksToFile
{
	if (![NSThread isMainThread]) {
		NSString *path = 
		[_dataPath stringByAppendingPathComponent:kLinksPlist];
		[_links writeToFile:path atomically:YES];
	} else {
		[self performSelectorOnMainThread:@selector(_writeLinksToFile)
							   withObject:nil 
							waitUntilDone:NO];
	}
}
- (void)_reachabilityChanged:(NSNotification* )note
{
	Reachability *curReach = [note object];
	//NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
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

@end
