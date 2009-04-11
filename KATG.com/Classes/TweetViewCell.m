//
//  TweetViewCell.m
//  KaTGTwitters
//
//  Created by Ashley Mills on 10/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
//

#import "TweetViewCell.h"

@implementation TweetViewCell
@synthesize icon;
@synthesize tweet;
@synthesize since;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
	
}

- (void)dealloc {
    [super dealloc];
}


@end
