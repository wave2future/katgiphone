//
//  TweetViewController.h
//  KaTGTwitter
//
//  Created by Ashley Mills on 11/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TweetViewCell;
@class MainViewController;

@interface TweetViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UIActivityIndicatorView *activity;
	IBOutlet UITableView *tv;
	IBOutlet MainViewController *mainViewController;
	
	long long bytesToLoad;
	long long bytesLoaded;
	
	NSMutableString * queryResult;
	NSMutableArray *tweets;
	
	UIImageView *icon;
	NSMutableDictionary *iconDict;
	UIImage * iconImage;
	
}

- (void) loadURL;
- (TweetViewCell *) createNewTweetCellFromNib;

@end
