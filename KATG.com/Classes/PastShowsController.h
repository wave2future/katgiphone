//
//  PastShowsController.h
//  KATG.com
//
//  Copyright 2008 Doug Russell
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

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface PastShowsController : UITableViewController <UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
	IBOutlet UINavigationController	*navigationController;
    NSMutableArray					*list;
	NSMutableArray					*listProxy;
	NSMutableArray					*filteredList;
	UIActivityIndicatorView			*activityIndicator;
	NSMutableArray					*feedEntries;
	NSString						*feedAddress;
	NSArray							*indexPaths;
	NSUserDefaults					*userDefaults;
	NetworkStatus					localWiFiConnectionStatus;
}

@property (nonatomic, retain) IBOutlet UINavigationController	*navigationController;
@property (nonatomic, retain) NSMutableArray					*list;
@property (nonatomic, retain) NSMutableArray					*listProxy;
@property (nonatomic, retain) NSMutableArray					*filteredList;
@property (nonatomic, retain) UIActivityIndicatorView			*activityIndicator;
@property (nonatomic, retain) NSMutableArray					*feedEntries;
@property (nonatomic, retain) NSString							*feedAddress;
@property (nonatomic, retain) NSArray							*indexPaths;
@property NetworkStatus localWiFiConnectionStatus;

- (void) pollFeed;
- (void)createNotificationForTermination;

@end
