//
//  ImagePageViewController.m
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

#import "ImagePageViewController.h"

@implementation ImagePageViewController

@synthesize imageView;

- (void)loadView 
{
	[super loadView];
	CGFloat x = 0;
	CGFloat y = 0;
	CGFloat w = 250;
	CGFloat h = 170;
	// Create a UIView that will fit in the UIScrollView this will be added to and assign it to self.view
	CGRect rect = CGRectMake(x, y, w, h);
	view = [[UIView alloc] initWithFrame:rect];
	[self setView:view];
	[view release];
	[view setBackgroundColor:[UIColor clearColor]];
	
	// Create centered imageView with 80% of the view rectangle
	rect = CGRectMake(trunc(0.1*w), trunc(0.1*h), trunc(0.8*w), trunc(0.8*h));
	imageView = [[UIImageView alloc] initWithFrame:rect];
	imageView.multipleTouchEnabled = YES;
	imageView.userInteractionEnabled = YES;
	[imageView setContentMode:UIViewContentModeScaleAspectFit];
	[imageView setBackgroundColor:[UIColor clearColor]];
	[view addSubview:imageView];
	[imageView release];
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[imageView removeFromSuperview]; imageView = nil;	
}

- (void)dealloc 
{
    [super dealloc];
}


@end
