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
	NSNumber            *shouldStream;
@private
	NSString            *_dataPath;
	NSArray             *_pics;
	NSUserDefaults      *_userDefaults;
	
	NSThread            *pollingThread;
	NSAutoreleasePool   *pollingPool;
}

@property (nonatomic, assign)   id<PastShowPicsDataModelDelegate> delegate;
@property (nonatomic, assign)   NSNumber *shouldStream;

+ (PastShowPicsDataModel *)sharedPastShowPicsDataModel;
- (NSArray *)pics:(NSString *)ID;

@end

@protocol PastShowPicsDataModelDelegate
@optional
- (void)pastShowPicsDataModelWillChange:(NSArray *)pics;
- (void)pastShowPicsDataModelDidChange:(NSArray *)pics;
@end