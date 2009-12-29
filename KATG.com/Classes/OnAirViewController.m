//
//  OnAirViewController.m
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

#import "OnAirViewControllerCategories.h"
#import "Reachability.h"

@implementation OnAirViewController
@synthesize delegate;
// Feedback
@synthesize nameTextField; 
@synthesize locationTextField;
@synthesize commentTextView;
@synthesize feedbackButton;
// Live Show Status
@synthesize liveShowStatusLabel;
// Next Live Show Countdown
@synthesize nextLiveShowCountdownLabel;
// Shoutcast 
@synthesize audioButton;
@synthesize volumeSliderContainer;
// Phone In
@synthesize callButton;
// connection status
@synthesize shouldStream;

#pragma mark -
#pragma mark Setup
#pragma mark -

- (void)viewDidLoad 
{
    [super viewDidLoad];
	// Set should stream and register for changes in reachability
	[self setupReachability];
	// Set custom feedback button images
	[self setFeedbackButtonImages];
	// Setup shoutcast playback and volume control
	[self setupAudioAssets];
	// Make sure phone is available, if not hide/disable phone in button
	if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:+16465028682"]]) {
		[callButton setEnabled:NO];
		[callButton setHidden:YES];
	}
	// Check live feed status
	[self pollStatusFeed];
	// Setup events data model
	[self getEventsData];
	// Check user defaults for resume values (playback and comment/name/location text)
	[self loadDefaults];
}

#pragma mark -
#pragma mark Cleanup
#pragma mark -

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	if (streamer)
	{
		[streamer stop];
	}
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[nameTextField release];
	[locationTextField release];
	[commentTextView release];
		
	[nextLiveShowCountdownLabel release];
	
	[audioButton release];
	[streamer release];
	
	[volumeSliderContainer release];
	
	[callButton release];
	
    [super dealloc];
}

@end
