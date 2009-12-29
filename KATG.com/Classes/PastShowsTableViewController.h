//
//  PastShowsTableViewController.h
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

#import "PastShowsDataModel.h"

@class Reachability;
@interface PastShowsTableViewController : UITableViewController <PastShowsDataModelDelegate> {
	id                     delegate;
	UINavigationController *navigationController;
	NSArray		           *list;
	NSMutableArray		   *filteredList;
	NSNumber               *shouldStream;
	NSUserDefaults		   *userDefaults;
	PastShowsDataModel     *model;
}

@property (nonatomic, assign)          id                     delegate;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain)          NSArray                *list;
@property (nonatomic, retain)          NSMutableArray         *filteredList;

- (void)reloadTableView;
- (void)_reachabilityChanged:(NSNotification* )note;
- (void)_updateReachability:(Reachability*)curReach;

@end
