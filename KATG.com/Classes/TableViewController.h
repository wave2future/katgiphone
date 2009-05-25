//
//  TableViewController.h
//  KATG.com
//
//  Created by Doug Russell on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewController : UITableViewController {
	NSMutableArray *list;
}

@property (nonatomic, retain) NSMutableArray *list;

@end
