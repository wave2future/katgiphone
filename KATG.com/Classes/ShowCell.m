//
//  ShowCell.m
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
    rect.size.width = self.contentView.bounds.size.width - 120;
	rect.size.height = 14;
    lblTitle.frame = rect;
	
	rect.origin.x = self.contentView.bounds.size.width - 290;
    rect.origin.y = 37;
    rect.size.width = self.contentView.bounds.size.width - 100;
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