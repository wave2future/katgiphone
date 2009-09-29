//
//  TweetViewController.m
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
#import "TweetViewController.h"
#import "TwtViewController.h"
#import "WebViewController.h"
#import "TableViewController.h"
#import "TweetCell.h"
#import "grabRSSFeed.h"
#import "MREntitiesConverter.h"
#import "extractURL.h"
#import "RegexKitLite.h"


#define kAccelerometerFrequency 15

static BOOL otherTweets;

@implementation TweetViewController

@synthesize navigationController, activityIndicator;

//*******************************************************
//* viewDidLoad:
//*
//* 
//* 
//*
//*******************************************************
- (void)viewDidLoad {
	//NSLog(@"Tweet View Did Load");
    [super viewDidLoad];
	
	self.navigationItem.title = @"The Twitters";
	
	tweets = [[NSMutableArray alloc] initWithCapacity: 100];
	iconDict = [[NSMutableDictionary alloc] init];
	isURL = [[NSMutableDictionary alloc] init];
	urlDict = [[NSMutableDictionary alloc] init];
	
	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	NSString *iconDictFilePath = [documentsPath stringByAppendingPathComponent: @"icons.plist"];
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: iconDictFilePath]) {
		[iconDict addEntriesFromDictionary: [NSDictionary dictionaryWithContentsOfFile: iconDictFilePath]];
	}
	
	if (iconDict.count >= 1000) {
		[iconDict removeAllObjects];
	}
	
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
	
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.bounds = CGRectMake(0, 0, 33.0, 29.0);
	[button setImage:[UIImage imageNamed:@"othButPlus.png"] forState:UIControlStateNormal];
	[button setImage:[UIImage imageNamed:@"othButPlusHighlighted.png"] forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(othTweets) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
											  initWithCustomView:button]
											  autorelease];
	self.navigationItem.leftBarButtonItem.enabled = NO;
	
	[self createNotificationForTermination];
}

//*******************************************************
//* 
//* 
//* 
//*******************************************************
- (void)refTweets:(id)sender{
	[isURL removeAllObjects];
	[urlDict removeAllObjects];
	[self.activityIndicator startAnimating];
	[self pollFeed];
}

//*******************************************************
//* 
//* 
//* 
//*******************************************************
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
//* 
//* 
//* 
//*******************************************************
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
	
	if ( otherTweets ) {
		searchString = [searchString stringByAppendingString: @"+OR+from%3AKaTGShowAlert+OR+%3Akeithmalley+OR+keithandthegirl+OR+katg+OR+%22keith+and+the+girl%22"];
	}
	
	searchString = [searchString stringByAppendingFormat: @"&rpp=%i", 20];
	
	NSURL *url = [NSURL URLWithString:searchString];
	NSString *queryResult = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];	
	
	SBJSON *jsonParser = [[SBJSON alloc] init];
	NSError *error;
	NSDictionary *queryDict = [jsonParser objectWithString: queryResult error: &error];
	NSArray *results = [queryDict objectForKey: @"results"];
	//*******************************************************
	//* Clear out the old tweets
	//*******************************************************
	[tweets removeAllObjects];
	
	//*******************************************************
	//* Set up the date formatter - has to use 10.4 format for iPhone
	//*******************************************************
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle: NSDateFormatterLongStyle];
	[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
	[formatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss +0000"];
	[formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
	
	//*******************************************************
	//* Process the results 1 tweet at a time
	//*******************************************************
	NSDictionary * tweet;
	
	for (tweet in results) {
		NSString * from = [tweet objectForKey: @"from_user"];
		NSString * text = [tweet objectForKey: @"text"];
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
	
	//***************************************************
	//* Add a disclosure indicator if the text contains web stuff
	//***************************************************
	
	NSString *regexString1 = @"\\b(https?://)(?:(\\S+?)(?::(\\S+?))?@)?([a-zA-Z0-9\\-.]+)(?::(\\d+))?((?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
	NSString *regexString2 = @"@([0-9a-zA-Z_]+)";
	NSString *index = [NSString stringWithFormat:@"%d", indexPath.row];
	if ([cell.lblTitle.text isMatchedByRegex:regexString1] ||
		[cell.lblTitle.text isMatchedByRegex:regexString2]) {
		
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
//* tweet text, and add 10 to that height for the 
//* cell height. Minimum height is 80.
//*************************************************
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *text = [[tweets objectAtIndex: indexPath.row] objectForKey: @"text"];
	CGSize maxTextSize = CGSizeMake(220.0, 200.0);
	CGSize textSize = [text sizeWithFont: [UIFont systemFontOfSize: 12] constrainedToSize: maxTextSize];
	CGFloat height = MAX((textSize.height + 10.0f), 80.0f);
	return height;
}

//*******************************************************
//* tableView:didSelectRowAtIndexPath
//* 
//* 
//*******************************************************
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *index = [NSString stringWithFormat:@"%d", indexPath.row];
	if ( [[isURL objectForKey: index] isEqualToString:@"YES"] ) {
		NSString *tweetURL = [urlDict objectForKey: [NSString stringWithFormat:@"%d", indexPath.row]];
		extractURL *extractor = [[extractURL alloc] init];
		NSArray *urls = [extractor newURLList:tweetURL];
		NSArray *twts = [extractor newTWTList:tweetURL];
		if (otherTweets) {
			NSMutableArray *TWTS = [[NSMutableArray alloc] initWithArray:twts];
			[TWTS addObject:[[tweets objectAtIndex: indexPath.row] objectForKey: @"from_user"]];
			[twts release];
			twts = [[NSArray alloc] initWithArray:TWTS];
			[TWTS release];
		}
		[extractor release];
		if ([urls count] + [twts count] > 1) {
			TableViewController *viewController = [[TableViewController alloc] initWithNibName:@"TableView" bundle:[NSBundle mainBundle]];
			viewController.urlList = urls;
			viewController.twtList = twts;
			[[self navigationController] pushViewController:viewController animated:YES];
			[viewController release];
		} else if ([urls count] == 1 && [twts count] == 0) {		
			//WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
			WebViewController *viewController = [[WebViewController alloc] init];
			NSString *urlAddress = [urls objectAtIndex:0];
			viewController.urlAddress = urlAddress;
			[[self navigationController] pushViewController:viewController animated:YES];
			[viewController release];
		} else if ([urls count] == 0 && [twts count] == 1) {
			TwtViewController *viewController = [[TwtViewController alloc] initWithNibName:@"TableView" bundle:[NSBundle mainBundle]];
			NSString *user = [NSString stringWithFormat:@"http://twitter.com/statuses/user_timeline/%@.json", [twts objectAtIndex:0]];
			viewController.searchString = user;
			[[self navigationController] pushViewController:viewController animated:YES];
			[viewController release];
		}
		[urls release];
		[twts release];
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

- (void)handleTerminationNotification:(NSNotification *)pNotification { 
	//NSLog(@"Tweet View received message = %@",(NSString*)[pNotification object]);
	[self saveData];
}

- (void) saveData {
	//NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	NSString *iconsFilePath = [documentsPath stringByAppendingPathComponent: @"icons.plist"];
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: iconsFilePath]) 
		[fm removeItemAtPath: iconsFilePath error: NULL];
	[iconDict writeToFile: iconsFilePath atomically: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[tweets removeAllObjects];
	NSString * from = @"KATGAPP";
	NSString * text = @"Low Memory Warning";
	NSString * since = @"1";
	NSString * imageURLString = @"http";
	NSDictionary * tweetDict = [NSDictionary dictionaryWithObjectsAndKeys: from, @"from_user", 
								text, @"text", 
								since, @"since",
								imageURLString, @"profile_image_url", nil];
	[tweets addObject:tweetDict];
	UIImage * tweetIcon = [UIImage imageNamed:@"othButPlus.png"];
	[iconDict setObject: tweetIcon forKey: @"http"];
	[self.tableView reloadData];
}

- (void)dealloc {
	[iconDict release];
	[tweets release];
	[isURL release];
	[urlDict release];
    [super dealloc];
}

@end

