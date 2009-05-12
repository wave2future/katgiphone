//
//  ShowDetailController.h
//  KATG.com
//
//  Created by Doug Russell on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


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
