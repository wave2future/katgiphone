//
//  TwitterTableViewController.h
//  Scott Sigler
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

#import "TwitterDataModel.h"

@class Reachability;
@interface TwitterTableViewController : UITableViewController <TwitterModelDelegate> {
	id delegate;
	// ShouldStream indicates connection status:
	// 0 No Connection
	// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
	// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
	// 3 Wifi Connection
	NSNumber         *shouldStream;
	NSArray          *tweetList;
	TwitterDataModel *model;
	UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

- (void)notification;
- (void)setupModel;
- (void)addSegmentedControl;
- (void)addActivityIndicator;
- (void)cleanupModel;
- (NSString *)timeSince:(NSDate *)date;
- (void)reloadTableView;
- (void)othTweets:(id)sender;
- (void)reachabilityChanged:(NSNotification* )note;
- (void)updateReachability:(Reachability*)curReach;

@end
