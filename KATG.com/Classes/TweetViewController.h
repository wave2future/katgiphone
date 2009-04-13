//
//  TweetViewController.h
//  KATG.com
//
//  Created by Ashley Mills on 11/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import <UIKit/UIKit.h>
#import "WebViewController.h"

@class TweetViewCell;
//@class MainViewController;

@interface TweetViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UIActivityIndicatorView *activity;
	IBOutlet UITableView *tv;
//	IBOutlet MainViewController *mainViewController;
	
	long long bytesToLoad;
	long long bytesLoaded;
	
	CFMutableDictionaryRef connections;
	
	NSMutableArray *tweets;
	
	UIImageView *icon;
	NSMutableDictionary *iconDict;
	UIImage * iconImage;

	NSString *otherTweets;
	NSMutableDictionary *isURL;
	NSMutableDictionary *urlDict;
	
	UIBarButtonItem *refButton;
	UIBarButtonItem *addButton;
}

- (void) loadURL;
- (TweetViewCell *) createNewTweetCellFromNib;
- (void) processSearchData: (NSMutableData *) data;
- (void) processIconData: (NSMutableDictionary *) dict;

@end
