//
//  PastShowsDetailViewController.m
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

#import "PastShowsDetailViewController.h"
#import "PastShowsDetailViewController+Playback.h"
#import "PastShowsDetailViewController+ScrollView.h"
#import "PastShowsDetailViewController+HiResImageView.h"

@implementation PastShowsDetailViewController

@synthesize shouldStream, show;
@synthesize titleLabel, numberLabel, guestsLabel;
@synthesize playButton;
@synthesize segmentedControl;
@synthesize noteView, picView;
@synthesize scrollView, pageControl, viewControllers;
@synthesize moviePlayer, movieURL;

#pragma mark -
#pragma mark SetupCleanup
#pragma mark -
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[self data];
	[self labels];
	[self notifications];
	[self pictures];
}
- (void)data
{
	NSString *ID = [show objectForKey:@"ID"];
	model = [PastShowDataModel model];
	[model setDelegate:self];
	[model setShouldStream:shouldStream];
	NSDictionary *sh = [[model show:ID] retain];
	
	picsModel = [PastShowPicsDataModel model];
	[picsModel setDelegate:self];
	[picsModel setShouldStream:shouldStream];
	picDataArray = [picsModel pics:ID];
	
	NSString *URL = [sh objectForKey:@"FileUrl"];
	if (URL) movieURL = [[NSURL URLWithString:URL] retain];
	if (!movieURL || [shouldStream intValue] < 2) 
	{
		[self hidePlayButton];
	}
	NSString *detail = [sh objectForKey:@"Detail"];
	if (detail) [self setNoteViewText:detail];
	[sh release];
}
- (void)hidePlayButton
{
	[playButton setEnabled:NO];
	[playButton setHidden:YES];
}
- (void)notifications 
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(moviePreloadDidFinish:) 
	 name:MPMoviePlayerContentPreloadDidFinishNotification 
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(moviePlayBackDidFinish:) 
	 name:MPMoviePlayerPlaybackDidFinishNotification 
	 object:nil];
}
- (void)labels 
{
	NSString *title = [show objectForKey:@"Title"];
	if (title) [titleLabel setText:title];
	NSString *guests = [show objectForKey:@"Guests"];
	if (guests) [guestsLabel setText:guests];
	NSString *number = 
	[NSString stringWithFormat:@"Show %@", [show objectForKey:@"Number"]];
	if (number) [numberLabel setText:number];
	CGSize size = 
	[guests sizeWithFont:
	 [UIFont systemFontOfSize:[guestsLabel minimumFontSize]]];
	if (size.width > guestsLabel.frame.size.width) 
	{
		[guestsLabel setFont:[UIFont systemFontOfSize:12]];
		[guestsLabel setNumberOfLines:3];
	}
}
- (void)pictures
{
	if (!picDataArray) return;
	NSMutableArray *controllers = [[NSMutableArray alloc] init];
	for (unsigned i = 0; i < picDataArray.count; i++) 
	{
		[controllers addObject:[NSNull null]];
	}
	if (controllers) 
	{
		[self setViewControllers:controllers];
		[controllers release];
	}
	scrollView.pagingEnabled = YES;
	scrollView.contentSize = 
	CGSizeMake(scrollView.frame.size.width * picDataArray.count, 
			   scrollView.frame.size.height);
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.scrollsToTop = NO;
	scrollView.delegate = self;
	pageControl.numberOfPages = picDataArray.count;
	pageControl.currentPage = 0;
	[self loadScrollViewWithPage:0];
	[self loadScrollViewWithPage:1];
}
- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
	[moviePlayer stop];
	[self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
	
}
- (void)dealloc 
{
	[titleLabel release];
	[numberLabel release];
	[guestsLabel release];
	
	[playButton release];
	[moviePlayer release];
	[movieURL release];
	
	[picsModel cancel];
	[picsModel setDelegate:nil];
	[picsModel release]; picsModel = nil;
	
	[model cancel];
	[model setDelegate:nil];
	[model release]; model = nil;
	
	[segmentedControl release];
	
	[picView release];
	[scrollView release];
	[pageControl release];
	[viewControllers release];
	[picDataArray release];
	
	[noteView release];
	
	[show release];
	
	[super dealloc];
}
#pragma mark -
#pragma mark Model Delegates
#pragma mark -
- (void)pastShowDataModelDidChange:(NSDictionary *)aShow 
{
	if ([NSThread isMainThread]) 
	{
		NSString *URL = [aShow objectForKey:@"FileUrl"];
		if (URL) movieURL = [[NSURL URLWithString:URL] retain];
		if (!movieURL || [shouldStream intValue] < 2) 
		{
			[self hidePlayButton];
		}
		NSString *detail = [aShow objectForKey:@"Detail"];
		if (detail) [self setNoteViewText:detail];
	} 
	else 
	{
		[self performSelectorOnMainThread:@selector(pastShowDataModelDidChange:)
							   withObject:aShow 
							waitUntilDone:NO];
	}
}
- (void)setNoteViewText:(NSString *)text 
{
	if ([NSThread isMainThread] && text) 
	{
		[noteView setText:text];
	} 
	else if (text) 
	{
		[self performSelectorOnMainThread:@selector(setNoteViewText:) withObject:text waitUntilDone:NO];
	}
}
- (void)pastShowModelDidFinish
{
	[model setDelegate:nil];
	[model release]; model = nil;
}
- (void)pastShowPicsDataModelDidChange:(NSArray *)pics
{
	if ([NSThread isMainThread])
	{
		if (!picDataArray) return;
		NSInteger count = [picDataArray count];
		picDataArray = [pics copy];
		NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:viewControllers];
		for (unsigned i = count; i < picDataArray.count; i++) 
		{
			[controllers addObject:[NSNull null]];
		}
		if (controllers)
		{
			self.viewControllers = controllers;
			[controllers release];
	}
		scrollView.contentSize = 
		CGSizeMake(scrollView.frame.size.width * picDataArray.count, 
				   scrollView.frame.size.height);
		pageControl.numberOfPages = picDataArray.count;
		for (unsigned i = 0; i < picDataArray.count; i++) 
		{
			ImagePageViewController *controller = [viewControllers objectAtIndex:i];
			if ((NSNull *)controller != [NSNull null]) 
			{
				controller = [self updateViewController:controller page:i];
			}
		}
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(pastShowPicsDataModelDidChange:)
							   withObject:[pics copy] 
							waitUntilDone:NO];
	}
}
#pragma mark -
#pragma mark Button Methods
#pragma mark -
- (IBAction)segmentedControlChangedState:(id)sender 
{
	if ([segmentedControl selectedSegmentIndex] == 0) {
		[noteView setHidden:NO];
		[picView setHidden:YES];
	} else {
		[noteView setHidden:YES];
		[picView setHidden:NO];
	}
}
- (IBAction)playButtonPressed:(id)sender 
{
	if ([shouldStream intValue] < 2) 
	{
		NSString *alertMessage = @"Streaming shows over cellular network is disabled, enable Wifi to stream";
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Past Shows Streaming Disabled"
							  message:alertMessage 
							  delegate:nil
							  cancelButtonTitle:@"Continue" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (playing) 
	{
		[self setPlayButtonImage:UIImageForNameExtension(@"playButton", @"png")];
		if (moviePlayer) 
		{
			[moviePlayer stop];
		}
		playing = NO;
		return;
	}
	playing = YES;
	
	[self chooseCorrectPlayback];
}

@end
