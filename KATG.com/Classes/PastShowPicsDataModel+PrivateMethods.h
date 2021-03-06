//
//  PastShowPicsDataModel+PrivateMethods.h
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

#define kPicsPlist @"pics_%@.plist"

#import "PastShowPicsDataModel.h"

@class Reachability;
@interface PastShowPicsDataModel (PrivateMethods)

- (void)_cancel;
- (void)_reachabilityChanged:(NSNotification* )note;
- (void)_updateReachability:(Reachability*)curReach;
- (NSArray *)_getPics:(NSString *)ID;
- (NSArray *)_loadingArray;
- (NSArray *)_noConnectionArray;
- (void)_pollShowFeed:(NSString *)ID;
- (void)_buildList:(NSMutableArray *)feedEntries;
- (void)_writePicsToFile:(NSString *)ID;
- (void)_stopShowThread;

@end
