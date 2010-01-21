//
//  InterTableViewController.m
//  KATG.com
//
//  Created by Doug Russell on 1/20/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#define kRowHeight 86

#import "InterTableViewController.h"
#import "TwitterTableCellView.h"
#import "ModalWebViewController.h"
#import "TwitterSingleTableViewController.h"
#import "ImageAdditions.h"

@implementation InterTableViewController

@synthesize urlList;
@synthesize twtList;
@synthesize shouldStream;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	[[self tableView] setRowHeight:kRowHeight];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc 
{
	[urlList release];
	[twtList release];
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [urlList count] + [twtList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"TwitterTableCell";
    TwitterTableCellView *cell = (TwitterTableCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[TwitterTableCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if (indexPath.row < [urlList count]) 
	{
		[[cell tweetBodyLabel] setText:[urlList objectAtIndex:indexPath.row]];
		[[cell iconView] setImage:UIImageForNameExtension(@"Compass", @"png")];
	} 
	else if (indexPath.row >= [urlList count]) 
	{
		[[cell tweetBodyLabel] setText:[twtList objectAtIndex:indexPath.row - [urlList count]]];
		[[cell iconView] setImage:UIImageForNameExtension(@"Twitter", @"png")];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (indexPath.row < [urlList count]) 
	{
		NSURLRequest *request = 
		[NSURLRequest requestWithURL:[NSURL URLWithString:[urlList objectAtIndex:indexPath.row]]];
		ModalWebViewController *viewController = 
		[[ModalWebViewController alloc] initWithNibName:@"ModalWebView" bundle:nil];
		[viewController setUrlRequest:request];
		[viewController setDisableDone:YES];
		[[self navigationController] pushViewController:viewController animated:YES];
		[viewController release];
	} 
	else if (indexPath.row >= [urlList count]) 
	{
		TwitterSingleTableViewController *viewController = 
		[[TwitterSingleTableViewController alloc] initWithNibName:@"TwitterSingleTableView" 
														   bundle:nil];
		[viewController setShouldStream:shouldStream];
		[viewController setUser:[twtList objectAtIndex:indexPath.row - [urlList count]]];
		[[self navigationController] pushViewController:viewController 
											   animated:YES];
		[viewController release];
	}
}

@end

