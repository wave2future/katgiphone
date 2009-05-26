//
//  TweetCell.m
//  KATG.com
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "TweetCell.h"


@implementation TweetCell

@synthesize lblTitle, lblSince, lblFrom, imgSquare;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        lblTitle.textColor = [UIColor blackColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:12.0];
		lblTitle.numberOfLines = 4;
        
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
	
	rect.origin.x = 60;
    rect.origin.y = 20;
    rect.size.width = self.contentView.bounds.size.width - 90;
	rect.size.height = self.contentView.bounds.size.height - 30;
    lblTitle.frame = rect;
    
	rect.origin.x = self.contentView.bounds.size.width - 20;
    rect.origin.y = 60;
    rect.size.width = 30;
	rect.size.height = 20;
    lblSince.frame = rect;
	
	rect.origin.x = 10;
    rect.origin.y = 0;
    rect.size.width = 100;
	rect.size.height = 20;
    lblFrom.frame = rect;
	
    rect.size.width = 48;
    rect.size.height = 48;
    rect.origin.x = 8;
    rect.origin.y = 20;
    imgSquare.frame = rect;
	
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