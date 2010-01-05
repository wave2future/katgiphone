//
//  OnAirViewController+SetupCleanup.m
//  KATG.com
//
//  Created by Doug Russell on 1/4/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#define kPhoneNumber @"tel:+16465028682"

#import "OnAirViewController+SetupCleanup.h"

@implementation OnAirViewController (SetupCleanup)

- (void)setup
{
	// Set should stream and register for changes in reachability
	[self setupReachability];
	// Set custom feedback button images
	[self setFeedbackButtonImages];
	// Setup shoutcast playback and volume control
	[self setupAudioAssets];
	// Make sure phone is available, if not hide/disable phone in button
	if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kPhoneNumber]]) 
	{
		[callButton setEnabled:NO];
		[callButton setHidden:YES];
	}
	// Check live feed status
	[self pollStatusFeed];
	// Setup events data model
	[self getEventsData];
	// Check user defaults for resume values 
	// (playback and comment/name/location text)
	[self loadDefaults];
}
- (void)cleanup
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	delegate = nil;
	
	[shouldStream release];
	
	[nameTextField release];
	[locationTextField release];
	[commentTextView release];
	[feedbackButton release];
	
	[liveShowStatusLabel release];
	[feedPool release];
	
	[nextLiveShowCountdownLabel release];
	
	[audioButton release];
	[streamer release];
	
	[volumeSliderContainer release];
	
	[callButton release];
}

@end

