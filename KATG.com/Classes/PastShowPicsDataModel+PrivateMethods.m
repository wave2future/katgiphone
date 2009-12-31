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

#define kFeedAddress @"http://app.keithandthegirl.com/Api/Feed/Pictures-By-Show/?ShowId=%@"
#define kXPath @"//picture"

@implementation PastShowPicsDataModel (PrivateMethods)

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
//	if (shouldStream != 0) {
//		pollingThread = [[NSThread alloc] initWithTarget:self selector:@selector(_pollShowFeed:) object:ID];
//		[pollingThread start];
//	}
	return [pics retain];
}

- (NSArray *)_loadingArray 
{
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Loading.png"];
	return [NSArray arrayWithObject:[UIImage imageWithContentsOfFile:path]];
}

- (NSArray *)_noConnectionArray 
{
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"NoConnection.png"];
	return [NSArray arrayWithObject:[UIImage imageWithContentsOfFile:path]];
}

- (void)_reachabilityChanged:(NSNotification *)note 
{
	
}

- (void)_attemptRelease 
{
	[self release];
	self = nil;
}

@end
