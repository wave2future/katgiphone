//  
//  OnAirViewController.m
//  KATG.com
//  
//  Live Show Tab with: 
//  Live Feed Playback
//  Submit Feedback
//  Live Feed Status
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

#import "OnAirViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import "sanitizeField.h"
#import "grabRSSFeed.h"
#import "Beacon.h"

// Integer value for countdown to next live show
static int timeSince;

@implementation OnAirViewController

// Set up interface for sending and receiving data from fields and labels
// Audio Streamer Play/Stop Button
@synthesize audioButton, volumeSliderContainer, feedbackButton, nameField, locField, comField, callButton, days, hours, minutes, statusText;

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
	
	// Draw Volume Slider
	[self drawVolumeSlider];
	
	// Set Feedback Button Image
	[self setFeedbackButtonImage];
	
	// Set Phone Button Image
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:+1..."]] == NO) {
		callButton.enabled = NO;
		callButton.hidden = YES;
	}
	
	// Notification Center for handling Text View Did Begin Editing. 
	// In this case it clears the Text View when editing begins unless it is
	// saved text from a previous session.
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleUITextViewTextDidBeginEditingNotification:) 
	 name:@"UITextViewTextDidBeginEditingNotification" 
	 object:nil];
	
	[self createNotificationForTermination];
}

- (void)viewDidAppear:(BOOL)animated {
	// Auto start audiostreamer if it was playing when the app last exited
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	[self setDefaults];
	
	//
	[ NSThread detachNewThreadSelector: @selector(feedStatusAutoPool) toTarget: self withObject: nil ];
	
	// Set update timer for live feed xml
	[self setFeedStatusTimer];
	
	//
	[ NSThread detachNewThreadSelector: @selector(nextShowAutoPool) toTarget: self withObject: nil ];
	
	// Set update timer for for Countdown to next live show
	timeSince = 0;
	[self setNextShowTimer];
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
		[[Beacon shared] startSubBeaconWithName:@"audioButtonPressed" timeSession:NO];
		NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(nil,
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
	[audioButton setImage:image forState:0];
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

#pragma mark Set User Defaults
//*******************************************************
//* setDefaults
//* 
//* 
//*******************************************************
- (void)setDefaults {
	NSString *one = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.keithandthegirl.com/1.txt"] encoding:NSASCIIStringEncoding error:nil];
	
	if (one.intValue == 1) {
		//NSLog(@"Defaults Set");
		if ([userDefaults boolForKey:@"StartStream"]) {
			[userDefaults setBool:NO forKey:@"StartStream"];
			//NSLog(@"Launch Stream");
			[self audioButtonPressed:self];
			[[Beacon shared] startSubBeaconWithName:@"streaming autoresumed" timeSession:NO];
		}
	} else {
		[userDefaults setBool:NO forKey:@"StartStream"];
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"NO INTERNET CONNECTION"
							  message:@"This Application requires an active internet connection. Please connect to wifi or cellular data network for full application functionality." 
							  delegate:nil
							  cancelButtonTitle:@"Continue" 
							  otherButtonTitles:nil];
		[alert show];
		[alert autorelease];
	}
	nameField.text = [userDefaults objectForKey:@"nameField"];
	locField.text = [userDefaults objectForKey:@"locField"];
	if ([[userDefaults objectForKey:@"comField"] isEqualToString: @""]) {
		comField.text = @"Comment";
	} else {
		comField.text = [userDefaults objectForKey:@"comField"];
	}
}

- (void)createNotificationForTermination { 
	//NSLog(@"createNotificationTwo"); 
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleTerminationNotification:) 
	 name:@"ApplicationWillTerminate" 
	 object:nil]; 
}

-(void)handleTerminationNotification:(NSNotification *)pNotification { 
	//NSLog(@"On Air View received message = %@",(NSString*)[pNotification object]);
	if (streamer) {
		[userDefaults setBool:YES forKey:@"StartStream"];
	}
	[userDefaults setObject:(NSString *)nameField.text forKey:@"nameField"];
	[userDefaults setObject:(NSString *)locField.text forKey:@"locField"];
	[userDefaults setObject:(NSString *)comField.text forKey:@"comField"];
	[userDefaults synchronize];
}

#pragma mark Volume Slider
//*******************************************************
//* drawVolumeSlider
//* 
//* 
//*******************************************************
- (void)drawVolumeSlider {
	MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:volumeSliderContainer.bounds];
	UIView *volumeViewSlider;
	
	[volumeSliderContainer addSubview:volumeView];
	
	for (UIView *view in [volumeView subviews]) if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) volumeViewSlider = view;
	
	[(UISlider *)volumeViewSlider setMinimumTrackImage:[[UIImage imageNamed:@"leftslide.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[(UISlider *)volumeViewSlider setMaximumTrackImage:[[UIImage imageNamed:@"rightslide.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
	
	for (UIView *view in [volumeSliderContainer subviews]) [view removeFromSuperview];
	
	volumeView.backgroundColor = [UIColor clearColor];
	volumeSliderContainer.backgroundColor = [UIColor clearColor];
	[volumeSliderContainer addSubview:volumeView];
	
	[volumeView release];
}

#pragma mark Feedback
//*******************************************************
//* feedBackPressed
//* 
//* When Submit Feedback button is pressed
//* a string is constructed from the name,
//* location and comment fields and sent to
//* attackwork via a post request
//* The contents of the string are url encoded
//* and illegal characters like & are duped out
//* for safe characters
//* After comment is submitted comField.text is
//* blanked
//*******************************************************
- (IBAction)feedbackButtonPressed:(id)sender {
	[[Beacon shared] startSubBeaconWithName:@"feedback sent" timeSession:NO];
	sanitizeField *cleaner = [[sanitizeField alloc] init];
	NSString *namePrefix = @"Name=";
	NSString *name;
	if ([cleaner stringCleaner:nameField.text] != nil) {
		name = [cleaner stringCleaner:nameField.text];
	} else {
		name = @"";
	}
	NSString *locPrefix = @"&Location=";
	NSString *location;
	if ([cleaner stringCleaner:locField.text] != nil) {
		location = [cleaner stringCleaner:locField.text];
	} else {
		location = @"";
	}
	NSString *comment;
	if ([cleaner stringCleaner:comField.text] != nil) {
		comment = [cleaner stringCleaner:comField.text];
	} else {
		comment = @"";
	}
	NSString *comPrefix = @"&Comment=";
	NSString *submitButton = @"&ButtonSubmit=Send+Comment";
	NSString *hiddenVoxbackId = @"&HiddenVoxbackId=3&HiddenMixerCode=IEOSE";
	[cleaner release];
	
	NSString *myRequestString = [namePrefix stringByAppendingString:name];
	myRequestString = [myRequestString stringByAppendingString:locPrefix];
	myRequestString = [myRequestString stringByAppendingString:location];
	myRequestString = [myRequestString stringByAppendingString:comPrefix];
	myRequestString = [myRequestString stringByAppendingString:comment];
	myRequestString = [myRequestString stringByAppendingString:submitButton];	
	myRequestString = [myRequestString stringByAppendingString:hiddenVoxbackId];
	
	namePrefix = nil;
	name = nil;
	locPrefix = nil;
	location = nil;
	comPrefix = nil;
	comment = nil;
	submitButton = nil;
	hiddenVoxbackId = nil;
	
	NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[ myRequestString length]];
	NSMutableURLRequest *request = [[ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: @"http://www.attackwork.com/Voxback/Comment-Form-Iframe.aspx" ] ]; 
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:myRequestData];
	
	[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	myRequestString = nil;
	
	comField.text = @"";
	
	[request release];
}

//*******************************************************
//* setFeedbackButtonImage
//* 
//* 
//*******************************************************
- (void)setFeedbackButtonImage {
	UIImage *feedButtonImage = [UIImage imageNamed:@"feedButtonNormal.png"];
	UIImage *normal = [feedButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	UIImage *feedButtonHighlightedImage = [UIImage imageNamed:@"feedButtonPressed.png"];
	UIImage *highlight = [feedButtonHighlightedImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	[feedbackButton setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[feedbackButton setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
}

//*******************************************************
//* textFieldDoneEditing
//* 
//* Dismiss keyboard when done is pressed
//*******************************************************
- (IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

//*******************************************************
//* textViewDoneEditing
//* 
//* Dismiss keyboard when background is clicked
//*******************************************************
- (IBAction)textViewDoneEditing:(id)sender {
	[nameField resignFirstResponder];
	[locField resignFirstResponder];
	[comField resignFirstResponder];
}

//*******************************************************
//* handleUITextViewTextDidBeginEditingNotification
//*
//* When TextView sends DidBeginEditing Notification
//* set value of text to blank
//* If string in comField matches the comField 
//* value stored in userDefaults and is not
//* "Comment" do not clear
//*******************************************************
- (void)handleUITextViewTextDidBeginEditingNotification:(NSNotification *)aNotification {
	/*if ([comField.text isEqualToString: [userDefaults objectForKey:@"comField"]]) {
		if ([comField.text isEqualToString: @"Comment"] ) {
			comField.text = @"";
		} else {
			return;
		}
	} else {
		comField.text = @"";
	}*/
	
	if ([comField.text isEqualToString: @"Comment"] ) {
		comField.text = @"";
	} else {
		return;
	}
	
}

#pragma mark Phone Button
//*******************************************************
//* phoneButtonPressed
//* Launch phone app to call show
//* Sets user defaults to restart stream when call
//* is complete
//*******************************************************
- (IBAction)phoneButtonPressed:(id)sender {
	[[Beacon shared] startSubBeaconWithName:@"phone in" timeSession:NO];
	if (streamer) {
		[userDefaults setBool:YES forKey:@"StartStream"];
		[userDefaults synchronize];
	}
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:+16465028682"]];
}

//*******************************************************
//* infoSheet
//* 
//* launch an alert sheet with a 
//* short explanation of the application
//*******************************************************
- (IBAction)infoSheet:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Keith and The Girl"
						  message:@"This is for anyone into hearing and learning about the Keith and The Girl show on the go. Listen live, check upcoming live events, watch KATGtv video episodes, see show notes and pictures, and much more. Take a look around, and enjoy." 
						  delegate:nil
						  cancelButtonTitle:@"Continue" 
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark Live Show Feed Indicator
//*******************************************************
//* setTimer
//*
//* Create and start timer 
//* for updating live feed indicator
//*******************************************************
- (void)setFeedStatusTimer {
	// Repeating timer to update feed
	feedTimer = [NSTimer scheduledTimerWithTimeInterval: 180.0
												 target: self
											   selector: @selector(feedTimer:)
											   userInfo: nil
												repeats: YES];
}

//*******************************************************
//* feedStatusAutoPool
//*
//* 
//*******************************************************
- (void)feedStatusAutoPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self pollFeedStatus];
	[ pool release ];
}

//*******************************************************
//* feedTimer
//*
//* Setup code to execute on timer
//*******************************************************
- (void)feedTimer: (NSTimer *) timer {
	[ NSThread detachNewThreadSelector: @selector(feedStatusAutoPool) toTarget: self withObject: nil ];
}

//*******************************************************
//* pollFeedStatus
//*
//* Create and run live feed xml
//*******************************************************
- (void)pollFeedStatus {
	// Create the feed string
	NSString *feedAddress = @"http://www.keithandthegirl.com/feed/show/live";
	
	// Select the xPath to parse against
	NSString *xPath = @"//root";
	
	// Call the grabRSSFeed function with the feedAddress
	// string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:xPath];
	
	feedAddress = nil;
	xPath = nil;
	
	NSMutableArray *feedEntries = [[NSMutableArray alloc] initWithArray:[feed entries]];
	
	[feed release];
	
	int feedEntryIndex = 0;
	NSString *feedStatusString;
	NSString *feedStatus = nil;
	if ([feedEntries count] > 0) {
		feedStatusString = [[feedEntries objectAtIndex: feedEntryIndex] objectForKey: @"OnAir"];
		int feedStatusInt = [feedStatusString intValue];
		feedStatusString = nil;
		if(feedStatusInt == 0) {
			feedStatus = @"Not Live";
		} else if(feedStatusInt == 1) {
			feedStatus = @"Live";
		} else {
			feedStatus = @"Unknown";
		}
	} else {
		[feedEntries release];
		return;
	}
	
	statusText.text = feedStatus;
	feedStatus = nil;
	
	[feedEntries release];
}

#pragma mark Next Live Show Indicator
//*******************************************************
//* setNextShowTimer
//*
//* Create and start timer 
//* for updating next show countdown
//*******************************************************
- (void)setNextShowTimer {
	// Repeating timer to update feed
	showTimer = [NSTimer scheduledTimerWithTimeInterval: 60.0
												 target: self
											   selector: @selector(showTimer:)
											   userInfo: nil
												repeats: YES];
}

//*******************************************************
//* nextShowAutoPool
//*
//* 
//*******************************************************
- (void)nextShowAutoPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self pollNextShow];
	[ pool release ];
}

//*******************************************************
//* handleTimer
//*
//* Setup code to execute on timer
//*******************************************************
- (void)showTimer: (NSTimer *) timer {
	[ NSThread detachNewThreadSelector: @selector(nextShowAutoPool) toTarget: self withObject: nil ];
}

//*******************************************************
//* pollNextShow
//*
//* Create and run live feed xml
//*******************************************************
- (void)pollNextShow {
	NSMutableArray *feedEntries = nil;
	if (timeSince > 0) {
		if (timeSince >= 60) {
			timeSince = timeSince - 60;
		}
		
		int d = timeSince / 86400;
		int h = timeSince / 3600 - d * 24;
		int m = timeSince / 60 - d * 1440 - h * 60;
		//int s = timeSince % 60;
		
		days.text = [[NSString alloc] initWithFormat:@"%d",d];
		hours.text = [[NSString alloc] initWithFormat:@"%d",h];
		minutes.text = [[NSString alloc] initWithFormat:@"%d",m];
	} else {
		// Change the feed string
		NSString *feedAddress = @"http://www.keithandthegirl.com/feed/event/?order=datereverse";
		NSString *xPath = @"//Event";
		// Call the grabRSSFeed function with the above
		// string as a parameter
		grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:(NSString *)xPath];
		
		feedAddress = nil;
		xPath = nil;
		
		feedEntries = [[NSMutableArray alloc] initWithArray:[feed entries]];
		
		[feed release];
		
		if (feedEntries.count == 0) {
			[feedEntries release];
			return;
		}
		
		// Evaluate the contents of feed for classification and add results into list
		
		NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle: NSDateFormatterLongStyle];
		[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
		[formatter setDateFormat: @"MM/dd/yyyy HH:mm zzz"];
		[formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
		
		int feedEntryIndex = [feedEntries count] - 1;
		
		NSString *feedTitle = [[feedEntries objectAtIndex: feedEntryIndex] 
							   objectForKey: @"Title"];
		
		timeSince = -1;
		
		BOOL match1 = [feedTitle rangeOfString:@"Live Show" options:NSCaseInsensitiveSearch].location != NSNotFound;
		BOOL match2 = timeSince > 0;
		BOOL match3 = [feedTitle rangeOfString:@"No Live Show" options:NSCaseInsensitiveSearch].location != NSNotFound;
		
		while ( !(match1 && match2) || match3 ) {
			feedTitle = [[feedEntries objectAtIndex: feedEntryIndex] 
						 objectForKey: @"Title"];
			
			NSString *feedTime = [[feedEntries objectAtIndex: feedEntryIndex] 
								  objectForKey: @"StartDate"];
			
			NSTimeZone *EST = [NSTimeZone timeZoneWithName:(NSString *)@"America/New_York"];
			
			if ([EST isDaylightSavingTime]) {
				feedTime = [feedTime stringByAppendingString:@" EDT"];
			} else {
				feedTime = [feedTime stringByAppendingString:@" EST"];
			}
			
			NSDate *eventTime = [formatter dateFromString: feedTime];
			
			timeSince = [eventTime timeIntervalSinceNow];
			
			match1 = [feedTitle rangeOfString:@"Live Show" options:NSCaseInsensitiveSearch].location != NSNotFound;
			match2 = timeSince > 0;
			match3 = [feedTitle rangeOfString:@"No Live Show" options:NSCaseInsensitiveSearch].location != NSNotFound;
			
			feedEntryIndex = feedEntryIndex - 1;
		}
		
		[formatter release];
		
		int d = timeSince / 86400;
		int h = timeSince / 3600 - d * 24;
		int m = timeSince / 60 - d * 1440 - h * 60;
		//int s = timeSince % 60;
		
		days.text = [[NSString alloc] initWithFormat:@"%d",d];
		hours.text = [[NSString alloc] initWithFormat:@"%d",h];
		minutes.text = [[NSString alloc] initWithFormat:@"%d",m];
		
		NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
		NSString * feedFilePath = [documentsPath stringByAppendingPathComponent: @"feed.plist"];
		
		NSMutableArray *feedPack = [[NSMutableArray alloc] initWithCapacity:2];
		NSDate *now = [NSDate date];
		[feedPack addObject:feedEntries];
		[feedPack addObject:now];
		
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath: feedFilePath]) {
			[fm removeItemAtPath: feedFilePath error: NULL];
		}
		
		[feedPack writeToFile: feedFilePath atomically: YES];
		[feedPack release];
	}
	
	[feedEntries release];
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
//* dealloc
//* 
//* 
//*******************************************************
- (void)dealloc {
	[audioButton release];
	[volumeSliderContainer release];
	[feedbackButton release];
	[nameField release];
	[locField release];
	[comField release];
	[callButton release];
	[super dealloc];
}

@end