//
//  PastShowsDetailViewController.h
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

#import <MediaPlayer/MediaPlayer.h>
#import "PastShowDataModel.h"
#import "PastShowPicsDataModel.h"
#import "ImagePageViewController.h"
#import "ImageAdditions.h"

@interface PastShowsDetailViewController : UIViewController 
<PastShowDataModelDelegate, PastShowPicsDataModelDelegate,
UIScrollViewDelegate, ImagePageDelegate> 
{
	PastShowDataModel     *model;
	PastShowPicsDataModel *picsModel;
	
	NSNumber     *shouldStream;
	NSDictionary *show;
	
	UILabel      *titleLabel;
	UILabel      *numberLabel;
	UILabel      *guestsLabel;
	
	UIButton     *playButton;
	
	UISegmentedControl *segmentedControl;
	
	UITextView *noteView;
	UIView     *picView;
	
	UIScrollView   *scrollView;
    UIPageControl  *pageControl;
    NSMutableArray *viewControllers;
    BOOL           pageControlUsed;
	
	MPMoviePlayerController *moviePlayer;
	
	NSURL *movieURL;
	BOOL playing;
	
	NSArray *picDataArray;
}

@property (nonatomic, retain) NSNumber     *shouldStream;
@property (nonatomic, retain) NSDictionary *show;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *guestsLabel;

@property (nonatomic, retain) IBOutlet UIButton *playButton;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, retain) IBOutlet UITextView *noteView;
@property (nonatomic, retain) IBOutlet UIView     *picView;

@property (nonatomic, retain) IBOutlet UIScrollView  *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain)          NSMutableArray *viewControllers;

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) NSURL *movieURL;

- (void)data;
- (void)hidePlayButton;
- (void)notifications;
- (void)labels;
- (void)pictures;
- (void)setNoteViewText:(NSString *)text;
- (IBAction)segmentedControlChangedState:(id)sender;
- (IBAction)playButtonPressed:(id)sender;

@end
