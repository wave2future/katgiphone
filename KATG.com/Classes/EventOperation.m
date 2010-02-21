//
//  EventOperation.m
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

#import "EventOperation.h"

@implementation EventOperation

@synthesize delegate;
@synthesize event;
@synthesize formatter, dayFormatter, dateFormatter, timeFormatter;

- (id)initWithEvent:(NSDictionary *)anEvent 
{
	if( (self = [super init]) )
	{
		event = [anEvent retain];
	}
	return self;
}
- (void)dealloc 
{
	[event release];
	[formatter release];
	[dayFormatter release];
	[dateFormatter release];
	[timeFormatter release];
	[super dealloc];
}
- (void)main 
{
	if( !self.isCancelled )
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[self _processEvent];
		[pool drain];
	}
}
- (void)_processEvent 
{
	if( !self.isCancelled )
	{
		NSDictionary *dateTimes;
		NSNumber *showType;
		if( !self.isCancelled )
		{
			dateTimes = [self _dateFormatting];
		}
		if( !self.isCancelled )
		{
			showType = [self _showType];
		}
		if( !self.isCancelled )
		{
			NSString *title = [event objectForKey:@"Title"];
			if (!title) title = @"";
			NSString *eventID = [event objectForKey:@"EventId"];
			if (!eventID) eventID = @"";
			NSString *details = [event objectForKey:@"Details"];
			if (!details) details = @"";
			
			[event release]; event = nil;
			event =
			[[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
												  title,
												  eventID,
												  details,
												  [dateTimes objectForKey:@"DateTime"],
												  [dateTimes objectForKey:@"Day"],
												  [dateTimes objectForKey:@"Date"],
												  [dateTimes objectForKey:@"Time"], 
												  showType, nil]
										 forKeys:[NSArray arrayWithObjects:
												  @"Title",
												  @"EventId",
												  @"Details",
												  @"DateTime",
												  @"Day",
												  @"Date",
												  @"Time", 
												  @"ShowType", nil]] retain];
			
			if (event != nil && [self delegate] && !self.isCancelled) 
			{
				[[self delegate] operationDidFinishSuccesfully:self];
			}
		}
	}
}
- (NSDictionary *)_dateFormatting 
{	
	NSString *eventTimeString = [event objectForKey:@"StartDate"];
	NSTimeZone *EST = [NSTimeZone timeZoneWithName:@"America/New_York"];
	if ([EST isDaylightSavingTime]) 
	{
		eventTimeString = [eventTimeString stringByAppendingString:@" EDT"];
	} 
	else 
	{
		eventTimeString = [eventTimeString stringByAppendingString:@" EST"];
	}
	
	NSDate *eventDateTime = [formatter dateFromString:eventTimeString];
	
	NSString *eventDay = [dayFormatter stringFromDate:eventDateTime];
	
	NSString *eventDate = [dateFormatter stringFromDate:eventDateTime];
	
	NSString *eventTime = [timeFormatter stringFromDate:eventDateTime];
	
	NSDictionary *dateTimes =
	[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
										 eventDateTime, 
										 eventDay, 
										 eventDate, 
										 eventTime, nil] 
								forKeys:[NSArray arrayWithObjects:
										 @"DateTime",
										 @"Day",
										 @"Date",
										 @"Time", nil]];
	return dateTimes;
}
- (NSNumber *)_showType 
{
	if ([[event objectForKey:@"Title"] rangeOfString:@"Live Show"].location != NSNotFound) {
		return [NSNumber numberWithBool:YES];
	} else {
		return [NSNumber numberWithBool:NO];
	}
}

@end
