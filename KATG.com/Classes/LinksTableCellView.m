//
//  LinksTableCellView.m
//  KATG.com
//
//  Copyright 2009 Doug Russell
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

#import "LinksTableCellView.h"

@implementation LinksTableCellView

@synthesize lblTitle, imgSquare;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
	{
        imgSquare = [[UIImageView alloc] initWithFrame:CGRectZero];
		
		// Initialization code
		lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        lblTitle.textColor = [UIColor blackColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:16.0];
		[lblTitle setTextAlignment:UITextAlignmentCenter];
		lblTitle.numberOfLines = 2;
		
		[self.contentView addSubview:imgSquare];
		[self.contentView addSubview:lblTitle];
		
		[imgSquare release];
		[lblTitle release];
    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 0);
    CGRect rect = baseRect;
	
	rect.origin.x = 10;
    rect.origin.y = 10;
    rect.size.width = self.contentView.bounds.size.width - 20;
	rect.size.height = 60;
    lblTitle.frame = rect;
	
	imgSquare.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (selected) 
	{
        lblTitle.textColor = [UIColor darkGrayColor];
    } 
	else 
	{
        lblTitle.textColor = [UIColor blackColor];
    }
}

- (void)dealloc 
{
    [lblTitle removeFromSuperview];
	[imgSquare removeFromSuperview];
    [super dealloc];
}

@end
