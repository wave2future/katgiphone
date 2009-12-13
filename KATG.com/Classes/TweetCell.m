//
//  TweetCell.m
//  KATG.com
//
//  Copyright 2008 Doug Russell
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "TweetCell.h"


@implementation TweetCell

@synthesize lblTitle, lblSince, lblFrom, imgSquare;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        lblTitle.textColor = [UIColor blackColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:10.0];
		lblTitle.numberOfLines = 5;
        
		lblSince = [[UILabel alloc] initWithFrame:CGRectZero];
        lblSince.textColor = [UIColor blackColor];
        lblSince.font = [UIFont boldSystemFontOfSize:12.0];
		
		lblFrom = [[UILabel alloc] initWithFrame:CGRectZero];
        lblFrom.textColor = [UIColor blackColor];
        lblFrom.font = [UIFont boldSystemFontOfSize:12.0];
		
        imgSquare = [[UIImageView alloc] initWithFrame:CGRectZero];
		
		[self.contentView addSubview:lblTitle];
		[self.contentView addSubview:lblSince];
		[self.contentView addSubview:lblFrom];
        [self.contentView addSubview:imgSquare];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 0);
    CGRect rect = baseRect;
	
	// Icon
    rect.size.width = 60;
    rect.size.height = 60;
    rect.origin.x = 5;
    rect.origin.y = 5;
    imgSquare.frame = rect;
	
	// Name of Tweeter
	rect.origin.x = 70;
    rect.origin.y = 5;
    rect.size.width = 110;
	rect.size.height = 15;
    lblFrom.frame = rect;
	
	// Time Since Tweet
	rect.origin.x = 280;
    rect.origin.y = 5;
    rect.size.width = 40;
	rect.size.height = 15;
    lblSince.frame = rect;
	
	// Body Of Tweet
	rect.origin.x = 70;
    rect.origin.y = 20;
    rect.size.width = 220;
	rect.size.height = self.contentView.bounds.size.height - 30;
    lblTitle.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (selected) {
        lblTitle.textColor = [UIColor whiteColor];
    } else {
        lblTitle.textColor = [UIColor blackColor];
    }
}

- (void)dealloc {
    [lblTitle release];
	[lblSince release];
	[lblFrom release];
    [imgSquare release];
    [super dealloc];
}


@end