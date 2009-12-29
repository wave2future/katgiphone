//
//  NSDictionary+EventSorting.m
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

#import "NSDictionary+EventSorting.h"

@implementation NSDictionary (EventSorting)

- (NSComparisonResult)compareByDateAscending:(id)event 
{
	int selfTime = [[self objectForKey:@"DateTime"] timeIntervalSinceNow];
	int otherTime = [[event objectForKey:@"DateTime"] timeIntervalSinceNow];
	NSComparisonResult result = NSOrderedSame;
	if (selfTime < otherTime) {
		result = NSOrderedAscending;
	} else if (selfTime > otherTime) {
		result = NSOrderedDescending;
	}
	return result;
}

- (NSComparisonResult)compareByDateDescending:(id)event 
{
	int selfTime = [[self objectForKey:@"DateTime"] timeIntervalSinceNow];
	int otherTime = [[event objectForKey:@"DateTime"] timeIntervalSinceNow];
	NSComparisonResult result = NSOrderedSame;
	if (selfTime < otherTime) {
		result = NSOrderedDescending;
	} else if (selfTime > otherTime) {
		result = NSOrderedAscending;
	}
	return result;
}

@end
