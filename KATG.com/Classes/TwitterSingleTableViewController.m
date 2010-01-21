//
//  TwitterSingleTableViewController.m
//  KATG.com
//
//  Copyright 2009 Doug Russell
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

#define kRowHeight 86

#import "TwitterSingleTableViewController.h"
#import "TwitterTableCellView.h"
#import "Reachability.h"

@implementation TwitterSingleTableViewController

@synthesize shouldStream, activityIndicator, user;

#pragma mark -
#pragma mark SetupCleanup
#pragma mark -
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[self.tableView setRowHeight:kRowHeight];
	[self notification];
	[self setupModel];
	[self addActivityIndicator];
}
- (void)notification
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(reachabilityChanged:) 
	 name:kReachabilityChangedNotification 
	 object:nil];
}
- (void)setupModel
{
	model = [TwitterSingleDataModel model];
	[model setDelegate:self];
	[model setShouldStream:shouldStream];
	tweetList = [[model tweetsForUser:user] retain];
}
- (void)addActivityIndicator
{
	// Create a 'right hand button' that is a activity Indicator
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	self.activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithFrame:frame];
	[self.activityIndicator sizeToFit];
	self.activityIndicator.autoresizingMask =
	(UIViewAutoresizingFlexibleLeftMargin |
	 UIViewAutoresizingFlexibleRightMargin |
	 UIViewAutoresizingFlexibleTopMargin |
	 UIViewAutoresizingFlexibleBottomMargin);
	UIBarButtonItem *loadingView = 
	[[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	loadingView.target = self;
	[[self navigationItem] setRightBarButtonItem:loadingView];
	[activityIndicator release];
	[self.activityIndicator startAnimating];
}
- (void)didReceiveMemoryWarning 
{
	[model cancelTweets];
	[model cancelOtherTweets];
    [super didReceiveMemoryWarning];	
}
- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self cleanupModel];
	[tweetList release];
    [super dealloc];
}
- (void)cleanupModel
{
	[model cancelTweets];
	[model setDelegate:nil];
	[model release];
}
#pragma mark -
#pragma mark Table view methods
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [tweetList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"TwitterTableCell";
    TwitterTableCellView *cell = (TwitterTableCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TwitterTableCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	NSString *name = [[tweetList objectAtIndex:indexPath.row] objectForKey:@"Name"];
	if (name) [[cell tweetNameLabel] setText:[NSString stringWithFormat:@"@%@", name]];
	NSString *text = [[tweetList objectAtIndex:indexPath.row] objectForKey:@"TweetText"];
	if (text) [[cell tweetBodyLabel] setText:text];
	NSURL *url = [NSURL URLWithString:[[tweetList objectAtIndex:indexPath.row] objectForKey:@"IconURL"]];
	if (url) 
	{
		UIImage *icon = [model image:url forIndexPath:indexPath];
		if (icon) [[cell iconView] setImage:icon];
	}
	NSDate *created = [[tweetList objectAtIndex:indexPath.row] objectForKey:@"CreatedAt"];
	if (created)
	{
		NSString *since = [self timeSince:created];
		if (since) [[cell timeSinceLabel] setText:since];
	}
	return cell;
}
- (NSString *)timeSince:(NSDate *)date
{
	NSInteger timeSince = -[date timeIntervalSinceNow];
	NSString *interval = @"s";
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
	NSString *since = [NSString stringWithFormat:@"%i%@", timeSince, interval];
	return since;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	NSString *text = [[tweetList objectAtIndex:indexPath.row] objectForKey:@"TweetText"];
	CGSize maxTextSize = CGSizeMake(238.0, 400.0);
	CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:maxTextSize];
	CGFloat height = MAX((textSize.height + 36.0f), 86.0f);
	return height;
}
- (void)reloadTableView
{
	if ([NSThread isMainThread])
	{
		[self.tableView reloadData];
	} 
	else 
	{
		[self performSelectorOnMainThread:@selector(reloadTableView) 
							   withObject:nil 
							waitUntilDone:NO];
	}
}
#pragma mark -
#pragma mark Model Delegate Methods
#pragma mark -
- (void)tweetsDidChange:(NSArray *)tweets
{
	if ([NSThread isMainThread])
	{
		if (tweets && [tweets count] > 0)
		{
			[tweetList release]; tweetList = nil;
			tweetList = [tweets retain];
			[self reloadTableView];
			[activityIndicator stopAnimating];
		}
	}
	else
	{
		[self performSelectorOnMainThread:@selector(tweetsDidChange:) 
							   withObject:tweets 
							waitUntilDone:NO];
	}
}
- (void)imageDidChange:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath
{
	if ([NSThread isMainThread])
	{
		TwitterTableCellView *cell = (TwitterTableCellView *)[self.tableView cellForRowAtIndexPath:indexPath];
		if (cell)
		{
			// Setting the image here may be duplicating effort
			// from the cellForRowIndexPath method
			cell.iconView.image = image;
			[cell setNeedsLayout];
		}
	}
}
#pragma mark -
#pragma mark Reachability
#pragma mark -
// Respond to changes in reachability
- (void)reachabilityChanged:(NSNotification* )note
{
	Reachability *curReach = [note object];
	//NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateReachability:curReach];
}
// ShouldStream indicates connection status:
// 0 No Connection
// 1 WWAN Connection, stream past shows over WWAN preference is set to NO
// 2 WWAN Connection, stream past shows over WWAN preference is set to YES
// 3 Wifi Connection
// If no connection is available inform user with alert
- (void)updateReachability:(Reachability*)curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus) 
	{
		case NotReachable:
		{
			shouldStream = [NSNumber numberWithInt:0];
			break;
		}
		case ReachableViaWWAN:
		{
			shouldStream = [NSNumber numberWithInt:2];
		}
		case ReachableViaWiFi:
		{
			shouldStream = [NSNumber numberWithInt:3];
			break;
		}
	}
}

@end

