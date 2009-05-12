//
//  ShowCell.m
//  KATG.com
//
//  Created by Doug Russell on 5/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ShowCell.h"


@implementation ShowCell
@synthesize lblTitle;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        lblTitle.textColor = [UIColor blackColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:12.0];
		lblTitle.numberOfLines = 2;
		
		[self.contentView addSubview:lblTitle];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 0);
    CGRect rect = baseRect;
	
	rect.origin.x = self.contentView.bounds.size.width - 240;
    rect.origin.y = 0;
    rect.size.width = self.contentView.bounds.size.width - 120;
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
    [super dealloc];
}


@end