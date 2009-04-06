//
//  FirstViewController.m
//  KATG.com
//
//  Created by Doug Russell on 4/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FirstViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)setButtonImage:(UIImage *)image
{
	[button.layer removeAllAnimations];
	[button
	 setImage:image
	 forState:0];
}

- (void)viewDidLoad
{
	UIImage *image = [UIImage imageNamed:@"playButton.png"];
	[self setButtonImage:image];
}

- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [button frame];
	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
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
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];
	
	[CATransaction commit];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}

- (IBAction)buttonPressed:(id)sender
{
	if (!streamer)
	{
		
		NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
															 nil,
															 (CFStringRef)@"http://liveshow.keithandthegirl.com:8004",
															 NULL,
															 NULL,
															 kCFStringEncodingUTF8)
		 autorelease];
		
		NSURL *url = [NSURL URLWithString:escapedValue];
		streamer = [[AudioStreamer alloc] initWithURL:url];
		[streamer
		 addObserver:self
		 forKeyPath:@"isPlaying"
		 options:0
		 context:nil];
		[streamer start];
		
		[self setButtonImage:[UIImage imageNamed:@"loadingButton.png"]];
		
		[self spinButton];
	}
	else
	{
		[button.layer removeAllAnimations];
		[streamer stop];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying])
		{
			[self
			 performSelector:@selector(setButtonImage:)
			 onThread:[NSThread mainThread]
			 withObject:[UIImage imageNamed:@"stopButton.png"]
			 waitUntilDone:NO];
		}
		else
		{
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
			
			[self
			 performSelector:@selector(setButtonImage:)
			 onThread:[NSThread mainThread]
			 withObject:[UIImage imageNamed:@"playButton.png"]
			 waitUntilDone:NO];
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
						  context:context];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

@end
