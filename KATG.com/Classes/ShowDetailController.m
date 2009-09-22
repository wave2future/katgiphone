//
//  ShowDetailController.m
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

#import "ShowDetailController.h"
#import "MREntitiesConverter.h"
#import "grabRSSFeed.h"

@implementation ShowDetailController

BOOL Stream = NO;
int imageNumber = 0;

NSMutableArray *imageArray;

@synthesize button, segmentedControl, imageView, imageButton, activityIndicator, imageActivityIndicator, lblTitle, lblImage, txtNotes, showTitle, showLink, showNotes, feedAddress, moviePlayer;

- (void)viewDidLoad {
	showLink = @"";
	
	self.navigationItem.title = @"Show Details";
	
	self.setButtonImage;
	
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
	
	imageArray = [[NSMutableArray alloc] initWithCapacity:10];
					
	[self pollFeed];
	[self updateView];
}

- (void)setButtonImage {
	UIImage *feedButtonImage = [UIImage imageNamed:@"feedButtonNormal.png"];
	UIImage *normal = [feedButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	UIImage *feedButtonHighlightedImage = [UIImage imageNamed:@"feedButtonPressed.png"];
	UIImage *highlight = [feedButtonHighlightedImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	[button setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
	
}

#pragma mark Feed
- (void)pollFeed {
	// Create the feed string
	NSString *xPath = @"//Show";
	// Call the grabRSSFeed function with the above string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:xPath];
	// Fill feedEntries with the results of parsing the show feed
	NSArray *feedEntries = [NSArray arrayWithArray:[feed entries]];
	[feed release];
		
	if (feedEntries.count != 0) {
		NSDictionary *feedEntry = [feedEntries objectAtIndex:0];
		showTitle = [feedEntry objectForKey: @"Title"];
		showLink = [[feedEntry objectForKey: @"FileUrl"] retain];
		showNotes = [feedEntry objectForKey: @"Detail"];
	} else {
		showTitle = @"Unable To Download Show";
		showLink = @"NULL";
		showNotes = @"NULL";
	}
	
	[self.activityIndicator stopAnimating];
}

- (void)updateView {
	CGRect rect = CGRectMake(5, 125, 315, 230);
	
	txtNotes = [[[UITextView alloc] initWithFrame:rect] autorelease];
	txtNotes.textColor = [UIColor blackColor];
	txtNotes.backgroundColor = [UIColor clearColor]; 
	
	txtNotes.dataDetectorTypes = UIDataDetectorTypeAll;
	
	txtNotes.editable = NO;
	txtNotes.font = [UIFont systemFontOfSize:15.0];
	
	[self.view addSubview:txtNotes];
	
	lblTitle.text = showTitle;
	
	if (![showNotes isEqualToString:@"NULL"]) {
		MREntitiesConverter *cleaner = [[MREntitiesConverter alloc] init];
		NSString *body = @" • ";
		body = [body stringByAppendingString:[showNotes stringByReplacingOccurrencesOfString:@"\n" withString:@"\n • "]];
		txtNotes.text = [cleaner convertEntitiesInString:body];
		[cleaner release];
	} else {
		txtNotes.text = @" • No Show Notes";
	}
	
	if ([showLink isEqualToString:@"NULL"]) {
		[button setHidden:YES];
		[button setEnabled:NO];
	}
}

//*******************************************************
//* buttonPressed
//* 
//* 
//*******************************************************
- (IBAction)buttonPressed:(id)sender {
	if (Stream) {
		NSURL *movieURL = [[NSURL alloc] initWithString:[self showLink]];
		[self playMovie:(NSURL *)movieURL];
	} else {
		NSString *alertMessage = @"Streaming shows over cellular network is disabled, enable Wifi to stream";
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Past Shows Streaming Disabled"
							  message:alertMessage 
							  delegate:nil
							  cancelButtonTitle:@"Continue" 
							  otherButtonTitles:nil];
		[alert show];
		[alert autorelease];
	}
}

- (IBAction)segmentedController:(id)sender {
	if ([segmentedControl selectedSegmentIndex] == 0) {
		[imageView setHidden:YES];
		[txtNotes setHidden:NO];
		[imageButton setEnabled:NO];
		[imageButton setHidden:YES];
	} else if ([segmentedControl selectedSegmentIndex] == 1) {
		[imageActivityIndicator startAnimating];
		[NSThread detachNewThreadSelector:@selector(autoPool) toTarget:self withObject:nil];
		[imageView setHidden:NO];
		[txtNotes setHidden:YES];
	}
}

#pragma mark Feed
- (void)autoPool {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self pollImageFeed];
	[pool release];
}

- (void)pollImageFeed {
	// Create the feed string
	NSString *imageFeedAddress = @"http://getitdownonpaper.com/katg/Pics.xml";
	NSString *xPath = @"//Picture";
	// Call the grabRSSFeed function with the above string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:imageFeedAddress XPath:xPath];
	// Fill feedEntries with the results of parsing the show feed
	NSArray *feedEntries = [NSArray arrayWithArray:[feed entries]];
	[feed release];
	
	for (NSDictionary *entry in feedEntries) {
		NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[entry objectForKey:@"URL"]]];
		UIImage *im = [UIImage imageWithData:imageData];
		NSDictionary *imDic = [NSDictionary dictionaryWithObjectsAndKeys:im, @"image", 
										[entry objectForKey:@"Description"], @"description", nil];
		[imageArray addObject:imDic];
	}
	[imageActivityIndicator stopAnimating];
	[imageButton setEnabled:YES];
	[imageButton setHidden:NO];
	if (imageArray.count > 0) {
		[imageView setImage:[[imageArray objectAtIndex:0] objectForKey:@"image"]];
		[lblImage setText:[[imageArray objectAtIndex:0] objectForKey:@"description"]];
	}
}

- (IBAction)imageButton:(id)sender {
	if (imageArray.count > 0) {
		if (imageNumber != [imageArray count] - 1) {
			imageNumber += 1;
		} else {
			imageNumber = 0;
		}
		[imageView setImage:[[imageArray objectAtIndex:imageNumber] objectForKey:@"image"]];
		[lblImage setText:[[imageArray objectAtIndex:imageNumber] objectForKey:@"description"]];
	}
}

- (BOOL)Stream {
	return Stream;
}

- (void)setStream:(BOOL)stream {
	Stream = stream;
}

//*******************************************************
//* playMovie
//* 
//* 
//*******************************************************
-(void)playMovie:(NSURL *)movieURL {
	// Initialize a movie player object with the specified URL
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
	if (mp) {
		// save the movie player object
		self.moviePlayer = mp;
		[mp release];
		[activityIndicator startAnimating];
	}
}

//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	//NSLog(@"Movie Preload Notification");
	
	[activityIndicator stopAnimating];
	
	[self.moviePlayer play];
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO]; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[self.moviePlayer stop];
}

- (void)dealloc {
	[showLink release];
	[imageArray release];
	[super dealloc];
}

@end