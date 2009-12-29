//
//  PastShowsDataModel.h
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

@protocol PastShowsDataModelDelegate;

@interface PastShowsDataModel : NSObject {
@public
	id<PastShowsDataModelDelegate> delegate;
	NSNumber       *shouldStream;
@private
	NSString       *_dataPath;
	NSArray        *_shows;
	NSMutableArray *_showsProxy;
	NSUserDefaults *_userDefaults;
	NSThread       *pollingThread;
	NSAutoreleasePool *pollingPool;
}

@property (nonatomic, assign)   id<PastShowsDataModelDelegate> delegate;
@property (nonatomic, assign)   NSNumber *shouldStream;

+ (PastShowsDataModel *)sharedPastShowsDataModel;
- (NSArray *)shows;
- (NSArray *)showsFromDisk;

@end

@protocol PastShowsDataModelDelegate
@optional
- (void)pastShowsDataModelWillChange:(NSArray *)shows;
- (void)pastShowsDataModelDidChange:(NSArray *)shows;
@end