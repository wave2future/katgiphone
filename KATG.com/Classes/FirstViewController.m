//
//  FirstViewController.m
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

#import "FirstViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import "grabRSSFeed.h"
#import "sanitizeField.h"

@implementation FirstViewController

// Set up interface for sending and receiving data from fields and labels
// Feed Status
@synthesize statusText;
// Feedback Fields
@synthesize nameField;
@synthesize locField;
@synthesize comField;

//*******************************************************
//* UITextViewTextDidBeginEditingNotification
//*
//* When TextView send DidBeginEditing Notification
//* set value of text to blank
//* This is not currently working
//*******************************************************
- (void)UITextViewTextDidBeginEditingNotification:(NSNotification*)aNotification {
	comField.text = @"";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
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
} // 

//*******************************************************
//* buttonPressed
//*
//* 
//*******************************************************
- (IBAction)buttonPressed:(id)sender {
	if (!streamer) // If the streamer is not active, activate stream and iniate button spin and image change
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
	else // If the streamer is active, deactivate stream and change button image
	{
		[button.layer removeAllAnimations];
		[streamer stop];
	}
} //

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
} //

//*******************************************************
//* feedButtonPressed
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
- (IBAction)feedButtonPressed:(id)sender {
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
} // Submit Feedback

//*******************************************************
//* handleTimer
//*
//* Setup code to execute on timer
//*******************************************************
- (void) handleTimer: (NSTimer *) timer {
	[self pollFeed];
} // Code to execute on a timer

//*******************************************************
//* viewDidLoad
//* 
//* 
//*******************************************************
- (void)viewDidLoad {
	// Loads Play button for audioStream
	UIImage *image = [UIImage imageNamed:@"playButton.png"];
	[self setButtonImage:image];
	
	// Set update timer for live feed xml
	[self setTimer];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey:@"StartStream"]) {
		[userDefaults setBool:NO forKey:@"StartStream"];
		[self buttonPressed:self]; //Replace with actual IBAction for button
	}
}

- (IBAction)phoneButtonPressed:(id)sender {
	if (streamer) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setBool:YES forKey:@"StartStream"];
		[userDefaults synchronize];
	}
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:+16465028682"]];
}

//*******************************************************
//* viewDidAppear
//*
//* 
//*******************************************************
- (void)viewDidAppear:(BOOL)animated {
	
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
			feedStatus = @"????";
		}
	} else {
		feedStatus = @"????";
	}

	statusText.text = feedStatus;
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
	// One Time timer to set up feed status when app launches
	NSTimer *shortTimer; // This is almost definitely the wrong way to do this
	shortTimer = [NSTimer scheduledTimerWithTimeInterval: 3.0
											 target: self
										   selector: @selector(handleTimer:)
										   userInfo: nil
											repeats: NO];
}

- (IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
} // Dismiss keyboard when done is pressed

- (IBAction)textViewDoneEditing:(id)sender {
	[nameField resignFirstResponder];
	[locField resignFirstResponder];
	[comField resignFirstResponder];
}// Dismiss keyboard when background is clicked

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
} // Sets up autorotate support (in this case none)

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
} // Does something I'm sure

- (void)dealloc {
	[super dealloc];
} // Release objects to save memory

@end
