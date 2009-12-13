//
//  TwtViewController.m
//  KATG.com
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
	//*******************************************************
	//* Set up the date formatter - has to use 10.4 format for iPhone
	//*******************************************************
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle: NSDateFormatterLongStyle];
	[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
	[formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
	
	//*******************************************************
	//* Clear out the old tweets
	//*******************************************************
	[tweets removeAllObjects];
		
	[formatter setDateFormat: @"EEE MMM dd HH:mm:ss +0000 yyyy"];
	NSURL *url = [NSURL URLWithString:searchString];
	NSString *queryResult = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];	
	
	NSRange range = [queryResult rangeOfString:@"\"error\":\"Not authorized\""];
	if (range.location == NSNotFound) {
		SBJSON *jsonParser = [[SBJSON alloc] init];
		NSError *error;
		NSArray *queryDict = [jsonParser objectWithString: queryResult error: &error];
		
		//*******************************************************
		//* Process the results 1 tweet at a time
		//*******************************************************
		NSDictionary *tweet;
		for (tweet in queryDict) {
			NSDictionary *user = [tweet objectForKey:@"user"];
			NSString * from = [user objectForKey: @"screen_name"];
			NSString *text = [tweet objectForKey: @"text"];
			
			NSDate * createdAt = [formatter dateFromString: [tweet objectForKey: @"created_at"]];
			int timeSince;
			NSString *interval = @"s";
			if (createdAt != nil) {
				//*******************************************************
				//* Calculate the time & units since creation
				//*******************************************************
				timeSince = -[createdAt timeIntervalSinceNow];
				
				//*******************************************************
				//* Convert from GMT to local time
				//*******************************************************
				NSInteger seconds = [[NSTimeZone defaultTimeZone] secondsFromGMT];
				timeSince -= seconds;
			} else {
				timeSince = 0;
			}
			
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
			NSString *imageURLString = [user objectForKey: @"profile_image_url"];
			
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
	}
	
	[queryResult release];
	[formatter release];
	
	[self.activityIndicator stopAnimating];
	
	[self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
	
	self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)reloadTableView {
	[self.tableView reloadData];
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
	
	if (tweets.count == 0) {
		static NSString *CellIdentifier = @"TweetCell";
		TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[TweetCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.lblTitle.text = @"No Tweets Here";
		cell.lblSince.text = @"";
		cell.lblFrom.text  = @"";
		UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.776 green:(CGFloat).875 blue:(CGFloat)0.776 alpha:(CGFloat)1.0];
		cell.lblTitle.backgroundColor = color1;
		cell.lblSince.backgroundColor = color1;
		cell.lblFrom.backgroundColor = color1;
		cell.backgroundView.backgroundColor = color1;
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"postCellBackground60.png"]];
		return cell;
	}
	
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
	
	[converter release];
	
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
		
		[url release];
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
	//[[UIAccelerometer sharedAccelerometer] release];
}

- (void)dealloc {
	[iconDict release];
	[tweets release];
	[isURL release];
	[urlDict release];
    [super dealloc];
}

@end

