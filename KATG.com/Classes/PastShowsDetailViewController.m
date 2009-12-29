//
//  PastShowsDetailViewController.m
//  KATG.com
//
//  Copyright 2008 Doug Russell
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

#import "PastShowsDetailViewController.h"
#import <QuartzCore/CoreAnimation.h>

@implementation PastShowsDetailViewController

@synthesize shouldStream;
@synthesize show;

@synthesize titleLabel;
@synthesize numberLabel;
@synthesize guestsLabel;

@synthesize playButton;

@synthesize segmentedControl;

@synthesize noteView;
@synthesize picView;

@synthesize scrollView;
@synthesize pageControl;

@synthesize moviePlayer;
@synthesize movieURL;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	PastShowDataModel *model = [PastShowDataModel sharedPastShowDataModel];
	[model setDelegate:self];
	[model setShouldStream:shouldStream];
	NSDictionary *sh = [model show:[show objectForKey:@"ID"]];
	
	[noteView setText:[sh objectForKey:@"Detail"]];
	movieURL = [[NSURL URLWithString:[sh objectForKey:@"FileUrl"]] retain];
	if (!movieURL) {
		[playButton setEnabled:NO];
	}
	if ([shouldStream intValue] < 2) {
		[playButton setHidden:YES];
	}
	
	[titleLabel setText:[show objectForKey:@"Title"]];
	
	CGSize size = 
	[[show objectForKey:@"Guests"] sizeWithFont:
	 [UIFont systemFontOfSize:[guestsLabel minimumFontSize]]
	 ];
	if (size.width > guestsLabel.frame.size.width) {
		[guestsLabel setFont:[UIFont systemFontOfSize:12]];
		[guestsLabel setNumberOfLines:3];
	}
	
	[guestsLabel setText:[show objectForKey:@"Guests"]];
	[numberLabel setText:[NSString stringWithFormat:@"Show %@", [show objectForKey:@"Number"]]];
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(moviePreloadDidFinish:) 
	 name:MPMoviePlayerContentPreloadDidFinishNotification 
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(moviePlayBackDidFinish:) 
	 name:MPMoviePlayerPlaybackDidFinishNotification 
	 object:nil];
}

- (void)pastShowDataModelDidChange:(NSDictionary *)show 
{
	if (![NSThread isMainThread]) {
		[self setNoteViewText:[show objectForKey:@"Detail"]];
		[movieURL release];
		movieURL = [[NSURL URLWithString:[show objectForKey:@"FileUrl"]] retain];
		if (!movieURL) {
			[playButton setEnabled:NO];
		}
	} else {
		[self performSelectorOnMainThread:@selector(pastShowDataModelDidChange:) withObject:[show copy] waitUntilDone:NO];
	}
}

- (void)setNoteViewText:(NSString *)text 
{
	if ([NSThread isMainThread]) {
		[noteView setText:text];
	} else {
		[self performSelectorOnMainThread:@selector(setNoteViewText:) withObject:text waitUntilDone:NO];
	}
}

- (IBAction)segmentedControlChangedState:(id)sender 
{
	if ([segmentedControl selectedSegmentIndex] == 0) {
		[noteView setHidden:NO];
		[picView setHidden:YES];
	} else {
		[noteView setHidden:YES];
		[picView setHidden:NO];
	}
}

- (IBAction)playButtonPressed:(id)sender 
{
	if ([shouldStream intValue] < 2) 
	{
		NSString *alertMessage = @"Streaming shows over cellular network is disabled, enable Wifi to stream";
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Past Shows Streaming Disabled"
							  message:alertMessage 
							  delegate:nil
							  cancelButtonTitle:@"Continue" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (playing) 
	{
		[self setPlayButtonImage:[UIImage imageNamed:@"playButton.png"]];
		if (moviePlayer) 
		{
			[moviePlayer stop];
		}
		playing = NO;
		return;
	}
	playing = YES;
	
	[self setPlayButtonImage:[UIImage imageNamed:@"loadButton.png"]];
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
	[self setPlayButtonImage:[UIImage imageNamed:@"playButton.png"]];
	[connection release];
	connection = nil;
	playing = NO;
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
	[self.moviePlayer play];
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
	playing = NO;
	[self setPlayButtonImage:[UIImage imageNamed:@"playButton.png"]];
}

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
	[playButton.layer removeAllAnimations];
	[playButton setImage:image forState:UIControlStateNormal];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished 
{
	if (finished)
	{
		[self spinButton];
	}
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
	[moviePlayer stop];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc 
{
	[shouldStream release];
	[show release];
	[titleLabel release];
	[numberLabel release];
	[guestsLabel release];
	[playButton release];
	[segmentedControl release];
	[noteView release];
	[picView release];
	[scrollView release];
    [pageControl release];
    [viewControllers release];
	[movieURL release];
	[moviePlayer release];
    [super dealloc];
}

@end
