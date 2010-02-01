//
//  PastShowsDetailViewController+HiResImageView.m
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

#define kThumbTag @"-Thumb"

#import "PastShowsDetailViewController+HiResImageView.h"
#import "HiResImageViewController.h"

@implementation PastShowsDetailViewController (HiResImageView)

- (void)presentHiResImageView:(NSURL *)URL
{
	BOOL fromDisk = NO;
	UIImage *image = [picsModel pic:URL local:&fromDisk];
	HiResImageViewController *viewController = 
	[[HiResImageViewController alloc] initWithNibName:@"HiResImageView" 
											   bundle:nil 
												image:image];
	[viewController setFromDisk:fromDisk];
	[self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
}
- (void)pastShowPicDataModelDidChange:(UIImage *)pic
{
	if ([(HiResImageViewController *)[self modalViewController] respondsToSelector:@selector(updateImage:)])
	{
		[(HiResImageViewController *)[self modalViewController] updateImage:pic];
	}
}

@end
