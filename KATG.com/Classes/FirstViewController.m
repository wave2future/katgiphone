//
//  FirstViewController.m
//  KATG.com
//
//  Created by Doug Russell on 4/5/09.
//  Copyright Radio Dysentery 2009. All rights reserved.
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

@implementation FirstViewController

// Set up interface for sending and receiving data from fields and labels
@synthesize nameField;
@synthesize locField;
@synthesize comField;
@synthesize statusText;

// Launch NIB (The GUI file)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

// 
- (void)setButtonImage:(UIImage *)image {
	[button.layer removeAllAnimations];
	[button
	 setImage:image
	 forState:0];
}

// 
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

//
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
	if (finished)
	{
		[self spinButton];
	}
}

// 
- (IBAction)buttonPressed:(id)sender {
	if (!streamer)
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
	else
	{
		[button.layer removeAllAnimations];
		[streamer stop];
	}
}

// 
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
}

// 
-(void) grabRSSFeed:(NSString *)feedAddress {
	
    // Initialize the feedEntries MutableArray that we declared in the header
    feedEntries = [[NSMutableArray alloc] init];	
	
    // Convert the supplied URL string into a usable URL object
    NSURL *url = [NSURL URLWithString: feedAddress];
	
    // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
    // object that actually grabs and processes the RSS data
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    //resultNodes = [rssParser nodesForXPath:@"//KATGFeed" error:nil]; //My Feed
	resultNodes = [rssParser nodesForXPath:@"//KATGGadget" error:nil]; //Grundle's Feed

    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		
        // Create a temporary MutableDictionary to store the items fields in, which will eventually end up in feedEntries
        NSMutableDictionary *feedItem = [[NSMutableDictionary alloc] init];
		
        // Create a counter variable as type "int"
        int counter;
		
        // Loop through the children of the current  node
        for(counter = 0; counter < [resultElement childCount]; counter++) {
			
            // Add each field to the feedItem Dictionary with the node name as key and node value as the value
            [feedItem setObject:[[resultElement childAtIndex:counter] stringValue] forKey:[[resultElement childAtIndex:counter] name]];
        }
		
        // Add the feedItem to the global feedEntries Array so that the view can access it.
        [feedEntries addObject:[feedItem copy]];
    }
}

// Submit Feedback
- (IBAction)feedButtonPressed:(id)sender {
	NSString *namePrefix = @"Name=";
	NSString *name = nameField.text;
	NSString *locPrefix = @"&Location=";
	NSString *location = locField.text;
	NSString *comment = comField.text;
	NSString *comPrefix = @"&Comment=";
	NSString *submitButton = @"&ButtonSubmit=Send+Comment";
//	NSString *hiddenVoxbackId = @"&HiddenVoxbackId=43&HiddenMixerCode=T2XPE";
	NSString *hiddenVoxbackId = @"&HiddenVoxbackId=3&HiddenMixerCode=IEOSE";
	
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

- (void) handleTimer: (NSTimer *) timer {
	// Create the feed string
    //NSString *feedAddress = @"http://dysenteryevents.com/katg/Feed.xml";
    NSString *feedAddress = @"http://www.thegrundleonline.com/xml/KATGGadget.xml";
	// Call the grabRSSFeed function with the above
    // string as a parameter
    [self grabRSSFeed:feedAddress];
	
	int feedEntryIndex = 0;
	NSString *feedStatusString = [[feedEntries objectAtIndex: feedEntryIndex] objectForKey: @"FeedStatus"];
	int feedStatusInt = [feedStatusString intValue];
	NSString *feedStatus = nil;
	if(feedStatusInt == 0) {
		feedStatus = @"Not Live";
	} else if(feedStatusInt == 1) {
		feedStatus = @"Live";
	} else {
		feedStatus = @"Unknown";
	}
	
	statusText.text = feedStatus;
} // handleTimer

- (void)viewDidLoad {
	// Loads Play button for audioStream
	UIImage *image = [UIImage imageNamed:@"playButton.png"];
	[self setButtonImage:image];
	
	// Create the feed string
    //NSString *feedAddress = @"http://dysenteryevents.com/katg/Feed.xml";
    NSString *feedAddress = @"http://www.thegrundleonline.com/xml/KATGGadget.xml";
	// Call the grabRSSFeed function with the above
    // string as a parameter
    [self grabRSSFeed:feedAddress];
	
	int feedEntryIndex = 0;
	NSString *feedStatusString = [[feedEntries objectAtIndex: feedEntryIndex] objectForKey: @"FeedStatus"];
	int feedStatusInt = [feedStatusString intValue];
	NSString *feedStatus = nil;
	if(feedStatusInt == 0) {
		feedStatus = @"Not Live";
	} else if(feedStatusInt == 1) {
		feedStatus = @"Live";
	} else {
		feedStatus = @"Unknown";
	}
	
	statusText.text = feedStatus;
	
	NSTimer *timer;
	
	timer = [NSTimer scheduledTimerWithTimeInterval: 180.0
											 target: self
										   selector: @selector(handleTimer:)
										   userInfo: nil
											repeats: YES];
}

// Dismiss keyboard when done is pressed (technically it just releases control from the front most GUI object)
- (IBAction)textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
}

// Dismiis keyboard when background is clicked
- (IBAction)textViewDoneEditing:(id)sender {
	[nameField resignFirstResponder];
	[locField resignFirstResponder];
	[comField resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Does something I'm sure
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

// Release objects to save memory
- (void)dealloc {
	[nameField release];
	[locField release];
	[comField release];
	[super dealloc];
}

@end
