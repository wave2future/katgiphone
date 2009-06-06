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

#define __IPHONE_OS_VERSION_MIN_REQUIRED __IPHONE_3_0


@interface ShowDetailController : UIViewController {
	IBOutlet UILabel *detailTitle;    // Label to display event title
	IBOutlet UILabel *detailLink;     // Label to display event date
	UITextView *detailBody;			  // TextView to display event description
	NSString *TitleTemp;              // Variable to store title passed from SecondViewController
	NSString *LinkTemp;               // Variable to store time passed from SecondViewController
	NSString *BodyTemp;               // Variable to store description passed from SecondViewController
	IBOutlet UIButton		*button;
	MPMoviePlayerController *moviePlayer;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) IBOutlet UILabel *detailTitle;
@property (nonatomic, retain) IBOutlet UILabel *detailLink;
@property (nonatomic, retain) UITextView *detailBody;
@property (nonatomic, retain) NSString *TitleTemp;
@property (nonatomic, retain) NSString *LinkTemp;
@property (nonatomic, retain) NSString *BodyTemp;
@property (nonatomic, retain) IBOutlet UIButton		*button;
@property (readwrite, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)buttonPressed:(id)sender;
- (void)playMovie:(NSURL *)movieURL;
- (void)setButtonImage;

@end
