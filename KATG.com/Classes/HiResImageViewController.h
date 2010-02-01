//
//  HiResImageViewController.h
//  2Cents
//
//  Created by Doug Russell on 11/8/09.
//  Copyright 2009 Paper Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingImageView.h"


@interface HiResImageViewController : UIViewController <UIScrollViewDelegate, TapDetectingImageViewDelegate> {
	UIToolbar *toolBar;
	UIBarButtonItem *doneButton;
	UIBarButtonItem *saveButton;
	
	UIActivityIndicatorView *activityIndicator;
	
	UIScrollView *imageScrollView;
	TapDetectingImageView *imageView;
	UIImage *image;
	
	BOOL fromDisk;
}

@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property(nonatomic, retain) UIScrollView *imageScrollView;
@property(nonatomic, retain) TapDetectingImageView *imageView;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, readwrite) BOOL fromDisk;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)anImage;
- (void)updateImage:(UIImage *)img;
- (IBAction)dismissModalViewController;
- (IBAction)saveImage;
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
- (void)saveImage:(UIImage *)img;

@end
