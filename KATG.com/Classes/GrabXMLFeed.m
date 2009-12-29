//
//  GrabXMLFeed.m
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

#import "GrabXMLFeed.h"
#import "GrabXMLFeed+PrivateMethods.h"
#import "TouchXML.h"

@implementation GrabXMLFeed

@synthesize delegate;
@synthesize feedEntries;

- (id)initWithFeed:(NSString *)feedAddress xPath:(NSString *)xPath 
{	
	if (self = [super init]) {
		// Initialize the feedEntries MutableArray that we declared in the header
		feedEntries = [[NSMutableArray alloc] init];
		
		// Convert the supplied URL string into a usable URL object
		_url = [[NSURL URLWithString:feedAddress] retain];
		
		_xpath = [xPath retain];
	}
	return self;
}

- (void)dealloc 
{
	delegate = nil;
	[_url release];
	[_xpath release];
	[feedEntries release];
	[super dealloc];
}

- (void)parse 
{
	[self _performParse];
}

- (NSInteger)instanceNumber
{
	return instanceNumber;
}

- (void)setInstanceNumber:(NSInteger)instance 
{
	instanceNumber = instance;
}

- (void)cancel 
{
	cancelled = YES;
}

- (BOOL)isCancelled
{
	return cancelled;
}

@end
