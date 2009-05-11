//
//  ShowCell.m
//  KATG.com
//
//  Created by Doug Russell on 5/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ShowCell.h"


@implementation ShowCell
@synthesize lblTitle, lblDescription, lblLink;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        lblTitle.textColor = [UIColor blackColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:12.0];
		lblTitle.numberOfLines = 4;
		
        lblDescription = [[UILabel alloc] initWithFrame:CGRectZero];
        lblDescription.textColor = [UIColor darkGrayColor];
        lblDescription.font = [UIFont systemFontOfSize:12.0];
		
		lblLink = [[UILabel alloc] initWithFrame:CGRectZero];
        lblLink.textColor = [UIColor darkGrayColor];
        lblLink.font = [UIFont systemFontOfSize:12.0];
		
		[self.contentView addSubview:lblTitle];
        [self.contentView addSubview:lblDescription];
        [self.contentView addSubview:lblLink];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 0);
    CGRect rect = baseRect;
	
	rect.origin.x = self.contentView.bounds.size.width - 190;
    rect.origin.y = 0;
    rect.size.width = self.contentView.bounds.size.width - 120;
    lblTitle.frame = rect;
    
	rect.origin.x = self.contentView.bounds.size.width - 265;
    rect.origin.y = 45;
	rect.size.width = 70;
	rect.size.height = 20;
    lblDescription.frame = rect;
	
	rect.origin.y -= 30;
    lblLink.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (selected) {
        lblTitle.textColor = [UIColor whiteColor];
        lblDescription.textColor = [UIColor whiteColor];
		lblLink.textColor = [UIColor whiteColor];
    } else {
        lblTitle.textColor = [UIColor blackColor];
        lblDescription.textColor = [UIColor darkGrayColor];
        lblLink.textColor = [UIColor darkGrayColor];
    }
}

- (void)dealloc {
    [lblTitle release];
    [lblDescription release];
	[lblLink release];
    [super dealloc];
}


@end