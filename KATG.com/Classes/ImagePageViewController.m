//
//  ImagePageViewController.m
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

#import "ImagePageViewController.h"


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
