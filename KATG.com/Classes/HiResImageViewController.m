//
//  HiResImageViewController.m
//  2Cents
//
//  Created by Doug Russell on 11/8/09.
//  Copyright 2009 Paper Software. All rights reserved.
//

#import "HiResImageViewController.h"
#import <QuartzCore/CoreAnimation.h>

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@implementation HiResImageViewController

@synthesize toolBar, doneButton, imageScrollView, imageView, image, saveButton, fromDisk;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        CGRect rect = CGRectMake(0, 44, 320, 416);
		
		// set up main scroll view
		imageScrollView = [[UIScrollView alloc] initWithFrame:rect];
		[imageScrollView setBackgroundColor:[UIColor blackColor]];
		[imageScrollView setDelegate:self];
		[imageScrollView setBouncesZoom:YES];
		[[self view] addSubview:imageScrollView];
		
		// add touch-sensitive image view to the scroll view
		imageView = [[TapDetectingImageView alloc] initWithImage:image];
		[imageView setDelegate:self];
		[imageView setTag:ZOOM_VIEW_TAG];
		[imageScrollView setContentSize:[imageView frame].size];
		[imageScrollView addSubview:imageView];
		[imageView release];
		
		// calculate minimum scale to perfectly fit image width, and begin at that scale
		float minimumScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
		[imageScrollView setMinimumZoomScale:minimumScale];
		[imageScrollView setZoomScale:minimumScale];
		
		CGRect frame = CGRectMake(130, 160, 60, 60);
		activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
		[activityIndicator setContentMode:UIViewContentModeScaleToFill];
		activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		activityIndicator.hidesWhenStopped = YES;
		[self.view addSubview:activityIndicator];
		[activityIndicator release];
		
		CAShapeLayer *shapeLayer = [CAShapeLayer layer];
		CGRect shapeRect = CGRectMake(115.0f, 155.0f, 70.0f, 70.0f);
		[shapeLayer setBounds:shapeRect];
		[shapeLayer setPosition:CGPointMake(30, 30)];
		[shapeLayer setFillColor:[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.3] CGColor]];
		[shapeLayer setStrokeColor:[[UIColor blackColor] CGColor]];
		[shapeLayer setLineWidth:2.0f];
		[shapeLayer setLineJoin:kCALineJoinRound];
		
		// Setup the path
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, shapeRect);
		[shapeLayer setPath:path];
		CGPathRelease(path);
		
		[[activityIndicator layer] insertSublayer:shapeLayer atIndex:0];
	}
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage *)anImage {
	image = [anImage retain];
	self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
	if (!fromDisk) [activityIndicator startAnimating];
}

- (void)updateImage:(UIImage *)img
{
	// Swap out image and adjust content size
	[image release]; image = nil;
	image = [img retain];
	[imageView setImage:img];
	[imageView setFrame:CGRectMake(0, 0, [img size].width, [img size].height)];
	[imageScrollView setContentSize:[imageView frame].size];	
	// calculate minimum scale to perfectly fit image width, and begin at that scale
	float minimumScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
	[imageScrollView setMinimumZoomScale:minimumScale];
	[imageScrollView setZoomScale:minimumScale];
	[activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	[self dismissModalViewController];
}

- (void)viewDidUnload 
{
	[activityIndicator removeFromSuperview];
	[imageView removeFromSuperview];
	[imageScrollView removeFromSuperview];
}

- (void)dealloc 
{
	[doneButton release];
	[saveButton release];
	[toolBar release];
	[image release];
	[super dealloc];
}

- (IBAction)dismissModalViewController 
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveImage 
{
	[self saveImage:image];
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
    return [imageScrollView viewWithTag:ZOOM_VIEW_TAG];
}

/************************************** NOTE **************************************/
/* The following delegate method works around a known bug in zoomToRect:animated: */
/* In the next release after 3.0 this workaround will no longer be necessary      */
/**********************************************************************************/
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale 
{
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint 
{
    // single tap does nothing for now
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint 
{
    // double tap zooms in
    float newScale = [imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint 
{
    // two-finger tap zooms out
    float newScale = [imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark Save Image
// Method to save UIImage to camera roll
- (void)saveImage:(UIImage *)img 
{
	[saveButton setEnabled:NO];
	
	[activityIndicator startAnimating];
	
	UIImageWriteToSavedPhotosAlbum(img,
								   self,
								   @selector(image:didFinishSavingWithError:contextInfo:), 
								   nil);
}
// Called asynchronously when writing is completed or failed
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error 
  contextInfo:(void *)contextInfo
{
	// Was there an error?
	if (error != NULL)
	{
		// Show error message...
		NSLog([error description]);
	}
	else  // No errors
	{
		[activityIndicator stopAnimating];
		// Show message image successfully saved
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Saved"
							  message:@"Image saved to camera roll!"
							  delegate:nil
							  cancelButtonTitle:@"Continue"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

@end
