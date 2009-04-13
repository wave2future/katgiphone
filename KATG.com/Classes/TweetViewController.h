//
//  TweetViewController.h
//  KaTGTwitter
//
//  Created by Ashley Mills on 11/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
//

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
