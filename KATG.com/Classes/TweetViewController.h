//
//  TweetViewController.h
//  KATG.com
//
//  Created by Doug Russell on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetViewController : UITableViewController <UITableViewDelegate, UIAccelerometerDelegate> {
	IBOutlet UINavigationController	*navigationController; // 
	UIActivityIndicatorView			*activityIndicator;
    
	NSMutableArray					*tweets;
	NSMutableDictionary				*iconDict;
	
	NSMutableDictionary *isURL;
	NSMutableDictionary *urlDict;
	
	UIBarButtonItem *refButton;
	UIButton *button;
	UIBarButtonItem *othButton;
}

@property (nonatomic, retain) IBOutlet UINavigationController	*navigationController;
@property (nonatomic, retain) UIActivityIndicatorView			*activityIndicator;

- (void) pollFeed;

@end
