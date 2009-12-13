//
//  ShowCell.m
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

#import "ShowCell.h"


@implementation ShowCell

@synthesize lblTitle, lblGuests;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        lblTitle.textColor = [UIColor blackColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:12.0];
		lblTitle.numberOfLines = 1;
		
		lblGuests = [[UILabel alloc] initWithFrame:CGRectZero];
        lblGuests.textColor = [UIColor grayColor];
        lblGuests.font = [UIFont boldSystemFontOfSize:12.0];
		lblGuests.numberOfLines = 1;
		
		[self.contentView addSubview:lblTitle];
		[self.contentView addSubview:lblGuests];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 0);
    CGRect rect = baseRect;
	
	rect.origin.x = self.contentView.bounds.size.width - 240;
    rect.origin.y = 23;
    rect.size.width = self.contentView.bounds.size.width - 80;
	rect.size.height = 14;
    lblTitle.frame = rect;
	
	rect.origin.x = self.contentView.bounds.size.width - 290;
    rect.origin.y = 37;
    rect.size.width = self.contentView.bounds.size.width - 30;
	rect.size.height = 14;
    lblGuests.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (selected) {
        lblTitle.textColor = [UIColor whiteColor];
		lblGuests.textColor = [UIColor whiteColor];
    } else {
        lblTitle.textColor = [UIColor blackColor];
		lblGuests.textColor = [UIColor grayColor];
    }
}

- (void)dealloc {
    [lblTitle release];
	[lblGuests release];
    [super dealloc];
}


@end