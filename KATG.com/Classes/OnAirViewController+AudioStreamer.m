//
//  OnAirViewController+AudioStreamer.m
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

#import "OnAirViewController+AudioStreamer.h"

@implementation OnAirViewController (AudioStreamer)

#pragma mark -
#pragma mark Setup
#pragma mark -
- (void)setupAudioAssets 
{
	[self setAudioButtonImage:[UIImage imageNamed:@"playButton.png"]];
	[self drawVolumeSlider];
}
#pragma mark -
#pragma mark Shoutcast
#pragma mark -
- (void)setAudioButtonImage:(UIImage *)image 
{
	[audioButton.layer removeAllAnimations];
	if (!image)
	{
		[audioButton setImage:[UIImage imageNamed:@"playButton.png"] forState:0];
	}
	else
	{
		[audioButton setImage:image forState:0];
		
		if ([audioButton.currentImage isEqual:[UIImage imageNamed:@"loadButton.png"]])
		{
			[self spinButton];
		}
	}}
//
// spinButton
//
// Shows the spin button when the audio is loading. This is largely irrelevant
// now that the audio is loaded from a local file.
//
- (void)spinButton
{
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

//
// animationDidStop:finished:
//
// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.
//
// Parameters:
//    theAnimation - the animation that rotated the button.
//    finished - is the animation finised?
//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}

//
// buttonPressed:
//
// Handles the play/stop button. Creates, observes and starts the
// audio streamer when it is a play button. Stops the audio streamer when
// it isn't.
//
// Parameters:
//    sender - normally, the play/stop button.
//
- (IBAction)audioButtonPressed:(id)sender
{
	if ([shouldStream intValue] == 0) 
	{
		return;
	}
	[FlurryAPI logEvent:@"playButton"];
	if ([audioButton.currentImage isEqual:[UIImage imageNamed:@"playButton.png"]])
	{
		[self setAudioButtonImage:[UIImage imageNamed:@"loadButton.png"]];
		[self createStreamer];
		[streamer start];
	}
	else
	{
		[streamer stop];
	}
}
//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[self setAudioButtonImage:[UIImage imageNamed:@"loadButton.png"]];
	}
	else if ([streamer isPlaying])
	{
		[self setAudioButtonImage:[UIImage imageNamed:@"stopButton.png"]];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		[self setAudioButtonImage:[UIImage imageNamed:@"playButton.png"]];
	}
}
//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:streamer];
		//[progressUpdateTimer invalidate];
		//progressUpdateTimer = nil;
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}
// 
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
	
	[self destroyStreamer];
	
	//NSString *urlString = @"http://liveshow.keithandthegirl.com:8004";
	NSString *urlString = 
	@"http://scfire-mtc-aa05.stream.aol.com:80/stream/1010";
	NSURL *url = [NSURL URLWithString:urlString];
	
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
//	progressUpdateTimer =
//	[NSTimer
//	 scheduledTimerWithTimeInterval:0.1
//	 target:self
//	 selector:@selector(updateProgress:)
//	 userInfo:nil
//	 repeats:YES];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(playbackStateChanged:)
	 name:ASStatusChangedNotification
	 object:streamer];
}

#pragma mark -
#pragma mark Volume
#pragma mark -
- (void)drawVolumeSlider 
{
	MPVolumeView *volumeView = 
	[[MPVolumeView alloc] initWithFrame:volumeSliderContainer.bounds];
	UIView *volumeViewSlider;
	[volumeSliderContainer addSubview:volumeView];
	for (UIView *view in [volumeView subviews]) 
	{
		if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) 
		{
			volumeViewSlider = view;
		}
	}
	[(UISlider *)volumeViewSlider setMinimumTrackImage:
	 [UIImageForNameExtension(@"leftslide", @"png") stretchableImageWithLeftCapWidth:10.0 
																		topCapHeight:0.0] 
											  forState:UIControlStateNormal];
	[(UISlider *)volumeViewSlider setMaximumTrackImage:
	 [UIImageForNameExtension(@"rightslide", @"png") stretchableImageWithLeftCapWidth:10.0 
																		 topCapHeight:0.0] 
											  forState:UIControlStateNormal];
	for (UIView *view in [volumeSliderContainer subviews]) [view removeFromSuperview];
	volumeView.backgroundColor = [UIColor clearColor];
	volumeSliderContainer.backgroundColor = [UIColor clearColor];
	[volumeSliderContainer addSubview:volumeView];
	[volumeView release];
}

@end
