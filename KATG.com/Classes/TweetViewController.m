//
//  TweetViewController.m
//  KaTGTwitter
//
//  Created by Ashley Mills on 11/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
//
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
#import "DetailViewController.h"
#import <JSON/JSON.h>

@implementation TweetViewController

//*******************************************************
//* viewDidLoad:
//*
//*******************************************************
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.navigationItem.title = @"KATG Tweets";

	queryResult = [[NSMutableString alloc] initWithCapacity: bytesToLoad];
	tweets = [[NSMutableArray alloc] initWithCapacity: 100];
	iconDict = [[NSMutableDictionary alloc] init];
	
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Other Tweets", @"On")
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(addAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)addAction:(id)sender{
	otherTweets = @"ON";
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
	if ( otherTweets == @"ON" )
		searchString = [searchString stringByAppendingString: @"+OR+keithandthegirl+OR+%22keith+and+the+girl%22"];
	
//	searchString = [searchString stringByAppendingFormat: @"&rpp=%i", (int)mainViewController.tweetCount.value];
	searchString = [searchString stringByAppendingFormat: @"&rpp=%i", 20];

	
	NSURL *url = [NSURL URLWithString: searchString];
	
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	NSURLConnection *connection = [NSURLConnection connectionWithRequest: request delegate: self];
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
	NSString *newData = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	[queryResult appendString: newData];
	[newData release];
	bytesLoaded += [data length];
}

//*******************************************************
//* connectionDidFinishLoading:
//*
//* All data has arrived, so parse and store relevant parts
//*******************************************************
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	SBJSON *jsonParser = [SBJSON new];
//	NSLog(@"Query result - %@", queryResult);
	
	NSError * error;
	NSDictionary * queryDict = [jsonParser objectWithString: queryResult error: &error];
	NSArray * results = [queryDict objectForKey: @"results"];
	
//	NSLog(@"Results - %@", results);

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
		NSDate * createdAt = [formatter dateFromString: [tweet objectForKey: @"created_at"]];
		
		//******************************************
		//* Calculate the time & units since creation.
		//* Compensating for TimeZone
		//******************************************
		NSString * interval = @"s";
		int timeSince = -[createdAt timeIntervalSinceNow];
		
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
		
		//******************************************
		// Store an icon for this user if we haven't already 
		//******************************************
		if ([iconDict objectForKey: from] == nil) {
			NSURL *iconURL = [NSURL URLWithString: [tweet objectForKey: @"profile_image_url"]];
			NSData *iconData = [NSData dataWithContentsOfURL: iconURL];
			[iconDict setObject: iconData forKey: from];
		}
		
		//******************************************
		//* Put everything in a dictionary and add to tweet array
		//******************************************

		NSDictionary * tweetDict = [NSDictionary dictionaryWithObjectsAndKeys: from, @"from_user", 
									text, @"text", 
									since, @"since", nil];
		
		[tweets addObject: tweetDict];
		
	}
//	NSLog(@"%@", tweets);
	
	//******************************************
	//* Finally reload the table view
	//******************************************
	[tv reloadData];
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
	
    cell.tweet.text = [[tweets objectAtIndex: indexPath.row] objectForKey: @"text"];
	cell.since.text = [[tweets objectAtIndex: indexPath.row] objectForKey: @"since"];
	NSString * from = [[tweets objectAtIndex: indexPath.row] objectForKey: @"from_user"];
	[cell.icon setImage: [UIImage imageWithData: [iconDict objectForKey: from]]];
	
	if ([cell.tweet.text rangeOfString: @"www"].location != NSNotFound |
		[cell.tweet.text rangeOfString: @"http:"].location != NSNotFound |
		[cell.tweet.text rangeOfString: @".com"].location != NSNotFound) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return (UITableViewCell *)cell;
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
	DetailViewController *viewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
//	viewController.TitleTemp = [[list objectAtIndex:indexPath.row] title];
//	viewController.DateTemp = [[list objectAtIndex:indexPath.row] publishDate];
//	viewController.BodyTemp = [[list objectAtIndex:indexPath.row] detail];
	[[self navigationController] pushViewController:viewController animated:YES];
	[viewController release];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

- (void)dealloc {
	[iconDict release];
	[queryResult release];
	[tweets release];
    [super dealloc];
}


@end

