//
//  LinksDataModel.h
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

@protocol LinksModelDelegate;

@interface LinksDataModel : NSObject {
@public
	id<LinksModelDelegate> delegate;
	// ShouldStream indicates connection status:
	// 0 No Connection
	// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
	// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
	// 3 Wifi Connection
	NSNumber            *shouldStream;
@private
	NSString            *_dataPath;
	NSArray             *_links;
	
	NSThread            *_thread;
	NSAutoreleasePool   *_pool;
	
	BOOL                _pollOnConnection;
}

@property (nonatomic, assign) id<LinksModelDelegate> delegate;
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
- (NSArray *)links;
// Cancels any running processes so model can be dismissed or changed
- (void)cancel;

@end

@protocol LinksModelDelegate
- (void)linksDataModelDidChange:(NSArray *)links;
@end
