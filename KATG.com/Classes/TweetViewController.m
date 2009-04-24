//
//  TweetViewController.m
//  KATG.com
//
//  Created by Ashley Mills on 11/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
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

#import "TweetViewController.h"
#import "TweetViewCell.h"
#import <JSON/JSON.h>
#import "MREntitiesConverter.h"

@implementation TweetViewController

#pragma mark UIView methods
//*******************************************************
//* viewDidLoad:
//*
//* Allocate storage for tweets and icons
//*
//*******************************************************
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	// Added Code
	self.navigationItem.title = @"KATG Tweets";
	// End Added Code
	
	tweets = [[NSMutableArray alloc] initWithCapacity: 100];
	iconDict = [[NSMutableDictionary alloc] init];
	urlDict = [[NSMutableDictionary alloc] init];
	
	connections = CFDictionaryCreateMutable(kCFAllocatorDefault,
											0,
											&kCFTypeDictionaryKeyCallBacks,
											&kCFTypeDictionaryValueCallBacks);
	// Added Code
	isURL = [[NSMutableDictionary alloc] init];
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
	// End Added Code
}

- (void)refTweets:(id)sender{
	refButton.enabled = NO;
	addButton.enabled = NO;
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
	refButton.enabled = NO;
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
//* Run the search query each time the view loads
//*******************************************************
- (void)viewDidAppear: (BOOL) animated {
	[super viewDidAppear: animated];
	
	[self loadData];
	//*******************************************************
	//* Run the search query
	//*******************************************************
	[self loadURL];
	
}

//*******************************************************
//* viewDidDisappear:
//*
//* Save the tweets and icons for next time
//*******************************************************
- (void)viewDidDisappear: (BOOL) animated {
	[super viewDidDisappear: animated];
	
	[self saveData];
}

#pragma mark Load and Save data methods

//*******************************************************
//* loadData:
//*
//* Load tweets and icons
//*******************************************************
- (void) loadData
{
	//*******************************************************
	//* Clear out the old tweets and icons
	//*******************************************************
	[tweets removeAllObjects];
	
	NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString * tweetsFilePath = [documentsPath stringByAppendingPathComponent: @"tweets.save"];
	NSString * iconsFilePath = [documentsPath stringByAppendingPathComponent: @"icons.save"];
	
	//*******************************************************
	//* Load the saved tweets and icons and reload the table
	//*******************************************************
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: tweetsFilePath]) 
		[tweets addObjectsFromArray: [NSArray arrayWithContentsOfFile: tweetsFilePath]];
	
	if ([fm fileExistsAtPath: iconsFilePath]) 
		[iconDict addEntriesFromDictionary: [NSDictionary dictionaryWithContentsOfFile: iconsFilePath]];
	
	[tv reloadData];
	
}

//*******************************************************
//* saveData:
//*
//* Save tweet1s and icons
//*******************************************************
- (void) saveData
{
	NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString * tweetsFilePath = [documentsPath stringByAppendingPathComponent: @"tweets.save"];
	NSString * iconsFilePath = [documentsPath stringByAppendingPathComponent: @"icons.save"];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: tweetsFilePath]) 
		[fm removeItemAtPath: tweetsFilePath error: NULL];
	if ([fm fileExistsAtPath: iconsFilePath]) 
		[fm removeItemAtPath: iconsFilePath error: NULL];
	
	[tweets writeToFile: tweetsFilePath atomically: YES];
	[iconDict writeToFile: iconsFilePath atomically: YES];
	
}

//*******************************************************
//* loadURL
//*
//* Create and run the search URL
//*******************************************************
- (void) loadURL
{
	NSString * searchString = @"http://search.twitter.com/search.json?q=from%3Akeithandthegirl+OR+from%3AKeithMalley";
	
	if ( otherTweets == @"YES" ) // Changed Code this line
		searchString = [searchString stringByAppendingString: @"+OR+keithandthegirl+OR+katg+OR+%22keith+and+the+girl%22"];
	
	searchString = [searchString stringByAppendingFormat: @"&rpp=%i", 20]; // Changed Code this line
	
	NSURL *url = [NSURL URLWithString: searchString];
	
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	NSURLConnection *connection = [NSURLConnection connectionWithRequest: request delegate: self];
	
	//*******************************************************
	//* Create a dictionary with mutable data for the incoming data,
	//* the search url, and a type (search in this case).
	//*******************************************************
	NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
										   [NSMutableData data], @"data",
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
	// Start animating UIActivityIndicatorView here
}

//*******************************************************
//* connection:didReceiveData:
//*
//* Append incoming data to the existing string
//*******************************************************
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSMutableDictionary * dict = (NSMutableDictionary *)CFDictionaryGetValue(connections, connection);
	NSMutableData *connectionData = [dict objectForKey: @"data"];
	[connectionData appendData: data];
}

//*******************************************************
//* connectionDidFinishLoading:
//*
//* All data has arrived, so process according to type
//*******************************************************
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *type = [(NSMutableDictionary *)CFDictionaryGetValue(connections, connection) objectForKey: @"type"];
	
	//*******************************************************
	//* Data type is either @"search" or @"icon"
	//*******************************************************
	if ([type isEqualToString: @"search"]) {
		
		// Stop animating UIActivityIndicatorView here
		
		[self processSearchData: (NSMutableDictionary *)CFDictionaryGetValue(connections, connection)];
	} else {
		[self processIconData: (NSMutableDictionary *)CFDictionaryGetValue(connections, connection)];
	}
	
	//*******************************************************
	//* We're done with this connection, so remove it from
	//* the dictionary.
	//*******************************************************
	CFDictionaryRemoveValue(connections, connection);
	int conCount = [connections count];
	if (conCount <= 0) {
		// Added Code
		refButton.enabled = YES;
		addButton.enabled = YES;
		// End Added Code
	}
}

#pragma mark Process data methods
//*******************************************************
//* processSearchData:
//*
//* Parse and store relevant parts of the search query.
//* Submit more requests for icon data if necessary.
//* 
//* The iconDict only gets cleared out when it gets to 
//* 1000 icons
//*******************************************************
- (void) processSearchData: (NSMutableDictionary *) dict {
	NSMutableData * data = [dict objectForKey: @"data"];
	NSString *queryResult = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	SBJSON *jsonParser = [[SBJSON alloc] init];
	NSError * error;
	NSDictionary * queryDict = [jsonParser objectWithString: queryResult error: &error];
	NSArray * results = [queryDict objectForKey: @"results"];
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
		//* Change high-bit characters into escape codes
		//*******************************************************
		imageURLString = [imageURLString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		
		if ([iconDict objectForKey: imageURLString] == nil) {
			NSURL * imageURL = [NSURL URLWithString: imageURLString];
			NSURLRequest *request = [NSURLRequest requestWithURL: imageURL];
			NSURLConnection *connection = [NSURLConnection connectionWithRequest: request delegate: self];
			//*******************************************************
			//* Create a dictionary with mutable data for the incoming data,
			//* the image url, and a type (icon in this case).
			//*******************************************************
			NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
												   [NSMutableData data], @"data",
												   imageURLString, @"url", 
												   @"icon", @"type", nil];
			
			//*******************************************************
			//* Using a CFDictionary so we can use connection as a key
			//* NSDictionary keys must conform to NSCopying
			//*******************************************************
			CFDictionaryAddValue(connections, connection, connectionDict);
			
			//*******************************************************
			//* Add a null object to the icon dictionary so we know
			//* not to request it again (will be replace with icon
			//* image data when it's received.
			//*******************************************************
			[iconDict setObject: [NSNull null] forKey: imageURLString];
		}
		
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
	
	//*******************************************************
	//* Finally reload the table view
	//*******************************************************
	[tv reloadData];
}

//*******************************************************
//* processIconData:
//*
//* Store the icon data in iconDict, then look through
//* the visible cells and assign the image if the url
//* matches the one just returned
//*******************************************************
- (void) processIconData: (NSMutableDictionary *) dict {
	NSData *iconData = [dict objectForKey: @"data"];
	NSString *iconURL = [dict objectForKey: @"url"]; 
	[iconDict setObject: iconData forKey: iconURL];
	
	NSArray * visibleCells = [self.tableView visibleCells];
	TweetViewCell * cell;
	
	for (cell in visibleCells) {
		if ([cell.imageURL isEqualToString: iconURL]) {
			cell.iconImage = [UIImage imageWithData: [iconDict objectForKey: iconURL]];
			
			//*******************************************************
			//* Need to re-draw the cell to display the image
			//*******************************************************
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
	// Added Code
	MREntitiesConverter *converter = [[MREntitiesConverter alloc] init];
	// End Added Code
    if (cell == nil) {
        cell = [self createNewTweetCellFromNib];
    }
	
	// Added converter code
    cell.tweetText = [converter convertEntitiesInString:[[tweets objectAtIndex: indexPath.row] objectForKey: @"text"]];
	cell.sinceText = [[tweets objectAtIndex: indexPath.row] objectForKey: @"since"];
	cell.fromText = [[tweets objectAtIndex: indexPath.row] objectForKey: @"from_user"];
	cell.imageURL = [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"];
	
	//***************************************************
	//* Use an image if one has been loaded for the URL
	//***************************************************
	if ([iconDict objectForKey: cell.imageURL] != [NSNull null]) {
		cell.iconImage = [UIImage imageWithData: [iconDict objectForKey: cell.imageURL]];
	}
	
	//***************************************************
	//* Add a disclosure indicator if the text contains web stuff
	//***************************************************
	NSString *index = [NSString stringWithFormat:@"%d", indexPath.row]; // Added Code This Line
	if ([cell.tweetText rangeOfString: @"www" options:1].location != NSNotFound ||
		[cell.tweetText rangeOfString: @"http:" options:1].location != NSNotFound ||
		[cell.tweetText rangeOfString: @".com" options:1].location != NSNotFound) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		// Added Code
		[isURL setObject: @"YES" forKey: index];
		[urlDict setObject:cell.tweetText forKey: index];
		// End Added Code
	}
	
	CGRect cellFrame = cell.frame;
	cellFrame.size.height = [self tableView: aTableView heightForRowAtIndexPath: indexPath];
	cell.frame = cellFrame;
	
	//***************************************************
	//* Make sure the cell draws itself
	//***************************************************
	[cell setNeedsDisplay];
    
	return (UITableViewCell *)cell;
}


//*************************************************
//* tableView:heightForRowAtIndexPath:
//*
//* Get the size of the bounding rectangle for the 
//* tweet text, and add 20 to that height for the 
//* cell height. Minimum height is 46.
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
	// Added Code
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
	// End Added Code
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

- (void)dealloc {
	[iconDict release];
	[tweets release];
	CFRelease(connections);
    [super dealloc];
}


@end

