//
//  LinksViewController.m
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

#define kRowHeight 80

#import "LinksViewController.h"
#import "LinksTableCellView.h"
#import "ModalWebViewController.h"

@implementation LinksViewController

@synthesize delegate;

@synthesize infoButton, tblView;

- (void)viewDidLoad 
{
	shouldStream = [[self delegate] shouldStream];
	LinksDataModel *model = [LinksDataModel model];
	[model setDelegate:self];
	[model setShouldStream:shouldStream];
	list = [model links];
	
	tblView.rowHeight = kRowHeight;
}
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc 
{
	[infoButton release];
	[tblView release];
	[list release];
    [super dealloc];
}

- (IBAction)infoSheet 
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Thanks and Credit"
						  message:@"The following people contributed directly or through content:\n • Keith Malley\n • Chemda\n • Michael Khalili\n • Hypercrypt (Klaus Dudas)\n • The Grundle (Barry Mendelson)\n • Londan Ash (Ashley Mills)\n • Picard (John Leschinski)\n • Subsonix (Marcus Newman)\n • Mapes\n • Aptmunich\n • Elmacgato\n • RegexKitLite Copyright © 2008-2009, John Engelhart" 
						  delegate:nil
						  cancelButtonTitle:@"Continue" 
						  otherButtonTitles:nil];
	[alert show];
	[alert autorelease];
}

- (void)linksDataModelDidChange:(NSArray *)links
{
	if ([NSThread isMainThread])
	{
		[list release]; list = nil;
		list = [links retain];
		[self.tblView reloadData];
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(linksDataModelDidChange:) 
							   withObject:links 
							waitUntilDone:NO];
	}
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [list count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	static NSString *CellIdentifier = @"LinksTableCellView";
    
	LinksTableCellView *cell = (LinksTableCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[LinksTableCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
	[bgView setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.5]];
	cell.selectedBackgroundView = bgView;
	[bgView release];
	
	cell.imgSquare.image = [UIImage imageNamed:@"LinkButton.png"];
	
	cell.lblTitle.text = [[list objectAtIndex:indexPath.row] objectForKey:@"title"];
	cell.lblTitle.backgroundColor = [UIColor clearColor];
	
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	BOOL inApp = [[[list objectAtIndex:indexPath.row] objectForKey:@"inApp"] boolValue];
	if (inApp) 
	{
		NSString *url = [[list objectAtIndex:indexPath.row] objectForKey:@"url"];
		NSURL *URL = [NSURL URLWithString:url];
		ModalWebViewController *viewController = 
		[[ModalWebViewController alloc] initWithNibName:@"ModalWebView" bundle:nil];
		[viewController setUrlRequest:[NSURLRequest requestWithURL:URL]];
		[viewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[self presentModalViewController:viewController animated:YES];
		[viewController release];
	} 
	else 
	{
		NSString *url = [[list objectAtIndex:indexPath.row] objectForKey:@"url"];
		if ([url rangeOfString:@"mailto:"].location != NSNotFound) 
		{
			url = [url stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
			url = [url stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
		}
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}
- (void)reloadTableView
{
	if ([NSThread isMainThread])
	{
		[self.tblView reloadData];
	} 
	else 
	{
		[self performSelectorOnMainThread:@selector(reloadTableView) 
							   withObject:nil 
							waitUntilDone:NO];
	}
}

@end
