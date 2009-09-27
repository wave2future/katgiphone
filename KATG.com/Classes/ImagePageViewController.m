//
//  ImagePageViewController.m
//  KATG.com
//
//  Created by Doug Russell on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImagePageViewController.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@implementation ImagePageViewController

- (id)initWithImage:(UIImage *)im withTitle:(NSString *)t withDescription:(NSString *)d {
    if (self = [super init]) {
        image = im;
		title = [NSString stringWithString:t];
		if (![d isEqualToString:@"NULL"]) {
			description = [NSString stringWithString:d];
		} else {
			description = @"";
		}
    }
    return self;
}

- (void)loadView {
	[super loadView];
	
	// Create a UIView that will fit in the UIScrollView this will be added to and assign it to self.view
	CGRect rect = CGRectMake(0, 0, 270, 190);
	view = [[UIView alloc] initWithFrame:rect];
	self.view = view;
	[view setBackgroundColor:[UIColor clearColor]];
	
	// Make a label for the image title and  add it to self.view
	rect = CGRectMake(10, 5, 250, 35);
	UILabel *lblTitle = [[UILabel alloc] initWithFrame:rect];
	[lblTitle setTextAlignment:UITextAlignmentCenter];
	[lblTitle setTextColor:[UIColor whiteColor]];
	[lblTitle setBackgroundColor:[UIColor clearColor]];
	lblTitle.font = [UIFont systemFontOfSize: 12];
	lblTitle.numberOfLines = 3;
	[lblTitle setText:title];
	[view addSubview:lblTitle];
	[lblTitle release];
	
	// Calculate the image size and the x offset that will center it
	CGSize size = image.size;
	CGFloat x = 270 - size.width;
	x = x / 2;
	
	// Make a UIImageView that is the exact size of the image and centered and add it to self.view
	rect = CGRectMake(x, 40, size.width, size.height);
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
	[imageView setImage:image];
	[view addSubview:imageView];
	[imageView release];
	
	// Make a label for the image description and add it to self.view
	rect = CGRectMake(15, 140, 250, 40);
	UILabel *lblDescription = [[UILabel alloc] initWithFrame:rect];
	[lblDescription setTextAlignment:UITextAlignmentCenter];
	[lblDescription setTextColor:[UIColor blackColor]];
	[lblDescription setBackgroundColor:[UIColor clearColor]];
	lblDescription.font = [UIFont systemFontOfSize: 12];
	lblDescription.numberOfLines = 3;
	[lblDescription setText:description];
	[view addSubview:lblDescription];
	[lblDescription release];
}

- (void)didReceiveMemoryWarning {
	[view release];
	[title release];
	[description release];
	[image release];
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[title release];
	[description release];
	[image release];
    [super dealloc];
}


@end
