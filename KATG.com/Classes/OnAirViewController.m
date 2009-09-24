//  
//  OnAirViewController.m
//  KATG.com
//  
//  Live Show Tab with: 
//  Live Feed Playback
//  Submit Feedback
//  Live Feed Status
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "OnAirViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>


@implementation OnAirViewController

// Set up interface for sending and receiving data from fields and labels
// Audio Streamer Play/Stop Button
@synthesize audioButton;

#pragma mark System Stuff
//*******************************************************
//* viewDidLoad
//* 
//* Set up view and launch view logic
//* Executes once when view is first launched
//* or relaunched after a low memory event
//*******************************************************
- (void)viewDidLoad {
	// Loads Play button for audioStream
	UIImage *image = [UIImage imageNamed:@"playButton.png"];
	[self setAudioButtonImage:image];
	[image release];
}

#pragma mark Audio Streamer
//*******************************************************
//* audioButtonPressed
//* If the streamer is not active, activate stream and 
//* iniate button spin and image change
//* If the streamer is active, 
//* deactivate stream and change button image
//*******************************************************
- (IBAction)audioButtonPressed:(id)sender {
	if (!streamer) {
		
		NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
															 nil,
															 (CFStringRef)@"http://liveshow.keithandthegirl.com:8004",
															 //(CFStringRef)@"http://scfire-mtc-aa05.stream.aol.com:80/stream/1010",
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
		
		[self setAudioButtonImage:[UIImage imageNamed:@"loadingButton.png"]];
		
		[self spinButton];
	}
	else {
		[audioButton.layer removeAllAnimations];
		[streamer stop];
	}
}

//*******************************************************
//* setAudioButtonImage
//* 
//* Sets image for AudioStreamer play button
//*******************************************************
- (void)setAudioButtonImage:(UIImage *)image {
	[audioButton.layer removeAllAnimations];
	[audioButton
	 setImage:image
	 forState:0];
}

//*******************************************************
//* spinButton
//* 
//* Fancy Spinny Button Animation using CoreAnimation
//*******************************************************
- (void)spinButton {
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [audioButton frame];
	audioButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
	audioButton.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
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
	[audioButton.layer addAnimation:animation forKey:@"rotationAnimation"];
	
	[CATransaction commit];
}

//*******************************************************
//* animationDidStop
//* 
//* 
//*******************************************************
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
	if (finished)
	{
		[self spinButton];
	}
}

//*******************************************************
//* observeValueForKeyPath
//* 
//* 
//*******************************************************
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying])
		{
			[self
			 performSelector:@selector(setAudioButtonImage:)
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
			 performSelector:@selector(setAudioButtonImage:)
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

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	//NSLog(@"Did Receive Memory Warning");
	if (streamer) {
		[audioButton.layer removeAllAnimations];
		[streamer stop];
	}
}

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (void)dealloc {
	[super dealloc];
} // Release objects to save memory

@end