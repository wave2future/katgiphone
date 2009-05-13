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
#import <QuartzCore/CoreAnimation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "grabRSSFeed.h"
#import "sanitizeField.h"

static BOOL streaming;

@implementation OnAirViewController

// Set up interface for sending and receiving data from fields and labels
// Audio Streamer Play Button
@synthesize button;
// 
@synthesize moviePlayer;
// Volume Slider
@synthesize volumeSliderContainer;
// Call in button
@synthesize callButton;
// Feed Status
@synthesize statusText;
// Feedback Button
@synthesize feedBack;
// Feedback Fields
@synthesize nameField;
@synthesize locField;
@synthesize comField;


#pragma mark System Stuff
//*******************************************************
//* initWithNibName
//* 
//* 
//*******************************************************
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

//*******************************************************
//* viewDidLoad
//* 
//* 
//*******************************************************
- (void)viewDidLoad {
	// Loads Play button for audioStream
	UIImage *image = [UIImage imageNamed:@"playButton.png"];
	[self setButtonImage:image];
	
	// Draw Volume Slider
	[self drawVolumeSlider];
	
	// Set Phone Button Image
	[self setPhoneButtonImage];
	
	// Set Feedback Button Image
	[self setFeedBackImage];
	
	// Set update timer for live feed xml
	[self setTimer];
	
	// Auto start audiostreamer when returning from phone call
	userDefaults = [NSUserDefaults standardUserDefaults];
	[self setDefaults];
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleNotification:) 
	 name:@"UITextViewTextDidBeginEditingNotification" 
	 object:nil];
	
	// Register to receive a notification that the movie is now in memory and ready to play
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(moviePreloadDidFinish:) 
	 name:MPMoviePlayerContentPreloadDidFinishNotification 
	 object:nil];
	
	streaming = NO;
	
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
	
	[ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: nil ];
}

#pragma mark Audio Streamer
//*******************************************************
//* buttonPressed
//* 
//* 
//*******************************************************
- (IBAction)buttonPressed:(id)sender {
	//NSURL *movieURL = [[NSURL alloc] initWithString: @"http://liveshow.keithandthegirl.com:8004/"];
	NSURL *movieURL = [[NSURL alloc] initWithString: @"http://141.217.119.35:8005/"];
	[self playMovie:movieURL];
}

//*******************************************************
//* playMovie
//* 
//* 
//*******************************************************
-(void)playMovie:(NSURL *)movieURL {
	if (streaming) {
		self.moviePlayer = nil;
		streaming = NO;
		[self setButtonImage:[UIImage imageNamed:@"playButton.png"]];
	} else {
		// Initialize a movie player object with the specified URL
		MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
		if (mp)
		{
			// save the movie player object
			self.moviePlayer = mp;
			[mp release];
			
			streaming = YES;
			
			[self setButtonImage:[UIImage imageNamed:@"loadingButton.png"]];
			
			[self spinButton];
		}
	}
}

//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	
	NSLog(@"Movie Preload Notification");
	
	[self setButtonImage:[UIImage imageNamed:@"stopButton.png"]];
}

//*******************************************************
//* setButtonImage
//* 
//* Sets image for AudioStreamer play button
//*******************************************************
- (void)setButtonImage:(UIImage *)image {
	[button.layer removeAllAnimations];
	[button
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

#pragma mark Volume Slider
//*******************************************************
//* 
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

#pragma mark Phone Button
//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (void)setDefaults {
	if ([userDefaults boolForKey:@"StartStream"]) {
		[userDefaults setBool:NO forKey:@"StartStream"];
		[self buttonPressed:self];
	}
	nameField.text = [userDefaults objectForKey:@"nameField"];
	locField.text = [userDefaults objectForKey:@"locField"];
	if ([[userDefaults objectForKey:@"comField"] isEqualToString: @""]) {
		comField.text = @"Comment";
	} else {
		comField.text = [userDefaults objectForKey:@"comField"];
	}
}

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (IBAction)phoneButtonPressed:(id)sender {
	if (streaming) {
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

#pragma mark Live Show Feed Indicator
//*******************************************************
//* autoPool
//*
//* 
//*******************************************************
- (void)autoPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self pollFeed];
	[ pool release ];
}

//*******************************************************
//* setTimer
//*
//* Create and start timer 
//* for updating live feed indicator
//*******************************************************
- (void)setTimer {
	// Repeating timer to update feed
	NSTimer *timer;
	timer = [NSTimer scheduledTimerWithTimeInterval: 180.0
											 target: self
										   selector: @selector(handleTimer:)
										   userInfo: nil
											repeats: YES];
}

//*******************************************************
//* handleTimer
//*
//* Setup code to execute on timer
//*******************************************************
- (void)handleTimer: (NSTimer *) timer {
	[ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: nil ];
}

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

//*******************************************************
//* pollFeed
//*
//* Create and run live feed xml
//*******************************************************
- (void)pollFeed {
	// Create the feed string
	NSString *feedAddress = @"http://www.keithandthegirl.com/feed/show/live";
    //NSString *feedAddress = @"http://www.thegrundleonline.com/xml/KATGGadget.xml";
	
	// Select the xPath to parse against
	NSString *xPath = @"//root";
	
	// Call the grabRSSFeed function with the feedAddress
	// string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:xPath];
	feedEntries = [feed entries];
	[feed release];
	
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
- (IBAction)feedBackPressed:(id)sender {
	sanitizeField *cleaner = [[sanitizeField alloc] init];
	NSString *namePrefix = @"Name=";
	NSString *name = [cleaner stringCleaner:nameField.text];
	NSString *locPrefix = @"&Location=";
	NSString *location = [cleaner stringCleaner:locField.text];
	NSString *comment = [cleaner stringCleaner:comField.text];
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
//* setFeedBackImage
//* 
//* 
//*******************************************************
- (void)setFeedBackImage {
	UIImage *feedButtonImage = [UIImage imageNamed:@"feedButtonNormal.png"];
	UIImage *normal = [feedButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	UIImage *feedButtonHighlightedImage = [UIImage imageNamed:@"feedButtonPressed.png"];
	UIImage *highlight = [feedButtonHighlightedImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	[feedBack setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[feedBack setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
}

//*******************************************************
//* textFieldDoneEditing
//* 
//* 
//*******************************************************
- (IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
} // Dismiss keyboard when done is pressed

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
//* UITextViewTextDidBeginEditingNotification
//*
//* When TextView sends DidBeginEditing Notification
//* set value of text to blank
//*******************************************************
- (void)handleNotification:(NSNotification *)aNotification {
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

#pragma mark More System Stuff
//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (void)viewDidDisappear:(BOOL)animated {
	if (streaming) {
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
