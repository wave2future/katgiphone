//
//  InterTableViewController.h
//  KATG.com
//
//  Created by Doug Russell on 1/20/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

@interface InterTableViewController : UITableViewController {
	NSArray *urlList;
	NSArray *twtList;
	NSNumber *shouldStream;
}

@property (nonatomic, retain) NSArray *urlList;
@property (nonatomic, retain) NSArray *twtList;
@property (nonatomic, assign) NSNumber *shouldStream;

@end
