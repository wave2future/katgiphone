//
//  ImagePageViewController.h
//  KATG.com
//
//  Created by Doug Russell on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImagePageViewController : UIViewController {
	UIImage *image;
	NSString *title;
	NSString *description;
}

- (id)initWithImage:(UIImage *)im withTitle:(NSString *)t withDescription:(NSString *)d;

@end
