//
//  PastShowDataModel.h
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

#define kShowPlist @"show_%@.plist"

@protocol PastShowDataModelDelegate;

@interface PastShowDataModel : NSObject {
@public
	id<PastShowDataModelDelegate> delegate;
	// ShouldStream indicates connection status:
	// 0 No Connection
	// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
	// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
	// 3 Wifi Connection
	NSNumber            *shouldStream;
@private
	NSString            *_dataPath;
	NSDictionary        *_show;
	NSUserDefaults      *_userDefaults;
	
	NSThread            *_pollingThread;
	NSAutoreleasePool   *_pollingPool;
}

@property (nonatomic, assign)   id<PastShowDataModelDelegate> delegate;
@property (nonatomic, assign)   NSNumber *shouldStream;

// Returns retained model instance
+ (id)model;
// Returns retained array of dictionary objects with episode data for  
// episode with given show ID
//   ==>(NSARRAY *)
//			==>(NSDICTIONARY *)
//					OBJECT==>(NSSTRING *) KEY==>@"FileUrl"
//					OBJECT==>(NSSTRING *) KEY==>@"Detail"
// Method returns immediately with one of the following:
//       1. if data exists on disk show array is returned from data on disk
//       2. if data does not exist on disk and user has connectivity,
//          a show array is returned with single dictionary to indicate that 
//          show data is being loaded
//       3. if data does not exist on disk and user does not have connectivity
//          a pics array is returned with single dictionary to indicate that 
//          no connection is available
// After initially returning, updated show data is obtained and shared
// via delegate methods (this process is in a state of change and will
// be better documented once it is nearer to complete)
- (NSDictionary *)show:(NSString *)ID;
// Cancels any running processes so model can be dismissed
- (void)cancel;

@end

@protocol PastShowDataModelDelegate
@optional
- (void)pastShowDataModelWillChange:(NSDictionary *)aShow;
- (void)pastShowDataModelDidChange:(NSDictionary *)aShow;
- (void)pastShowModelDidFinish;
@end