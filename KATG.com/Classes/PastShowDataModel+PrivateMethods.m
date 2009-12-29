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

#define FEEDADDRESS @"http://app.keithandthegirl.com/Api/Feed/Show/?ShowId=%@"

@implementation PastShowDataModel (PrivateMethods)

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
    }
    return self;
}

- (NSDictionary *)_getShow:(NSString *)ID 
{
	NSString *path = 
	[_dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"show_%@.plist", ID]];
	NSDictionary *shw = [NSDictionary dictionaryWithContentsOfFile:path];
	if (shw == nil && [shouldStream intValue] != 0) {
		shw = [self _loadingDictionary];
	} else if (shw == nil && [shouldStream intValue] == 0) {
		shw = [self _noConnectionDictionary];
	}
	if (shouldStream != 0) {
		pollingThread = [[NSThread alloc] initWithTarget:self selector:@selector(_pollShowFeed:) object:ID];
		[pollingThread start];
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
	pollingPool = [[NSAutoreleasePool alloc] init];
	NSString *feedAddress = [NSString stringWithFormat:FEEDADDRESS, ID];;
	// Select the xPath to parse against
	NSString *xPath = @"//root";
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
	[self _buildShow:feedEntries];
	[feedEntries release];
	[parser autorelease];
	[self _stopPollingThread];
}

- (void)_stopPollingThread 
{
	[pollingPool release];
	[pollingThread cancel];
	pollingThread = nil;
}

- (void)_buildShow:(NSMutableArray *)feedEntries 
{
	if ([feedEntries count] > 0) {
		NSDictionary *entry = [feedEntries objectAtIndex:0];
		
		NSString *detail;
		if ([[entry objectForKey:@"Detail"] isEqualToString:@"NULL"]) {
			detail = @" • No Show Notes";
		} else {
			detail = @" • ";
			detail = [detail stringByAppendingString:[[entry objectForKey:@"Detail"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n • "]];
		}
		

		_show = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
																  [entry objectForKey:@"FileUrl"],
																  detail, nil]
														 forKeys:[NSArray arrayWithObjects:
																  @"FileUrl",
																  @"Detail", nil]];
		[[self delegate] pastShowDataModelDidChange:_show];
		if (![detail isEqualToString:@" • No Show Notes"]) {
			[self _writeShowToFile:[entry objectForKey:@"ShowId"]];
		}
	}
}

- (void)_writeShowToFile:(NSString *)ID {
	if (![NSThread isMainThread]) {
		NSString *path = [_dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"show_%@.plist", ID]];
		[_show writeToFile:path atomically:YES];
	} else {
		[self performSelectorOnMainThread:@selector(_writeShowToFile:) withObject:ID waitUntilDone:NO];
	}
}

- (void)_attemptRelease 
{
	[self release];
	self = nil;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[pollingPool release];
	[pollingThread cancel];
	pollingThread = nil;
	delegate = nil;
	[_dataPath release];
	[_show release];
	[super dealloc];
}

@end
