//
//  PastShowDataModel+PrivateMethods.m
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

#import "PastShowDataModel+PrivateMethods.h"
#import "Reachability.h"
#import "GrabXMLFeed.h"

#define kFeedAddress @"http://app.keithandthegirl.com/Api/Feed/Show/?ShowId=%@"
#define kXPath @"//root"

@implementation PastShowDataModel (PrivateMethods)

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
		_userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}
- (void)_cancel 
{
	if([_pollingThread isExecuting])
	{
		[_pollingThread cancel];
	}
}
- (void)dealloc 
{
	delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self _stopPollingThread];
	[_dataPath release];
	[super dealloc];
}
- (NSDictionary *)_getShow:(NSString *)ID 
{
	NSString *fileName = [NSString stringWithFormat:kShowPlist, ID];
	NSString *path = [_dataPath stringByAppendingPathComponent:fileName];
	NSDictionary *shw = [NSDictionary dictionaryWithContentsOfFile:path];
	if (!shw && [shouldStream intValue] != 0) 
	{
		shw = [self _loadingDictionary];
	} 
	else if (!shw && [shouldStream intValue] == 0) 
	{
		shw = [self _noConnectionDictionary];
	}
	if ([shouldStream intValue] != 0) 
	{
		_pollingThread = 
		[[NSThread alloc] initWithTarget:self 
								selector:@selector(_pollShowFeed:) 
								  object:ID];
		[_pollingThread start];
	}
	return [shw retain];
}
- (NSDictionary *)_loadingDictionary 
{
	NSDictionary *show = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
															  @"",
															  @"Loading Show Notes", nil]
													 forKeys:[NSArray arrayWithObjects:
															  @"FileUrl",
															  @"Detail", nil]];
	return show;
}
- (NSDictionary *)_noConnectionDictionary 
{
	NSDictionary *show = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
															  @"",
															  @"Unable to Download Show Notes", nil]
													 forKeys:[NSArray arrayWithObjects:
															  @"FileUrl",
															  @"Detail", nil]];
	return show;
}
- (void)_pollShowFeed:(NSString *)ID 
{
	_pollingPool = [[NSAutoreleasePool alloc] init];
	NSString *feedAddress = [NSString stringWithFormat:kFeedAddress, ID];;
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
	if (![_pollingThread isCancelled])
	{
		NSMutableArray *feedEntries = [[parser feedEntries] copy];
		[self _buildShow:feedEntries];
		[feedEntries release];
		[parser release];
	}
	[self _stopPollingThread];
}
- (void)_stopPollingThread 
{
	[_pollingPool drain]; _pollingPool = nil;
	[_pollingThread cancel];
	[_pollingThread release]; _pollingThread = nil;
}
- (void)_buildShow:(NSMutableArray *)feedEntries 
{
	if ([feedEntries count] > 0) {
		NSDictionary *entry = [feedEntries objectAtIndex:0];
		
		NSString *detail;
		if ([[entry objectForKey:@"Detail"] isEqualToString:@"NULL"]) 
		{
			detail = @" • No Show Notes";
		} 
		else 
		{
			detail = @" • ";
			detail = 
			[detail stringByAppendingString:
			 [[entry objectForKey:@"Detail"] stringByReplacingOccurrencesOfString:@"\n" 
																	   withString:@"\n • "]];
		}
		_show = 
		[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
											 [entry objectForKey:@"FileUrl"],
											 detail, nil]
									forKeys:[NSArray arrayWithObjects:
											 @"FileUrl",
											 @"Detail", nil]];
		[[self delegate] pastShowDataModelDidChange:_show];
		if (![detail isEqualToString:@" • No Show Notes"]) 
		{
			[self _writeShowToFile:[entry objectForKey:@"ShowId"]];
		}
	}
}
- (void)_writeShowToFile:(NSString *)ID 
{
	if (![NSThread isMainThread]) {
		NSString *path = 
		[_dataPath stringByAppendingPathComponent:
		 [NSString stringWithFormat:kShowPlist, ID]];
		[_show writeToFile:path atomically:YES];
	} else {
		[self performSelectorOnMainThread:@selector(_writeShowToFile:)
							   withObject:ID 
							waitUntilDone:NO];
	}
}
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

@end
