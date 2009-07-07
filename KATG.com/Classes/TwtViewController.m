//
//  TwtViewController.m
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

#import <JSON/JSON.h>
#import "TwtViewController.h"
#import "TweetCell.h"
#import "grabRSSFeed.h"
#import "MREntitiesConverter.h"


#define kAccelerometerFrequency 15

static BOOL otherTweets;

@implementation TwtViewController

@synthesize activityIndicator;
@synthesize searchString;

//*******************************************************
//* viewDidLoad:
//*
//* Set row height, you could add buttons to the
//* navigation controller here.
//*
//*******************************************************
- (void)viewDidLoad {
    [super viewDidLoad];
	
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
}

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (void)autoPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self pollFeed];
	[ pool release ];
}

//*******************************************************
//* pollFeed
//*
//* Get Tweets
//*******************************************************
- (void) pollFeed {	
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
	
	if (iconDict.count >= 1000) {
		[iconDict removeAllObjects];
	}
	
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
	
	[jsonParser release];
	[formatter release];
	[queryResult release];
	
	[self.activityIndicator stopAnimating];
	
	[self.tableView reloadData];
	self.navigationItem.leftBarButtonItem.enabled = YES;
}

//*******************************************************
//* 
//* 
//* 
//*******************************************************
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
		//NSLog(@"No SHAKER");
		//NSLog(@"%d", shakeCount);
        shakeCount = 0;
        shakeTimer = 0;
    }
	
    // If shakeCount reaches 5 within our time limit we consider that a shake.
	if (shakeCount > 6 && shakeTimer < 10 && ![self.activityIndicator isAnimating]) {
		//NSLog(@"SHAKER");
		//NSLog(@"%d", shakeCount);
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
	
	UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.776 green:(CGFloat).875 blue:(CGFloat)0.776 alpha:(CGFloat)1.0];
	UIColor *color2 = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.627 alpha:(CGFloat)1.0];
	
	//cell.lblTitle.backgroundColor = [UIColor clearColor];
	cell.lblSince.backgroundColor = [UIColor clearColor];
	
	if (indexPath.row%2 == 0) {
		cell.lblTitle.backgroundColor = color1;
		//cell.lblSince.backgroundColor = color1;
		cell.lblFrom.backgroundColor = color1;
		cell.backgroundView.backgroundColor = color1;
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackground60.png"]];
	} else {
		cell.lblTitle.backgroundColor = color2;
		//cell.lblSince.backgroundColor = color2;
		cell.lblFrom.backgroundColor = color2;
		cell.backgroundView.backgroundColor = color2;
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundDark60.png"]];
	}
	
	cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackgroundSelected60.png"]];
	
	if ([iconDict objectForKey: [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]] == nil) {
		
		NSURL *url = [[NSURL alloc] initWithString:[[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]];
		NSData *data = [NSData dataWithContentsOfURL:url];
		if ([data length] != 0) {
			[iconDict setObject: data forKey: [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]];
		} else {
			data = [NSData dataWithContentsOfFile:@"TweetIconSub.png"];
			[iconDict setObject: data forKey: [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]];
		}
	}
	
	UIImage *tweetIcon = [UIImage imageWithData:[iconDict objectForKey: 
												 [[tweets objectAtIndex: indexPath.row] 
												  objectForKey: @"profile_image_url"]]];
	cell.imgSquare.image = tweetIcon;
	
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
	NSString *text = [[tweets objectAtIndex: indexPath.row] objectForKey: @"text"];
	CGSize maxTextSize = CGSizeMake(220.0, 200.0);
	CGSize textSize = [text sizeWithFont: [UIFont systemFontOfSize: 12] constrainedToSize: maxTextSize];
	CGFloat height = MAX((textSize.height + 10.0f), 80.0f);
	return height;
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

