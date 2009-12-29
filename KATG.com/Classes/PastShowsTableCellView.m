//
//  PastShowsTableCellView.m
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

#import "PastShowsTableCellView.h"

@implementation PastShowsTableCellView

@synthesize showTypeImageView;
@synthesize showTitleLabel;
@synthesize showGuestsLabel;
@synthesize showNotesImageView;
@synthesize showPicsImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    [super setSelected:selected animated:animated];
	if (selected) {
		[showTitleLabel setTextColor:[UIColor whiteColor]];
	} else {
		[showTitleLabel setTextColor:[UIColor blackColor]];
	}
}

- (void)dealloc 
{
	[showTypeImageView release];
	[showTitleLabel release];
	[showNotesImageView release];
	[showPicsImageView release];
    [super dealloc];
}

@end
