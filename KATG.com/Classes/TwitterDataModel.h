//
//  TwitterDataModel.h
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

#define SearchString @"http://search.twitter.com/search.rss?q=from%3Akeithandthegirl+OR+from%3AKeithMalley"
#define ExtendedSearch @"+OR+from%3AKaTGShowAlert+OR+%3Akeithmalley+OR+keithandthegirl+OR+katg+OR+%22keith+and+the+girl%22"
#define ResultsCount @"&rpp=20"

@protocol TwitterDataModelDelegate;

@interface TwitterDataModel : NSObject {
@public
	id<TwitterDataModelDelegate> delegate;
	// ShouldStream indicates connection status:
	// 0 No Connection
	// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
	// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
	// 3 Wifi Connection
	NSNumber         *shouldStream;
	BOOL             notify;
@private
	NSString         *_dataPath;
	
	NSArray          *_tweets;
	NSMutableArray   *_tweetsProxy;
	
	// How do I want to store the images?
	
	BOOL             _pollOnConnection;
}

@property (nonatomic, assign) id<TwitterDataModelDelegate> delegate;
@property (nonatomic, assign) NSNumber *shouldStream;

// Access shared Tweets Model
+ (TwitterDataModel *)sharedTwitterDataModel;
// Access events:
// Immediately returns either tweets from disk or a tempory tweet i.e loading or no connection
// Then Asynchronously polls twitter feed and informs delegate or posts a notification when changes occur
- (NSArray *)tweets;
// Start change notifications
- (void)startNotifier;
// Stop change notifications
- (void)stopNotifier;

@end

@protocol TwitterDataModelDelegate
@optional
// Notifies delegate just before events data will change
- (void)twitterDataModelWillChange:(NSArray *)tweets;
// Notifies delegate events data has changed
- (void)twitterDataModelDidChange:(NSArray *)tweets;
@end