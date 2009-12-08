//
//  ShowDetailController.h
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

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ShowDetailController : UIViewController <UIScrollViewDelegate> {
	IBOutlet UIButton					*button;
	IBOutlet UISegmentedControl			*segmentedControl;
	IBOutlet UIActivityIndicatorView	*activityIndicator;
	IBOutlet UIActivityIndicatorView	*imageActivityIndicator;
	IBOutlet UILabel					*lblTitle;			// Label to display event title
	UITextView							*txtNotes;			// TextView to display event description
	NSString							*showTitle;			// Variable to store title passed from PastShowsController
	NSString							*showLink;			// Variable to store time passed from PastShowsController
	NSString							*showNotes;			// Variable to store description passed from PastShowsController
	NSString							*showNumber;
	NSString							*feedAddress;
	MPMoviePlayerController				*moviePlayer;
	
	IBOutlet UIScrollView				*scrollView;
    IBOutlet UIPageControl				*pageControl;
	IBOutlet UIImageView				*blackBox;
    NSMutableArray						*viewControllers;
	NSMutableDictionary					*imageDictionary;
    BOOL pageControlUsed;
	
	//NSURL *theURL;
	NSString *urlDescription;
	NSURLConnection *theConnection;
}

@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *imageActivityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *lblTitle;
@property (nonatomic, retain) UITextView *txtNotes;
@property (nonatomic, retain) NSString *showTitle;
@property (nonatomic, retain) NSString *showLink;
@property (nonatomic, retain) NSString *showNotes;
@property (nonatomic, retain) NSString *showNumber;
@property (nonatomic, retain) NSString *feedAddress;
@property (readwrite, retain) MPMoviePlayerController *moviePlayer;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) UIImageView *blackBox;

- (IBAction)buttonPressed:(id)sender;
- (void)playMovie:(NSURL *)movieURL;
- (void)setButtonImage;
- (void)pollFeed;
- (void)pollImageFeed;
- (void)updateView;
- (BOOL)Stream;
- (void)setStream:(BOOL)stream;
- (IBAction)segmentedController:(id)sender;

- (IBAction)changePage:(id)sender;
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (void)createNotificationForTermination;

@end