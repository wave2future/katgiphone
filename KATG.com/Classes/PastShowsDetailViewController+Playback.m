//
//  PastShowsDetailViewController+Playback.m
//  KATG.com
//
//  Created by Doug Russell on 1/4/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#import "PastShowsDetailViewController+Playback.h"
#import <QuartzCore/CoreAnimation.h>

@implementation PastShowsDetailViewController (Playback)

#pragma mark -
#pragma mark Redirect Hack
#pragma mark -
// This is a hack to deal with MPMoviePlayer failing to handle some redirects
// as of 3.1
- (NSURLRequest *)connection:(NSURLConnection *)connection 
			 willSendRequest:(NSURLRequest *)request 
			redirectResponse:(NSURLResponse *)redirectResponse 
{
	[urlDescription release];
	urlDescription = nil;	
	urlDescription = [[request URL] description];
	[urlDescription retain];
	return request;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	[connection cancel];
	[connection release];
	connection = nil;
	
	[movieURL release];
	movieURL = nil;
	movieURL = [[NSURL URLWithString:urlDescription] retain];
	
	[self playMovie];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[self setPlayButtonImage:UIImageForNameExtension(@"playButton", @"png")];
	[connection release];
	connection = nil;
	playing = NO;
}
#pragma mark -
#pragma mark Playback Methods
#pragma mark -
- (void)chooseCorrectPlayback
{
	[self setPlayButtonImage:UIImageForNameExtension(@"loadButton", @"png")];
	[self spinButton];
	
	NSString *osVersion = [[UIDevice currentDevice] systemVersion];
	if ([osVersion doubleValue] >= 3.1) 
	{
		// On 3.1 and up 
		NSURLRequest *theRequest = [NSURLRequest requestWithURL:movieURL
													cachePolicy:NSURLRequestUseProtocolCachePolicy
												timeoutInterval:60.0];
		[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
	else 
	{
		// On 3.0
		[self playMovie];          
	}
}
-(void)playMovie 
{
	// Initialize a movie player object with the specified URL
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
	if (mp) 
	{
		// save the movie player object
		self.moviePlayer = mp;
		[mp release];
	}
}
//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	if (playing) [self.moviePlayer play];
}
//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
	playing = NO;
	[self setPlayButtonImage:UIImageForNameExtension(@"playButton", @"png")];
}
#pragma mark -
#pragma mark Playbutton Animatipn
#pragma mark -
- (void)spinButton 
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [playButton frame];
	playButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
	playButton.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
	
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[playButton.layer addAnimation:animation forKey:@"rotationAnimation"];
	
	[CATransaction commit];
}
- (void)setPlayButtonImage:(UIImage *)image 
{
	if ([NSThread isMainThread])
	{
		[playButton.layer removeAllAnimations];
		[playButton setImage:image forState:UIControlStateNormal];
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(setPlayButtonImage:) 
							   withObject:image 
							waitUntilDone:NO];
	}
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished 
{
	if (finished)
	{
		[self spinButton];
	}
}

@end
