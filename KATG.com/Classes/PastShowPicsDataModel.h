//
//  PastShowPicsDataModel.h
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

@protocol PastShowPicsDataModelDelegate;

@interface PastShowPicsDataModel : NSObject {
@public
	id<PastShowPicsDataModelDelegate> delegate;
	// ShouldStream indicates connection status:
	// 0 No Connection
	// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
	// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
	// 3 Wifi Connection
	NSNumber            *shouldStream;
@private
	NSString            *_dataPath;
	NSArray             *_pics;
	NSMutableArray      *_picsProxyParser;
	NSMutableArray		*_picsProxyImages;
	NSThread            *_pollingThread;
	NSAutoreleasePool   *_pollingPool;
	NSThread            *_imageThread;
	NSAutoreleasePool   *_imagePool;
	NSString            *_ID;
}

@property (nonatomic, assign) id<PastShowPicsDataModelDelegate> delegate;
@property (nonatomic, assign) NSNumber *shouldStream;

// Returns retained model instance
+ (id)model;
// Returns retained array of dictionary objects with picture data for  
// episode with given show ID
//   ==>(NSARRAY *)
//			==>(NSDICTIONARY *)
//					OBJECT==>(NSSTRING *) KEY==>@"URL"
//					OBJECT==>(NSSTRING *) KEY==>@"Title"
//					OBJECT==>(NSSTRING *) KEY==>@"Description"
//					OBJECT==>(NSDATA *)	  KEY==>@"Data"
//								(while no integrity testing is performed
//								except ensuring that some data does exist
//								it is reasonable to assume this data will
//								can be used to initialize a UIImage)
//								(URL maybe a local file URL or a URL to a 
//								remote server)
// Method returns immediately with one of the following:
//       1. if data exists on disk pics array is returned from data on disk
//       2. if data does not exist on disk and user has connectivity,
//          a pics array is returned with single dictionary to indicate that 
//          images are being loaded
//       3. if data does not exist on disk and user does not have connectivity
//          a pics array is returned with single dictionary to indicate that 
//          no connection is available
// After initially returning, updated picture data is obtained and shared
// via delegate methods (this process is in a state of change and will
// be better documented once it is nearer to complete)
- (NSArray *)pics:(NSString *)ID;
// Returns unretained UIImage retrieved from URL
// Method returns immediately with one of the following:
//       1. if data exists on disk, UIImage is returned from data on disk
//       2. if data does not exist on disk and user has connectivity
//          UIImage is returned with placeholder image to indicate that 
//          the image is being loaded
//       3. if data does not exist on disk and user does not have connectivity
//          UIImage is returned with placeholder image to indicate that 
//          the image is not available
// After initially returning, image data is obtained and shared via delegate 
// methods (this process is in a state of change and will be better documented 
// once it is nearer to complete)
- (UIImage *)pic:(NSURL *)URL;
// Cancels any running processes so model can be dismissed
- (void)cancel;

@end

@protocol PastShowPicsDataModelDelegate
@optional
// Provides pics array as it existed prior to new data
// being made available
- (void)pastShowPicsDataModelWillChange:(NSArray *)pics;
// Provides new pics array with updated pic data
- (void)pastShowPicsDataModelDidChange:(NSArray *)pics;
// Provides new pic data for individual pic queried with 
// [self (UIImage *)pic:(NSURL *)URL]
- (void)pastShowPicDataModelDidChange:(UIImage *)pic;
@end
