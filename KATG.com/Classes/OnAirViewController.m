//
//  OnAirViewController.m
//  KATG.com
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
#import "EventsViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "grabRSSFeed.h"
#import "sanitizeField.h"


// Integer value for countdown to next live show
static int timeSince;

@implementation OnAirViewController

// Set up interface for sending and receiving data from fields and labels
// Audio Streamer Play/Stop Button
@synthesize audioButton;
// Volume Slider, this view contains the actual MPVolumeView as a subview
@synthesize volumeSliderContainer;
// Call in button
@synthesize callButton;
// Live Show Feed Status Indicator
@synthesize statusText;
// Next Live Show Countdown
@synthesize days, hours, minutes;
// Submit Feedback Button
@synthesize feedbackButton;
// Feedback Fields
@synthesize nameField, locField, comField;

#pragma mark System Stuff
//*******************************************************
//* viewDidLoad
//* 
//* 
//*******************************************************
- (void)viewDidLoad {
	// Loads Play button for audioStream
	UIImage *image = [UIImage imageNamed:@"playButton.png"];
	[self setAudioButtonImage:image];
	
	// Draw Volume Slider
	[self drawVolumeSlider];
	
	// Set Phone Button Image
	[self setPhoneButtonImage];
	
	// Set Feedback Button Image
	[self setFeedbackButtonImage];
	
	// Auto start audiostreamer if it was playing when the app last exited
	userDefaults = [NSUserDefaults standardUserDefaults];
	[self setDefaults];
	
	// Notification Center for handling Text View Did Begin Editing. 
	// In this case it clears the Text View when editing begins unless it is
	// saved text from a previous session.
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleUITextViewTextDidBeginEditingNotification:) 
	 name:@"UITextViewTextDidBeginEditingNotification" 
	 object:nil];
	
	if ([self isDataSourceAvailable] == NO) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"NO INTERNET CONNECTION"
							  message:@"This Application requires an active internet connection. Please connect to wifi or cellular data network for full application functionality." 
							  delegate:nil
							  cancelButtonTitle:@"Continue" 
							  otherButtonTitles:nil];
		[alert show];
		return;
	}
	
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

#pragma mark Connectivity
//*******************************************************
//* isDataSourceAvailable
//* 
//* 
//*******************************************************
- (BOOL)isDataSourceAvailable {
    static BOOL checkNetwork = YES;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        checkNetwork = NO;
        
        Boolean success;    
        const char *host_name = "keithandthegirl.com";
		
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
        CFRelease(reachability);
    }
    return _isDataSourceAvailable;
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

#pragma mark Set User Defaults
//*******************************************************
//* setDefaults
//* 
//* 
//*******************************************************
- (void)setDefaults {
	if ([userDefaults boolForKey:@"StartStream"]) {
		[userDefaults setBool:NO forKey:@"StartStream"];
		[self audioButtonPressed:self];
	}
	nameField.text = [userDefaults objectForKey:@"nameField"];
	locField.text = [userDefaults objectForKey:@"locField"];
	if ([[userDefaults objectForKey:@"comField"] isEqualToString: @""]) {
		comField.text = @"Comment";
	} else {
		comField.text = [userDefaults objectForKey:@"comField"];
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
	if (streamer) {
		[userDefaults setBool:YES forKey:@"StartStream"];
		[userDefaults synchronize];
	}
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:+16465028682"]];
}

//*******************************************************
//* setPhoneButtonImage
//* 
//* 
//*******************************************************
- (void)setPhoneButtonImage {
	UIImage *feedButtonImage = [UIImage imageNamed:@"feedButtonNormal.png"];
	UIImage *normal = [feedButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	UIImage *feedButtonHighlightedImage = [UIImage imageNamed:@"feedButtonPressed.png"];
	UIImage *highlight = [feedButtonHighlightedImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	[callButton setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[callButton setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
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
	sanitizeField *cleaner = [[sanitizeField alloc] init];
	NSString *namePrefix = @"Name=";
	NSString *name = nil;
	if ([cleaner stringCleaner:nameField.text] != nil) {
		name = [cleaner stringCleaner:nameField.text];
	} else {
		name = @"";
	}
	NSString *locPrefix = @"&Location=";
	NSString *location = nil;
	if ([cleaner stringCleaner:locField.text] != nil) {
		location = [cleaner stringCleaner:locField.text];
	} else {
		location = @"";
	}
	NSString *comment = nil;
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
	
	NSData *myRequestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[ myRequestString length]];
	NSMutableURLRequest *request = [[ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: @"http://www.attackwork.com/Voxback/Comment-Form-Iframe.aspx" ] ]; 
	[ request setHTTPMethod: @"POST" ];
	[ request setHTTPBody: myRequestData ];
	
	[ NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
	
	comField.text = @"";
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
	if ([comField.text isEqualToString: [userDefaults objectForKey:@"comField"]]) {
		if ([comField.text isEqualToString: @"Comment"] ) {
			comField.text = @"";
		} else {
			return;
		}
	} else {
		comField.text = @"";
	}
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
	NSTimer *timer;
	timer = [NSTimer scheduledTimerWithTimeInterval: 180.0
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
//* handleTimer
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
    //NSString *feedAddress = @"http://www.thegrundleonline.com/xml/KATGGadget.xml";
	
	// Select the xPath to parse against
	NSString *xPath = @"//root";
	
	// Call the grabRSSFeed function with the feedAddress
	// string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:xPath];
	feedEntries = [feed entries];
	
	int feedEntryIndex = 0;
	NSString *feedStatusString;
	NSString *feedStatus = nil;
	if ([feedEntries count] > 0) {
		feedStatusString = [[feedEntries objectAtIndex: feedEntryIndex] objectForKey: @"OnAir"];
		int feedStatusInt = [feedStatusString intValue];
		if(feedStatusInt == 0) {
			feedStatus = @"Not Live";
		} else if(feedStatusInt == 1) {
			feedStatus = @"Live";
		} else {
			feedStatus = @"Unknown";
		}
	} else {
		feedStatus = @"Unknown";
	}
	
	statusText.text = feedStatus;
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
	NSTimer *timer;
	timer = [NSTimer scheduledTimerWithTimeInterval: 60.0
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
		feedEntries = [feed entries];
		[feed release];
		
		// Evaluate the contents of feed for classification and add results into list
		
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_0
		
		NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle: NSDateFormatterLongStyle];
		[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
		[formatter setDateFormat: @"MM/dd/yyyy HH:mm zzz"];
		
#elif __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_3_0
		
		NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle: NSDateFormatterLongStyle];
		[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
		[formatter setDateFormat: @"MM/dd/yyyy HH:mm"];
		NSTimeZone *EST = [NSTimeZone timeZoneWithName:(NSString *)@"America/New_York"];
		[formatter setTimeZone:(NSTimeZone *)EST];
		
#endif
		
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
			
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_0
			
			NSTimeZone *EST = [NSTimeZone timeZoneWithName:(NSString *)@"America/New_York"];
			
			if ([EST isDaylightSavingTime]) {
				feedTime = [feedTime stringByAppendingString:@" EDT"];
			} else {
				feedTime = [feedTime stringByAppendingString:@" EST"];
			}
			
#endif
			
			NSDate *eventTime = [formatter dateFromString: feedTime];
			
			timeSince = [eventTime timeIntervalSinceNow];
			
			match1 = [feedTitle rangeOfString:@"Live Show" options:NSCaseInsensitiveSearch].location != NSNotFound;
			match2 = timeSince > 0;
			match3 = [feedTitle rangeOfString:@"No Live Show" options:NSCaseInsensitiveSearch].location != NSNotFound;
			
			feedEntryIndex = feedEntryIndex - 1;
		}
		
		int d = timeSince / 86400;
		int h = timeSince / 3600 - d * 24;
		int m = timeSince / 60 - d * 1440 - h * 60;
		//int s = timeSince % 60;
		
		days.text = [[NSString alloc] initWithFormat:@"%d",d];
		hours.text = [[NSString alloc] initWithFormat:@"%d",h];
		minutes.text = [[NSString alloc] initWithFormat:@"%d",m];
		
		NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
		NSString * feedFilePath = [documentsPath stringByAppendingPathComponent: @"feed.save"];
		
		NSMutableArray *feedPack = [[NSMutableArray alloc] initWithCapacity:2];
		NSDate *now = [NSDate date];
		[feedPack addObject:feedEntries];
		[feedPack addObject:now];
		
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath: feedFilePath]) 
			[fm removeItemAtPath: feedFilePath error: NULL];
		
		[feedPack writeToFile: feedFilePath atomically: YES];
	}
}

#pragma mark More System Stuff
//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (void)viewDidDisappear:(BOOL)animated {
	if (streamer) {
		[userDefaults setBool:YES forKey:@"StartStream"];
	}
	[userDefaults setObject:(NSString *)nameField.text forKey:@"nameField"];
	[userDefaults setObject:(NSString *)locField.text forKey:@"locField"];
	[userDefaults setObject:(NSString *)comField.text forKey:@"comField"];
	[userDefaults synchronize];
}

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
} // Sets up autorotate support (in this case none)

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
} // Does something I'm sure

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (void)dealloc {
	[super dealloc];
} // Release objects to save memory

@end