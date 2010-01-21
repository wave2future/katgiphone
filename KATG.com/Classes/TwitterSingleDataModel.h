//
//  TwitterSingleDataModel.h
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

@protocol TwitterSingleModelDelegate;

@interface TwitterSingleDataModel : NSObject {
@public
	id<TwitterSingleModelDelegate> delegate;
	// ShouldStream indicates connection status:
	// 0 No Connection
	// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
	// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
	// 3 Wifi Connection
	NSNumber            *shouldStream;
@private
	NSString            *_dataPath;
	NSArray             *_tweets;
	
	NSThread            *_tweetThread;
	NSAutoreleasePool   *_tweetPool;
		
	NSMutableDictionary *_images;
	
	NSDateFormatter     *_formatter;
	
	BOOL                _pollOnConnection;
}

@property (nonatomic, assign) id<TwitterSingleModelDelegate> delegate;
@property (nonatomic, assign) NSNumber *shouldStream;

// Returns retained model instance
+ (id)model;
// THIS NEEDS MODIFICATION
// Returns retained array of dictionary objects with tweet data
//   ==>(NSARRAY *)
//			==>(NSDICTIONARY *)
//					OBJECT==>(NSDate *)   KEY==>@"CreatedAt"
//					OBJECT==>(NSSTRING *) KEY==>@"TweetText"
//                  OBJECT==>(NSSTRING *) KEY==>@"Name"
//                  OBJECT==>(NSSTRING *) KEY==>@"ScreenName"
//                  OBJECT==>(NSSTRING *) KEY==>@"IconURL"
// Method returns immediately with one of the following:
//       1. if data exists on disk tweet array is returned from data on disk
//       2. if data does not exist on disk and user has connectivity,
//          a tweet array is returned with single dictionary to indicate that 
//          tweet data is being loaded
//       3. if data does not exist on disk and user does not have connectivity
//          a tweet array is returned with single dictionary to indicate that 
//          no connection is available
// After initially returning, updated show data is obtained and shared
// via delegate methods (this process is in a state of change and will
// be better documented once it is nearer to complete)
- (NSArray *)tweetsForUser:(NSString *)user;
// Cancels any running processes so model can be dismissed or changed
- (void)cancelTweets;
// Method returns immediately with one of the following:
//       1. if image has already been loaded, returns final image
//       2. if image has not been previously loaded,= a temporary image is
//          returned
// After method returns:
//       1. if the image exists on disk it is loaded and then sent to
//          the delegate
//       2. if the image does not exist it is retrieved from the given URL,
//          loaded, sent to delegate and written to disk for future use
- (UIImage *)image:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath;

@end

@protocol TwitterSingleModelDelegate
- (void)tweetsDidChange:(NSArray *)tweets;
- (void)imageDidChange:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath;
@end
