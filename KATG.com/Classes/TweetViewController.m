//
//  TweetViewController.m
//  KaTGTwitter
//
//  Created by Ashley Mills on 11/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
//

#import "TweetViewController.h"
#import "TweetViewCell.h"
//#import "MainViewController.h"
#import <JSON/JSON.h>
#import "DetailViewController.h"

@implementation TweetViewController

//*******************************************************
//* viewDidLoad:
//*
//*******************************************************
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.navigationItem.title = @"KATG Tweets";
	
	tweets = [[NSMutableArray alloc] initWithCapacity: 100];
	iconDict = [[NSMutableDictionary alloc] init];
	isURL = [[NSMutableDictionary alloc] init];
	urlDict = [[NSMutableDictionary alloc] init];
	
	connections = CFDictionaryCreateMutable(kCFAllocatorDefault,
											0,
											&kCFTypeDictionaryKeyCallBacks,
											&kCFTypeDictionaryValueCallBacks);
		
	addButton = [[[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Other Tweets", @"On")
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(otherTweets:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
	
	refButton = [[[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Update", @"On")
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(refTweets:)] autorelease];
    self.navigationItem.leftBarButtonItem = refButton;
	refButton.enabled = NO;
	addButton.enabled = NO;
}

- (void)refTweets:(id)sender{
	refButton.enabled = NO;
	tweets = [[NSMutableArray alloc] initWithCapacity: 100];
	iconDict = [[NSMutableDictionary alloc] init];
	
	connections = CFDictionaryCreateMutable(kCFAllocatorDefault,
											0,
											&kCFTypeDictionaryKeyCallBacks,
											&kCFTypeDictionaryValueCallBacks);
	[self loadURL];
}

- (void)otherTweets:(id)sender{
	addButton.enabled = NO;
	if (otherTweets == @"YES") {
		otherTweets = @"NO";
	} else {
			otherTweets = @"YES";
	}
	tweets = [[NSMutableArray alloc] initWithCapacity: 100];
	iconDict = [[NSMutableDictionary alloc] init];
	
	connections = CFDictionaryCreateMutable(kCFAllocatorDefault,
											0,
											&kCFTypeDictionaryKeyCallBacks,
											&kCFTypeDictionaryValueCallBacks);
	[self loadURL];
}

//*******************************************************
//* viewDidAppear:
//*
//* Run the search query each time the view loads (?)
//*******************************************************
- (void)viewDidAppear: (BOOL) animated {
	[super viewDidAppear: animated];
	
	[self loadURL];
}

//*******************************************************
//* loadURL
//*
//* Create and run the search URL
//*******************************************************
- (void) loadURL
{
	NSString * searchString = @"http://search.twitter.com/search.json?q=from%3Akeithandthegirl+OR+from%3AKeithMalley";
	
//	if (mainViewController.showOthers.isOn)
	if ( otherTweets == @"YES" )
		searchString = [searchString stringByAppendingString: @"+OR+keithandthegirl+OR+%22keith+and+the+girl%22"];
	
//	searchString = [searchString stringByAppendingFormat: @"&rpp=%i", (int)mainViewController.tweetCount.value];
	searchString = [searchString stringByAppendingFormat: @"&rpp=%i", 20];

	
	NSURL *url = [NSURL URLWithString: searchString];
	
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	NSURLConnection *connection = [NSURLConnection connectionWithRequest: request delegate: self];
	NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableData data], @"data",
										   searchString, @"url", 
										   @"search", @"type", nil];
	
	CFDictionaryAddValue(connections, connection, connectionDict);
}

#pragma mark NSURLConnection delegate methods
//*******************************************************
//* connection:didReceiveResponse:
//*
//* Get ready to receive data
//*******************************************************
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	bytesToLoad = [response expectedContentLength];
	bytesLoaded = 0;
	
}

//*******************************************************
//* connection:didReceiveData:
//*
//* Append incoming data to the existing string
//*******************************************************
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSMutableDictionary * dict = (NSMutableDictionary *)CFDictionaryGetValue(connections, connection);
	NSMutableData *connectionData = [dict objectForKey: @"data"];
	[connectionData appendData: data];
	bytesLoaded += [data length];
}

//*******************************************************
//* connectionDidFinishLoading:
//*
//* All data has arrived, so 
//*******************************************************
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *type = [(NSMutableDictionary *)CFDictionaryGetValue(connections, connection) objectForKey: @"type"];
	
	if ([type isEqualToString: @"search"]) {
		[self processSearchData: [(NSMutableDictionary *)CFDictionaryGetValue(connections, connection) objectForKey: @"data"]];
	} else {
		[self processIconData: (NSMutableDictionary *)CFDictionaryGetValue(connections, connection)];
	}
}

//*******************************************************
//* processSearchData:
//*
//* Parse and store relevant parts of the search query.
//* Submit more requests for icon data if necessary.
//*******************************************************
- (void) processSearchData: (NSMutableData *) data
{
	NSString *queryResult = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	SBJSON *jsonParser = [SBJSON new];
	
	NSError * error;
	NSDictionary * queryDict = [jsonParser objectWithString: queryResult error: &error];
	NSArray * results = [queryDict objectForKey: @"results"];
	
	//******************************************
	//* Set up the date formatter - has to use 10.4 format for iPhone
	//******************************************
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle: NSDateFormatterLongStyle];
	[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
	[formatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss +0000"];
	
	//******************************************
	//* Process the results 1 tweet at a time
	//******************************************
	NSDictionary * tweet;
	
	for (tweet in results) {
		NSString * from = [tweet objectForKey: @"from_user"];
		NSString * text = [tweet objectForKey: @"text"];
		NSString * imageURL = [tweet objectForKey: @"profile_image_url"];
		NSDate * createdAt = [formatter dateFromString: [tweet objectForKey: @"created_at"]];
		
		//******************************************
		//* Calculate the time & units since creation
		//******************************************
		NSString * interval = @"s";
		int timeSince = -[createdAt timeIntervalSinceNow];
		
		//******************************************
		//* Convert from GMT to local time
		//******************************************
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
		NSURL *iconURL = [NSURL URLWithString: imageURL];
		
		if ([iconDict objectForKey: imageURL] == nil) {
			NSURLRequest *request = [NSURLRequest requestWithURL: iconURL];
			NSURLConnection *connection = [NSURLConnection connectionWithRequest: request delegate: self];
			NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableData data], @"data",
												   imageURL, @"url", 
												   @"icon", @"type", nil];
			
			CFDictionaryAddValue(connections, connection, connectionDict);
			
			[iconDict setObject: [NSNull null] forKey: imageURL];
		}
		
		
		//******************************************
		//* Put everything in a dictionary and add to tweet array
		//******************************************
		
		NSDictionary * tweetDict = [NSDictionary dictionaryWithObjectsAndKeys: from, @"from_user", 
									text, @"text", 
									since, @"since",
									imageURL, @"profile_image_url", nil];
		
		[tweets addObject: tweetDict];
		
	}
	
	//******************************************
	//* Finally reload the table view
	//******************************************
	[tv reloadData];
	refButton.enabled = YES;
	addButton.enabled = YES;
}

//*******************************************************
//* processIconData:
//*
//*
//*
//*******************************************************
- (void) processIconData: (NSMutableDictionary *) dict
{
	NSData *iconData = [dict objectForKey: @"data"];
	NSString *iconURL = [dict objectForKey: @"url"]; 
	[iconDict setObject: iconData forKey: iconURL];
	
	NSArray * visibleCells = [self.tableView visibleCells];
	TweetViewCell * cell;
	
	for (cell in visibleCells) {
		if ([cell.imageURL isEqualToString: iconURL]) {
			cell.iconImage = [UIImage imageWithData: [iconDict objectForKey: iconURL]];
			[cell setNeedsDisplay];
		}
	}
}

#pragma mark UITableViewDataSource methods
//*************************************************
//* tableView:numberOfRowsInSection:
//*
//*************************************************
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tweets.count;
}

//*************************************************
//* tableView:cellForRowAtIndexPath:
//*
//* Set the cell text etc, and show a disclosure
//* inidicator if tweet contains a url
//*************************************************
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetViewCell *cell = (TweetViewCell *)[aTableView dequeueReusableCellWithIdentifier: @"TweetViewCell"];
	
    if (cell == nil) {
        cell = [self createNewTweetCellFromNib];
    }
	
    cell.tweetText = [[tweets objectAtIndex: indexPath.row] objectForKey: @"text"];
	cell.sinceText = [[tweets objectAtIndex: indexPath.row] objectForKey: @"since"];
	cell.fromText = [[tweets objectAtIndex: indexPath.row] objectForKey: @"from_user"];
	cell.imageURL = [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"];
	
	if ([iconDict objectForKey: cell.imageURL] != [NSNull null]) {
		cell.iconImage = [UIImage imageWithData: [iconDict objectForKey: cell.imageURL]];
	}
	NSString *index = [NSString stringWithFormat:@"%d", indexPath.row];
	
	if ([cell.tweetText rangeOfString: @"www" options:1].location != NSNotFound ||
		[cell.tweetText rangeOfString: @"http:" options:1].location != NSNotFound ||
		[cell.tweetText rangeOfString: @".com" options:1].location != NSNotFound) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[isURL setObject: @"YES" forKey: index];
		[urlDict setObject:cell.tweetText forKey:index];
	}
	
	CGRect cellFrame = cell.frame;
	cellFrame.size.height = [self tableView: aTableView heightForRowAtIndexPath: indexPath];
	cell.frame = cellFrame;
	
	[cell setNeedsDisplay];
    return (UITableViewCell *)cell;
}


//*************************************************
//* tableView:cellForRowAtIndexPath:
//*
//* Set the cell text etc, and show a disclosure
//* inidicator if tweet contains a url
//*************************************************
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * text = [[tweets objectAtIndex: indexPath.row] objectForKey: @"text"];
	CGSize maxTextSize = CGSizeMake(220.0, 200.0);
	CGSize textSize = [text sizeWithFont: [UIFont systemFontOfSize: 12] constrainedToSize: maxTextSize];
	CGFloat height = MAX((textSize.height + 20.0f), 46.0f);
	return height;
}

//*************************************************
//* createNewTweetCellFromNib
//*
//*************************************************
- (TweetViewCell *) createNewTweetCellFromNib
{
	NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed: @"TweetViewCell"
														  owner: self options: nil];
	TweetViewCell * tweetCell = nil;
	NSObject * nibItem;
	for (nibItem in nibContents) {
		if ([nibItem class] == [TweetViewCell class]) {
			tweetCell = (TweetViewCell *) nibItem;
			break;
		}
	}
	
	return tweetCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ( [isURL objectForKey: [NSString stringWithFormat:@"%d", indexPath.row]] == @"YES" ) {
		WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
		
		NSString *tweetURL = [urlDict objectForKey: [NSString stringWithFormat:@"%d", indexPath.row]];
		
		NSString *urlAddress = nil;
		
		if ([tweetURL rangeOfString: @"http:" options:1].location != NSNotFound) {
			int tweetLength = tweetURL.length;
			int urlStart = [tweetURL rangeOfString: @"http:" options:1].location;
			NSRange tweetRange = {urlStart, tweetLength-urlStart};
			NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
			NSRange urlEndRange = [tweetURL rangeOfCharacterFromSet:charSet options:1 range:tweetRange];
			int urlEnd = urlEndRange.location;
			if (urlEnd > tweetLength ) {
				urlEnd = tweetLength;
			}
			int urlLength = urlEnd - urlStart;
			urlAddress = [tweetURL substringWithRange:NSMakeRange( urlStart, urlLength ) ];
		} else if ( [tweetURL rangeOfString: @"www." options:1].location != NSNotFound ) {
			int tweetLength = tweetURL.length;
			int urlStart = [tweetURL rangeOfString: @"www." options:1].location;
			NSRange tweetRange = {urlStart, tweetLength-urlStart};
			NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
			NSRange urlEndRange = [tweetURL rangeOfCharacterFromSet:charSet options:1 range:tweetRange];
			int urlEnd = urlEndRange.location;
			if (urlEnd > tweetLength ) {
				urlEnd = tweetLength;
			}
			int urlLength = urlEnd - urlStart;
			urlAddress = @"http://";
			NSString *urlStub = [tweetURL substringWithRange:NSMakeRange( urlStart, urlLength ) ];
			urlAddress = [urlAddress stringByAppendingString:urlStub];
		} else if ( [tweetURL rangeOfString: @".com" options:1].location != NSNotFound ) {
			int tweetLength = tweetURL.length;
			int comStart = [tweetURL rangeOfString: @".com" options:1].location;
			NSRange startRange = {0, comStart};
			NSRange endRange = {comStart, tweetLength - comStart};
			NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
			NSRange urlStartRange = [tweetURL rangeOfCharacterFromSet:charSet options:5 range:startRange];
			NSRange urlEndRange = [tweetURL rangeOfCharacterFromSet:charSet options:1 range:endRange];
			int urlStart = urlStartRange.location + 1;
			if (urlStart < 0) {
				urlStart = 0;
			}
			int urlEnd = urlEndRange.location;
			if (urlEnd > tweetLength) {
				urlEnd = tweetLength;
			}
			int urlLength = urlEnd - urlStart;
			urlAddress = @"http://";
			NSString *urlStub = [tweetURL substringWithRange:NSMakeRange( urlStart, urlLength ) ];
			urlAddress = [urlAddress stringByAppendingString:urlStub];
		}
		
		viewController.urlAddress = urlAddress;
		[[self navigationController] pushViewController:viewController animated:YES];
		[viewController release];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

- (void)dealloc {
	[iconDict release];
	[tweets release];
    [super dealloc];
}


@end

