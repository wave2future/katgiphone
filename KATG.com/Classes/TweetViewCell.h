//
//  TweetViewCell.h
//  KaTGTwitters
//
//  Created by Ashley Mills on 10/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TweetViewCell : UITableViewCell {
	IBOutlet UIImageView *icon;
	IBOutlet UITextView *tweet;
	IBOutlet UILabel *since;
}

@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UITextView *tweet;
@property (nonatomic, retain) UILabel *since;

@end
