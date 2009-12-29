//
//  EventsDataModel.m
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

#import "EventsDataModel.h"
#import "EventsDataModel+PrivateMethods.h"
#import "EventsDataModel+Reachability.h"
#import "EventsDataModel+Operations.h"
#import "SynthesizeSingleton.h"

@implementation EventsDataModel

@synthesize delegate;
@synthesize shouldStream;

SYNTHESIZE_SINGLETON_FOR_CLASS(EventsDataModel);

- (NSArray *)events 
{
	return [self _getEvents];
}

- (NSArray *)eventsFromDisk 
{
	return [self _getEventsFromDisk];
}

- (void)startNotifier 
{
	notify = YES;
}

- (void)stopNotifier 
{
	notify = NO;
}

@end
