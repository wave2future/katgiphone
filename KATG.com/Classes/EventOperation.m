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

- (id)initWithEvent:(NSDictionary *)anEvent {
	if( (self = [super init]) )
	{
		event = [anEvent retain];
	}
	return self;
}

- (void)dealloc {
	[event release];
	[super dealloc];
}

- (void)main {
	if( !self.isCancelled )
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[self _processEvent];
		[pool drain];
	}
}

- (void)_processEvent 
{	
	NSDictionary *dateTimes = [self _dateFormatting];
	
	NSNumber *showType = [self _showType];
	
	event = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
												 [event objectForKey:@"Title"],
												 [event objectForKey:@"EventId"],
												 [event objectForKey:@"Details"],
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
												 @"ShowType", nil]];
	
	if (event != nil && [self delegate]) {
		[[self delegate] operationDidFinishSuccesfully:self];
	}
}

- (NSDictionary *)_dateFormatting 
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle: NSDateFormatterLongStyle];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateFormat: @"MM/dd/yyyy HH:mm zzz"];
	NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"US"];
	[formatter setLocale:us];
	[us release];
	
	NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
	[dayFormatter setDateStyle: NSDateFormatterLongStyle];
	[dayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dayFormatter setDateFormat: @"EEE"];
	[dayFormatter setLocale:[NSLocale currentLocale]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle: NSDateFormatterLongStyle];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat: @"MM/dd"];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setDateStyle: NSDateFormatterLongStyle];
	[timeFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[timeFormatter setDateFormat: @"h:mm aa"];
	[timeFormatter setLocale:[NSLocale currentLocale]];
	
	NSString *eventTimeString = [event objectForKey:@"StartDate"];
	NSTimeZone *EST = [NSTimeZone timeZoneWithName:@"America/New_York"];
	if ([EST isDaylightSavingTime]) {
		eventTimeString = [eventTimeString stringByAppendingString:@" EDT"];
	} else {
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
	
	[formatter release];
	[dayFormatter release];
	[dateFormatter release];
	[timeFormatter release];
	
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
