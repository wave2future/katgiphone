//
//  TweetViewController.m
//  KATG.com
//  

#import <JSON/JSON.h>
#import "TweetViewController.h"
#import "WebViewController.h"
#import "TableViewController.h"
#import "TweetCell.h"
#import "grabRSSFeed.h"
#import "MREntitiesConverter.h"
#import "extractURL.h"


static BOOL otherTweets;
#define kAccelerometerFrequency 15

@implementation TweetViewController

@synthesize navigationController;
@synthesize activityIndicator;

//*******************************************************
//* viewDidLoad:
//*
//* Set row height, you could add buttons to the
//* navigation controller here.
//*
//*******************************************************
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"The Twitters";
		
	tweets = [[NSMutableArray alloc] initWithCapacity: 100];
	iconDict = [[NSMutableDictionary alloc] init];
	isURL = [[NSMutableDictionary alloc] init];
	urlDict = [[NSMutableDictionary alloc] init];
	
	// Create a 'right hand button' that is a activity Indicator
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	self.activityIndicator = [[UIActivityIndicatorView alloc]
							  initWithFrame:frame];
	[self.activityIndicator sizeToFit];
	self.activityIndicator.autoresizingMask =
	(UIViewAutoresizingFlexibleLeftMargin |
	 UIViewAutoresizingFlexibleRightMargin |
	 UIViewAutoresizingFlexibleTopMargin |
	 UIViewAutoresizingFlexibleBottomMargin);
	
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] 
									initWithCustomView:self.activityIndicator];
	loadingView.target = self;
	self.navigationItem.rightBarButtonItem = loadingView;
	
	otherTweets = NO;
	
	[self.activityIndicator startAnimating];
	[ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: nil ];
	
	/*refButton = [[[UIBarButtonItem alloc]
				  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
				  target:self
				  action:@selector(refTweets:)] autorelease];
    self.navigationItem.rightBarButtonItem = refButton;*/
	
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.bounds = CGRectMake(0, 0, 33.0, 29.0);
	[button setImage:[UIImage imageNamed:@"othButPlus.png"] forState:UIControlStateNormal];
	[button setImage:[UIImage imageNamed:@"othButPlusHighlighted.png"] forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(othTweets) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
											  initWithCustomView:button]
											  autorelease];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"ViewDidAppear");
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void)refTweets:(id)sender{
	[isURL removeAllObjects];
	[urlDict removeAllObjects];
	[self.activityIndicator startAnimating];
	[self pollFeed];
}

- (void)othTweets {
	[isURL removeAllObjects];
	[urlDict removeAllObjects];
	if ( otherTweets ) {
		otherTweets = NO;
		[button setImage:[UIImage imageNamed:@"othButPlus.png"] forState:UIControlStateNormal];
		[button setImage:[UIImage imageNamed:@"othButPlusHighlighted.png"] forState:UIControlStateHighlighted];
	} else {
		otherTweets = YES;
		[button setImage:[UIImage imageNamed:@"othButMinus.png"] forState:UIControlStateNormal];
		[button setImage:[UIImage imageNamed:@"othButMinusHighlighted.png"] forState:UIControlStateHighlighted];
	}
	[ NSThread detachNewThreadSelector: @selector(activityPool) toTarget: self withObject: nil ];
	[self pollFeed];
}

- (void)autoPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self pollFeed];
	[ pool release ];
}

- (void)activityPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self.activityIndicator startAnimating];
	[ pool release ];
}

//*******************************************************
//* pollFeed
//*
//* Get Tweets
//*******************************************************
- (void) pollFeed {
	NSString *searchString = @"http://search.twitter.com/search.json?q=from%3Akeithandthegirl+OR+from%3AKeithMalley";
	
	if ( otherTweets ) // Changed Code this line
		searchString = [searchString stringByAppendingString: @"+OR+keithandthegirl+OR+katg+OR+%22keith+and+the+girl%22"];
	
	searchString = [searchString stringByAppendingFormat: @"&rpp=%i", 20]; // Changed Code this line
	
	NSURL *url = [NSURL URLWithString:searchString];
	NSString *queryResult = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];	
	
	SBJSON *jsonParser = [[SBJSON alloc] init];
	NSError *error;
	NSDictionary *queryDict = [jsonParser objectWithString: queryResult error: &error];
	NSArray *results = [queryDict objectForKey: @"results"];
	//*******************************************************
	//* Clear out the old tweets and icons
	//*******************************************************
	[tweets removeAllObjects];
	
	if (iconDict.count >= 1000)
		[iconDict removeAllObjects];
	
	//*******************************************************
	//* Set up the date formatter - has to use 10.4 format for iPhone
	//*******************************************************
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle: NSDateFormatterLongStyle];
	[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
	[formatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss +0000"];
	
	//*******************************************************
	//* Process the results 1 tweet at a time
	//*******************************************************
	NSDictionary * tweet;
	
	for (tweet in results) {
		NSString * from = [tweet objectForKey: @"from_user"];
		NSString * text = [tweet objectForKey: @"text"];
		NSDate * createdAt = [formatter dateFromString: [tweet objectForKey: @"created_at"]];
		
		//*******************************************************
		//* Calculate the time & units since creation
		//*******************************************************
		NSString * interval = @"s";
		int timeSince = -[createdAt timeIntervalSinceNow];
		
		//*******************************************************
		//* Convert from GMT to local time
		//*******************************************************
		NSInteger seconds = [[NSTimeZone defaultTimeZone] secondsFromGMT];
		timeSince -= seconds;
		
		if (timeSince > 60) {
			interval = @"m";
			timeSince /= 60;
			
			if (timeSince > 60) {
				interval = @"h";
				timeSince /= 60;
				
				if (timeSince > 24) {
					interval = @"d";
					timeSince /= 24;
					
					if (timeSince > 7) {
						interval = @"w";
						timeSince /= 7;
					}
				}
			}
		}
		
		NSString * since = [NSString stringWithFormat:@"%i%@", timeSince, interval];
		
		//*******************************************************
		//* Check to see if this image URL has been seen (and stored)
		//* already. If not, send an asychronous request for the 
		//* image, and store the necessary info in a CFDictionary with connection
		//* as the key, so we can find it again when the data is received.
		//*******************************************************
		NSString * imageURLString = [tweet objectForKey: @"profile_image_url"];
		
		//*******************************************************
		//* Put everything in a dictionary and add to tweet array
		//*******************************************************
		NSDictionary * tweetDict = [NSDictionary dictionaryWithObjectsAndKeys: from, @"from_user", 
									text, @"text", 
									since, @"since",
									imageURLString, @"profile_image_url", nil];
		[tweets addObject: tweetDict];
		
	}
	
	/*if (tweets.count == 0) {
		NSString * from = @"KATGAPP";
		NSString * text = @"No Internet Connection";
		NSString * since = @"1";
		NSString * imageURLString = @"http";
		NSDictionary * tweetDict = [NSDictionary dictionaryWithObjectsAndKeys: from, @"from_user", 
									text, @"text", 
									since, @"since",
									imageURLString, @"profile_image_url", nil];
		[tweets addObject:tweetDict];
	} */
	
	[jsonParser release];
	[formatter release];
	[queryResult release];
	
	[self.activityIndicator stopAnimating];
	
	[self.tableView reloadData];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    CGFloat shakeThreshold = 1.0;
    static NSInteger shakeCount = 0;
    static NSInteger shakeTimer = 0;
	
    // If we detect a large enough motion in any direction, we increment the shakeCount.
	if (([acceleration x] > shakeThreshold || [acceleration x] < (-1 * shakeThreshold)) || ([acceleration y] > shakeThreshold || [acceleration y] < (-1 * shakeThreshold)) || ([acceleration z] > shakeThreshold || [acceleration z] < (-1 * shakeThreshold))) {
        shakeCount++;
    }
	
    // shakeTimer gets incremented as long as their is a running shakeCount
    if (shakeCount) shakeTimer++;
	
    // If it exceeds 9 (a little more than half a second), the current shake is thrown away.
    if (shakeTimer > 10) {
		NSLog(@"No SHAKER");
		NSLog(@"%d", shakeCount);
        shakeCount = 0;
        shakeTimer = 0;
    }
	
    // If shakeCount reaches 5 within our time limit we consider that a shake.
	if (shakeCount > 6 && shakeTimer < 10 && ![self.activityIndicator isAnimating]) {
		NSLog(@"SHAKER");
		NSLog(@"%d", shakeCount);
		shakeCount = 0; 
        shakeTimer = 0;
        [isURL removeAllObjects];
		[urlDict removeAllObjects];
		[ NSThread detachNewThreadSelector: @selector(activityPool) toTarget: self withObject: nil ];
		[self pollFeed];
    }
}

#pragma mark Table view methodss
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//*******************************************************
//* tableView:numberOfRowsInSection
//*
//*  Customize the number of rows in the table view
//*
//*******************************************************
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tweets.count;
}

//*******************************************************
//* tableView:cellForRowAtIndexPath
//*
//* Customize the appearance of table view cells.
//* Assign icons to event types
//*
//*******************************************************
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TweetCell";
	
	MREntitiesConverter *converter = [[MREntitiesConverter alloc] init];
	
	TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[TweetCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	// Set up the cell...
	cell.lblTitle.text = [converter convertEntitiesInString:[[tweets objectAtIndex: indexPath.row] objectForKey: @"text"]];
	cell.lblSince.text = [[tweets objectAtIndex: indexPath.row] objectForKey: @"since"];
	cell.lblFrom.text =  [[tweets objectAtIndex: indexPath.row] objectForKey: @"from_user"];
	
	cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.92 green:(CGFloat).973 blue:(CGFloat)0.92 alpha:(CGFloat)1.0];
	UIColor *color2 = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.667 alpha:(CGFloat)1.0];
	if (indexPath.row%2 == 0) {
		cell.lblTitle.backgroundColor = color1;
		cell.lblSince.backgroundColor = color1;
		cell.lblFrom.backgroundColor = color1;
		cell.backgroundView.backgroundColor = color1;
	} else {
		cell.lblTitle.backgroundColor = color2;
		cell.lblSince.backgroundColor = color2;
		cell.lblFrom.backgroundColor = color2;
		cell.backgroundView.backgroundColor = color2;
	}
	
	cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(CGFloat)0.72 green:(CGFloat).773 blue:(CGFloat)0.72 alpha:(CGFloat)1.0];
	
	if ([iconDict objectForKey: [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]] == nil) {
		
		NSURL *url = [[NSURL alloc] initWithString:[[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]];
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage * tweetIcon = [UIImage imageWithData:data];
		
		[iconDict setObject: tweetIcon forKey: [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]];
	}
	
	cell.imgSquare.image = [iconDict objectForKey: [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]];
	
	//***************************************************
	//* Add a disclosure indicator if the text contains web stuff
	//***************************************************
	NSString *index = [NSString stringWithFormat:@"%d", indexPath.row]; // Added Code This Line
	if ([cell.lblTitle.text rangeOfString: @"www" options:1].location != NSNotFound ||
		[cell.lblTitle.text rangeOfString: @"http:" options:1].location != NSNotFound ||
		[cell.lblTitle.text rangeOfString: @".com" options:1].location != NSNotFound ||
		[cell.lblTitle.text rangeOfString: @"@" options:1].location != NSNotFound) {
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		[isURL setObject:@"YES" forKey: index];
		[urlDict setObject:cell.lblTitle.text forKey: index];
	}
	
	return cell;
}

//*************************************************
//* tableView:heightForRowAtIndexPath:
//*
//* Get the size of the bounding rectangle for the 
//* tweet text, and add 20 to that height for the 
//* cell height. Minimum height is 46.
//*************************************************
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString * text = [[tweets objectAtIndex: indexPath.row] objectForKey: @"text"];
	CGSize maxTextSize = CGSizeMake(120.0, 200.0);
	CGSize textSize = [text sizeWithFont: [UIFont systemFontOfSize: 12] constrainedToSize: maxTextSize];
	CGFloat height = MAX((textSize.height + 20.0f), 80.0f);
	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *index = [NSString stringWithFormat:@"%d", indexPath.row];
	if ( [[isURL objectForKey: index] isEqualToString:@"YES"] ) {
		NSString *tweetURL = [urlDict objectForKey: [NSString stringWithFormat:@"%d", indexPath.row]];
		extractURL *extractor = [[extractURL alloc] init];
		NSMutableArray *urls = [extractor makeURLList:tweetURL];
		if ([urls count] > 1) {
			TableViewController *viewController = [[TableViewController alloc] initWithNibName:@"TableView" bundle:[NSBundle mainBundle]];
			viewController.list = urls;
			[[self navigationController] pushViewController:viewController animated:YES];
			[viewController release];
		} else {		
			WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
			NSString *urlAddress = [urls objectAtIndex:0];
			viewController.urlAddress = urlAddress;
			[[self navigationController] pushViewController:viewController animated:YES];
			[viewController release];
		}
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[[UIAccelerometer sharedAccelerometer] release];
}

- (void)dealloc {
	[iconDict release];
	[tweets release];
	[isURL release];
	[urlDict release];
    [super dealloc];
}

@end

