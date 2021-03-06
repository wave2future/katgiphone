//
//  TwitterTableCellView.m
//  Scott Sigler
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

#define iconRect CGRectMake(7, 24, 50, 50)

#import "TwitterTableCellView.h"
#import <QuartzCore/CoreAnimation.h>
#import "ImageAdditions.h"

@implementation TwitterTableCellView

@synthesize tweetNameLabel, timeSinceLabel, tweetBodyLabel, iconView, accesoryButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
	{
		UIColor *green = [UIColor colorWithRed:0.627451f green:0.7451f blue:0.627451f alpha:1.0];
		bgView = 
		[[UIImageView alloc] initWithImage:UIImageForNameExtension(@"CellBackgroundDark80", @"png")];
		[self setBackgroundView:bgView];
		[bgView release];
		
        selView = 
		[[UIImageView alloc] initWithImage:UIImageForNameExtension(@"CellBackgroundSelected80", @"png")];
		[selView setBackgroundColor:[UIColor colorWithRed:0.427451f green:0.5451f blue:0.427451f alpha:1.0]];
		[self setSelectedBackgroundView:selView];
		[selView release];
		
		tweetNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[tweetNameLabel setFont:[UIFont systemFontOfSize:15]];
		[tweetNameLabel setAdjustsFontSizeToFitWidth:YES];
		[tweetNameLabel setBackgroundColor:green];
		[tweetNameLabel setTextColor:[UIColor blackColor]];
		[self addSubview:tweetNameLabel];
		[tweetNameLabel release];
		
		timeSinceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[timeSinceLabel setFont:[UIFont systemFontOfSize:14]];
		[timeSinceLabel setBackgroundColor:green];
		[timeSinceLabel setTextColor:[UIColor darkGrayColor]];
		[timeSinceLabel setTextAlignment:UITextAlignmentRight];
		[self addSubview:timeSinceLabel];
		[timeSinceLabel release];
		
		tweetBodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[tweetBodyLabel setFont:[UIFont systemFontOfSize:14]];
		[tweetBodyLabel setNumberOfLines:3];
		[tweetBodyLabel setBackgroundColor:green];
		[tweetBodyLabel setTextColor:[UIColor blackColor]];
		[tweetBodyLabel setBaselineAdjustment:UIBaselineAdjustmentNone];
		[self addSubview:tweetBodyLabel];
		[tweetBodyLabel release];
		
		iconView = [[UIButton alloc] initWithFrame:CGRectZero];
		[iconView.imageView setContentMode:UIViewContentModeScaleAspectFit];
		[self addSubview:iconView];
		[iconView release];
		
		//This should probably be in layout
		CGRect frame = iconRect;
		// Make layer
		CAShapeLayer *strokeLayer = [CAShapeLayer layer];
		[strokeLayer setBounds:frame];
		[strokeLayer setPosition:CGPointMake(25, 25)];
		[strokeLayer setFillColor:[[UIColor clearColor] CGColor]];
		[strokeLayer setStrokeColor:[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0] CGColor]];
		[strokeLayer setLineWidth:2.0f];
		[strokeLayer setLineJoin:kCALineJoinRound];
		// Setup the path
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, frame);
		[strokeLayer setPath:path];
		CGPathRelease(path);
		[[iconView layer] addSublayer:strokeLayer];
		
		UIImage *image = [UIImage imageNamed:@"Arrow.png"];
		CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
		accesoryButton = [[UIButton alloc] initWithFrame:rect];
		[accesoryButton setImage:image forState:UIControlStateNormal];
		[self setAccessoryView:accesoryButton];
		[[self accessoryView] setHidden:YES];
		[(UIButton *)[self accessoryView] setEnabled:NO];
		[accesoryButton release];
    }
    return self;
}
- (void)layoutSubviews 
{
    [super layoutSubviews];
	
	CGRect frame = CGRectMake(0, 0, 320, self.contentView.bounds.size.height);
	[bgView setFrame:frame];
	
	//frame = CGRectMake(0, 0, 320, self.contentView.bounds.size.height);
	[selView setFrame:frame];
	
	frame = CGRectMake(11, 3, 196, 21);
	[tweetNameLabel setFrame:frame];
	
	frame = CGRectMake(206, 3, 94, 21);
	[timeSinceLabel setFrame:frame];
	
	frame = CGRectMake(62, 24, 238, self.contentView.bounds.size.height - 36);
	[tweetBodyLabel setFrame:frame];
	[tweetBodyLabel setNumberOfLines:trunc((self.contentView.bounds.size.height)/18)];
	
	frame = iconRect;
	[iconView setFrame:frame];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)dealloc 
{
	[tweetNameLabel removeFromSuperview];
	[timeSinceLabel removeFromSuperview];
	[tweetBodyLabel removeFromSuperview];
	[iconView removeFromSuperview];
	[accesoryButton removeFromSuperview];
    [super dealloc];
}

@end
