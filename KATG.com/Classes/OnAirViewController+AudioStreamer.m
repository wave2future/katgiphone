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
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation OnAirViewController (AudioStreamer)

#pragma mark -
#pragma mark Setup
#pragma mark -
- (void)setupAudioAssets 
{
	UIImage *image = [UIImage imageNamed:@"playButton.png"];
	[self setAudioButtonImage:image];
	[self drawVolumeSlider];
}

#pragma mark -
#pragma mark Shoutcast
#pragma mark -

- (IBAction)audioButtonPressed:(id)sender 
{
	if ([shouldStream intValue] == 0) {
		return;
	}
	if (!streamer) {
		NSString *urlString = @"http://liveshow.keithandthegirl.com:8004";
		//NSString *urlString = @"http://scfire-mtc-aa05.stream.aol.com:80/stream/1010";
		
		NSURL *url = [NSURL URLWithString:urlString];
		
		streamer = [[AudioStreamer alloc] initWithURL:url];
		
		[streamer addObserver:self 
				   forKeyPath:@"isPlaying" 
					  options:0 
					  context:nil];
		
		[streamer start];
		
		[self setAudioButtonImage:[UIImage imageNamed:@"loadButton.png"]];
		
		[self spinButton];
	} else {
		
		[audioButton.layer removeAllAnimations];
		
		[streamer stop];
	}
}

- (void)setAudioButtonImage:(UIImage *)image 
{
	[audioButton.layer removeAllAnimations];
	[audioButton setImage:image forState:UIControlStateNormal];
}

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

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished 
{
	if (finished)
	{
		[self spinButton];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
	if ([keyPath isEqual:@"isPlaying"]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying]) {
			[self performSelector:@selector(setAudioButtonImage:) 
						 onThread:[NSThread mainThread] 
					   withObject:[UIImage imageNamed:@"stopButton.png"] 
					waitUntilDone:NO];
		} else {
			[streamer removeObserver:self 
						  forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
			
			[self performSelector:@selector(setAudioButtonImage:) 
						 onThread:[NSThread mainThread] 
					   withObject:[UIImage imageNamed:@"playButton.png"]
					waitUntilDone:NO];
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath 
						 ofObject:object 
						   change:change
						  context:context];
}

#pragma mark -
#pragma mark Volume
#pragma mark -

- (void)drawVolumeSlider 
{
	MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:volumeSliderContainer.bounds];
	
	UIView *volumeViewSlider;
	
	[volumeSliderContainer addSubview:volumeView];
	
	for (UIView *view in [volumeView subviews]) {
		if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
			volumeViewSlider = view;
		}
	}
	
	[(UISlider *)volumeViewSlider setMinimumTrackImage:[[UIImage imageNamed:@"leftslide.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] 
											  forState:UIControlStateNormal];
	
	[(UISlider *)volumeViewSlider setMaximumTrackImage:[[UIImage imageNamed:@"rightslide.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] 
											  forState:UIControlStateNormal];
	
	for (UIView *view in [volumeSliderContainer subviews]) [view removeFromSuperview];
	
	volumeView.backgroundColor = [UIColor clearColor];
	volumeSliderContainer.backgroundColor = [UIColor clearColor];
	[volumeSliderContainer addSubview:volumeView];
	
	[volumeView release];
}

@end
