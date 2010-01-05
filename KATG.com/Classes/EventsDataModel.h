//
//  EventsDataModel.h
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

#define kEventsPlist @"events.plist"
#define kFeedAddress @"http://www.keithandthegirl.com/feed/event/"
#define kXPath @"//Event"
#define EventsModelWillChange @"EventsModelWillChange"
#define EventsModelDidChange @"EventsModelDidChange"

@protocol EventsDataModelDelegate;

@interface EventsDataModel : NSObject <EventOperationDelegate> {
@public
	id<EventsDataModelDelegate> delegate;
	// ShouldStream indicates connection status:
	// 0 No Connection
	// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
	// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
	// 3 Wifi Connection
	NSNumber         *shouldStream;
	BOOL             notify;
@private
	NSString         *_dataPath;
	NSArray          *_events;
	NSMutableArray   *_eventsProxy;
	NSOperationQueue *_eventQueue;
	BOOL             _pollOnConnection;
	NSAutoreleasePool *_pollingPool;
}

@property (nonatomic, assign)   id<EventsDataModelDelegate> delegate;
@property (nonatomic, assign)   NSNumber *shouldStream;

// Access shared Events Model
+ (EventsDataModel *)sharedEventsDataModel;
// Access events:
// Immediately returns either events from disk or a tempory event i.e loading or no connection
// Then Asynchronously polls events feed and informs delegate or posts a notification when changes occur
- (NSArray *)events;
// Immediately returns events from disk,
// if no events exist on disk -(NSArray *)events is used to 
// return a temporary event and then poll events feed
- (NSArray *)eventsFromDisk;
// Start change notifications
- (void)startNotifier;
// Stop change notifications
- (void)stopNotifier;

@end

@protocol EventsDataModelDelegate
@optional
// Notifies delegate just before events data will change
- (void)eventsDataModelWillChange:(NSArray *)events;
// Notifies delegate events data has changed
- (void)eventsDataModelDidChange:(NSArray *)events;
@end