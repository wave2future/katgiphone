//
//  EventsDataModel+Operations.m
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

#define EventsModelWillChange @"EventsModelWillChange"
#define EventsModelDidChange @"EventsModelDidChange"

#import "EventsDataModel+Operations.h"
#import "GrabXMLFeed.h"
#import "NSDictionary+EventSorting.h"

@implementation EventsDataModel (Operations)

- (void)parsingDidCompleteForNode:(NSDictionary *)node parser:(GrabXMLFeed *)parser
{
	EventOperation *op = [[EventOperation alloc] initWithEvent:node];
	[op setDelegate:self];
	[op setFormatter:[_formatter copy]];
	[op setDayFormatter:[_dayFormatter copy]];
	[op setDateFormatter:[_dateFormatter copy]];
	[op setTimeFormatter:[_timeFormatter copy]];
	[_eventQueue addOperation:op];
	[op release];
}

- (void)parsingDidCompleteSuccessfully:(GrabXMLFeed *)parser
{
	[parser release];
	[_pollingPool drain]; _pollingPool = nil;
	[self performSelectorOnMainThread:@selector(startTimer) 
						   withObject:nil 
						waitUntilDone:NO];
}

- (void)startTimer
{
	_timer = 
	[NSTimer scheduledTimerWithTimeInterval:5.0 
									 target:self 
								   selector:@selector(checkQueue:) 
								   userInfo:nil 
									repeats:NO];
}

- (void)operationDidFinishSuccesfully:(EventOperation *)op 
{	
	NSDictionary *event = [[op event] copy];
	if (event) {
		[self _addToEventsProxy:event];
	}
	//NSInteger count = [[_eventQueue operations] count];
	//NSLog(@"%d", count);
}

- (void)checkQueue:(NSTimer *)timer
{
	NSInteger count = [[_eventQueue operations] count];
	//NSLog(@"count: %d", count);
	if (count > 0)
	{
		//NSLog(@"continue");
		[NSTimer scheduledTimerWithTimeInterval:5.0 
										 target:self 
									   selector:@selector(checkQueue:) 
									   userInfo:nil 
										repeats:NO];
	}
	else 
	{
		[self _cleanup];
	}
}

- (void)_addToEventsProxy:(NSDictionary *)event 
{
	if ([NSThread isMainThread]) 
	{
		[_eventsProxy addObject:event];
		NSString *path = [_dataPath stringByAppendingPathComponent:kEventsPlist];
		[_eventsProxy sortUsingSelector:@selector(compareByDateAscending:)];
		[_eventsProxy writeToFile:path atomically:YES];
		if ([(NSObject *)[self delegate] respondsToSelector:@selector(eventsDataModelWillChange:)]) 
		{
			[[self delegate] eventsDataModelWillChange:_events];
		}
		if (notify) 
		{
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:EventsModelWillChange 
			 object:_events];
		}
		[_events release];
		_events = (NSArray *)[_eventsProxy copy];
		
		if ([(NSObject *)[self delegate] respondsToSelector:@selector(eventsDataModelDidChange:)]) 
		{
			[[self delegate] eventsDataModelDidChange:_events];
		}
		if (notify) 
		{
			[[NSNotificationCenter defaultCenter] 
			 postNotificationName:EventsModelDidChange 
			 object:_events];
		}
		[self writeEventsToDisk];
	} 
	else 
	{
		[self performSelectorOnMainThread:@selector(_addToEventsProxy:) 
							   withObject:event 
							waitUntilDone:NO];
	}
}

- (void)writeEventsToDisk
{
	if ([NSThread isMainThread])
	{
		NSString *path = [_dataPath stringByAppendingPathComponent:kEventsPlist];
		[_events writeToFile:path atomically:YES];
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(writeEventsToDisk) 
							   withObject:nil 
							waitUntilDone:NO];
	}

}

@end
