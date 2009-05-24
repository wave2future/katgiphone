//
//  TweetCell.h
//  KATG.com
//
//  Created by Doug Russell on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TweetCell : UITableViewCell {
	UILabel *lblTitle;
	UILabel *lblSince;
	UILabel *lblFrom;
    UIImageView *imgSquare;
}

@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) UILabel *lblSince;
@property (nonatomic, retain) UILabel *lblFrom;
@property (nonatomic, retain) UIImageView *imgSquare;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end