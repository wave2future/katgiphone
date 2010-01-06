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

- (void)presentHiResImageView:(NSString *)URL
{
	NSURL *url = 
	[NSURL URLWithString:[URL stringByReplacingOccurrencesOfString:@"-Thumb" 
														withString:@""]];
	[NSThread detachNewThreadSelector:@selector(lkjaslasffaosaijfasfsfa:) 
							 toTarget:self 
						   withObject:url];
	
}
- (void)lkjaslasffaosaijfasfsfa:(NSURL *)url
{
	NSAutoreleasePool *pool = 
	[[NSAutoreleasePool alloc] init];
	NSData *imageData = 
	[NSData dataWithContentsOfURL:url];
	[self performSelectorOnMainThread:@selector(asdfsdafdsdfasfadssdf:) 
						   withObject:imageData 
						waitUntilDone:NO];
	[pool release];
}
- (void)asdfsdafdsdfasfadssdf:(NSData *)imageData
{
	if ([NSThread isMainThread])
	{
		UIImage *image = [UIImage imageWithData:imageData];
		HiResImageViewController *viewController = 
		[[HiResImageViewController alloc] initWithNibName:@"HiResImageView" 
												   bundle:nil 
													image:image];
		[self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[self presentModalViewController:viewController animated:YES];
		[viewController release];
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(asdfsdafdsdfasfadssdf:) 
							   withObject:imageData 
							waitUntilDone:NO];
	}
}

@end
