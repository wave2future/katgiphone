//
//  PastShowsDetailViewController+ScrollView.h
//  KATG.com
//
//  Created by Doug Russell on 1/4/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#import "PastShowsDetailViewController.h"

@interface PastShowsDetailViewController (ScrollView)

- (void)changePage:(NSInteger)page;
- (void)loadScrollViewWithPage:(int)page;
- (void)removeViewsBeforePage:(int)page;
- (void)removeViewsAfterPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end
