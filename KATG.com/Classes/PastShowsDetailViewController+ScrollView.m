//
//  PastShowsDetailViewController+ScrollView.m
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

#import "PastShowsDetailViewController+ScrollView.h"

@implementation PastShowsDetailViewController (ScrollView)

- (void)changePage:(NSInteger)page
{
	pageControl.currentPage = page;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}
- (void)loadScrollViewWithPage:(int)page 
{
    if (page < 0) return;
    if (page >= picDataArray.count) return;
    
	ImagePageViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[ImagePageViewController alloc] init];
		[controller setDelegate:self];
		[controller loadView];
		controller = [self updateViewController:controller page:page];
		[viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}
- (ImagePageViewController *)updateViewController:(ImagePageViewController *)controller 
											 page:(NSInteger)page
{
	if (!picDataArray && [picDataArray count] > page) return nil;
	
	NSString *titleString = [[picDataArray objectAtIndex:page] objectForKey:@"Title"];
	if (titleString)
	{
		CGSize size = 
		[titleString sizeWithFont:[UIFont systemFontOfSize:14] 
				constrainedToSize:CGSizeMake(controller.titleLabel.frame.size.width, 100)];
		if (size.height > 17 && !controller.scaledDown)
		{
			controller.titleLabel.numberOfLines = 2;
			CGRect frame = controller.imageView.frame;
			controller.imageView.frame = CGRectMake(frame.origin.x, 
													frame.origin.y + 17, 
													frame.size.width, 
													frame.size.height - 17);
			controller.scaledDown = YES;
		}
		[controller.titleLabel setText:titleString];
	}
	
	NSData *imageData = [[picDataArray objectAtIndex:page] objectForKey:@"Data"];
	UIImage *imageLo = [UIImage imageWithData:imageData];
	if (imageLo) [controller.imageView setImage:imageLo];
	
	NSString *description = [[picDataArray objectAtIndex:page] objectForKey:@"Description"];
	if (description) [controller.descriptionLabel setText:description];
	
	NSURL *URL = [NSURL URLWithString:[[picDataArray objectAtIndex:page] objectForKey:@"URL"]];
	if (URL) [controller setURL:URL];
	
	return controller;
}
- (void)removeViewsBeforePage:(int)page 
{
	if (page < 1) return;
    if (page >= picDataArray.count) return;
	for (int i = 0; i < page; i++) {
		[viewControllers replaceObjectAtIndex:i withObject:[NSNull null]];
	}
}
- (void)removeViewsAfterPage:(int)page 
{
	if (page < 1) return;
    if (page > picDataArray.count) return;
	for (int i = page; i < picDataArray.count; i++) {
		[viewControllers replaceObjectAtIndex:i withObject:[NSNull null]];
	}
}
- (void)scrollViewDidScroll:(UIScrollView *)sender 
{
	// We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
	[self removeViewsBeforePage:page - 1];
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	[self removeViewsAfterPage:page + 2];
}
// At the end of scroll animation, reset the boolean used 
// when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{
    pageControlUsed = NO;
}

@end
