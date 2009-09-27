//
//  ImagePageViewController.m
//  KATG.com
//
//  Created by Doug Russell on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImagePageViewController.h"
#import "TapDetectingImageView.h"

@implementation ImagePageViewController

- (void)loadView {
	// Create a UIView that will fit in the UIScrollView this will be added to and assign it to self.view
	CGRect rect = CGRectMake(0, 0, 270, 190);
	self.view = [[UIView alloc] initWithFrame:rect];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Make a label for the image title and  add it to self.view
	CGRect rect = CGRectMake(10, 5, 250, 35);
	UILabel *lblTitle = [[UILabel alloc] initWithFrame:rect];
	[lblTitle setTextAlignment:UITextAlignmentCenter];
	[lblTitle setTextColor:[UIColor whiteColor]];
	[lblTitle setBackgroundColor:[UIColor clearColor]];
	lblTitle.font = [UIFont systemFontOfSize: 12];
	lblTitle.numberOfLines = 3;
	[lblTitle setText:title];
	[self.view addSubview:lblTitle];
	[lblTitle release];
	
	// Calculate the image size and the x offset that will center it
	CGSize size = image.size;
	CGFloat x = 270 - size.width;
	x = x / 2;
	
	// Make a UIImageView that is the exact size of the image and centered and add it to self.view
	rect = CGRectMake(x, 40, size.width, size.height);
	UIImageView *imView = [[UIImageView alloc] initWithFrame:rect];
	[imView setImage:image];
	[self.view addSubview:imView];
	[imView release];
	
	// Make a label for the image description and add it to self.view
	rect = CGRectMake(15, 140, 250, 40);
	UILabel *lblDescription = [[UILabel alloc] initWithFrame:rect];
	[lblDescription setTextAlignment:UITextAlignmentCenter];
	[lblDescription setTextColor:[UIColor blackColor]];
	[lblDescription setBackgroundColor:[UIColor clearColor]];
	lblDescription.font = [UIFont systemFontOfSize: 12];
	lblDescription.numberOfLines = 3;
	[lblDescription setText:description];
	[self.view addSubview:lblDescription];
	[lblDescription release];
	
	[self.view setBackgroundColor:[UIColor clearColor]];
}

- (id)initWithImage:(UIImage *)im withTitle:(NSString *)t withDescription:(NSString *)d {
    if (self = [super init]) {
        image = im;
		title = [NSString stringWithString:t];
		if (![d isEqualToString:@"NULL"]) {
			description = [NSString stringWithString:d];
		} else {
			description = @"No Description";
		}
    }
    return self;
}

- (void)didReceiveMemoryWarning {
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
