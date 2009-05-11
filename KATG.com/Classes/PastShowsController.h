//
//  PastShowsController.h
//  KATG.com
//
//  Created by Doug Russell on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PastShowsController : UITableViewController <UITableViewDelegate> {
	IBOutlet UINavigationController	*navigationController;
	//IBOutlet UITableView			*tableView;
    NSMutableArray					*list;
	UIActivityIndicatorView			*activityIndicator;
}

@property (nonatomic, retain) IBOutlet UINavigationController	*navigationController;
//@property (nonatomic, retain) IBOutlet UITableView				*tableView;
@property (nonatomic, retain) NSMutableArray					*list;
@property (nonatomic, retain) UIActivityIndicatorView			*activityIndicator;

- (void)pollFeed;
@end
