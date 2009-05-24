//
//  OnAirViewController.h
//  KATG.com
//
//  Live Show Tab with: 
//  Live Feed Playback
//  Submit Feedback
//  Live Feed Status
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


@class AudioStreamer; // This is the shoutcast radio class

@interface OnAirViewController : UIViewController {
	// Live Feed Play Button
	IBOutlet UIButton		*audioButton;
	
	// Instantiate radio object
	AudioStreamer			*streamer;
	
	// Volume Slider
	IBOutlet UIView			*volumeSliderContainer;
	
	// Call Button
	IBOutlet UIButton		*callButton;
	
	// Check reachability
	BOOL _isDataSourceAvailable;
	
	// Feed status
	NSMutableArray			*feedEntries;
	IBOutlet UILabel		*statusText;
	
	// Next Live Show
	IBOutlet UILabel		*days;
	IBOutlet UILabel		*hours;
	IBOutlet UILabel		*minutes;
	
	// Feedback fields and button
	IBOutlet UIButton		*feedbackButton;
	IBOutlet UITextField	*nameField;
	IBOutlet UITextField	*locField;
	IBOutlet UITextView		*comField;
	NSNotificationCenter	*myNotficationCenter;
	NSUserDefaults			*userDefaults;
}

// Ensures textFields and Labels will persist in memory until they've been used
@property (nonatomic, retain) IBOutlet UIButton		*audioButton;
@property (nonatomic, retain) IBOutlet UIView		*volumeSliderContainer;
@property (nonatomic, retain) IBOutlet UIButton		*callButton;
@property (nonatomic, retain) IBOutlet UILabel		*statusText;
@property (nonatomic, retain) IBOutlet UILabel		*days;
@property (nonatomic, retain) IBOutlet UILabel		*hours;
@property (nonatomic, retain) IBOutlet UILabel		*minutes;
@property (nonatomic, retain) IBOutlet UIButton		*feedbackButton;
@property (nonatomic, retain) IBOutlet UITextField	*nameField;
@property (nonatomic, retain) IBOutlet UITextField	*locField;
@property (nonatomic, retain) IBOutlet UITextView	*comField;

// Check Reachability
- (BOOL)isDataSourceAvailable;
// Play Button
- (IBAction)audioButtonPressed:(id)sender;
- (void)setAudioButtonImage:(UIImage *)image;
- (void)spinButton;
// System Volume Slider
- (void)drawVolumeSlider;

// Set up user default to automatically launch audiostreamer
- (void)setDefaults;
// Call Button
- (IBAction)phoneButtonPressed:(id)sender;
// Custom Phone Button Image
- (void)setPhoneButtonImage;

// Submit feedback
- (IBAction)feedbackButtonPressed:(id)sender;
// Custom feedback button image
- (void)setFeedbackButtonImage;
// Dismiss keyboard when DONE is pressed
- (IBAction)textFieldDoneEditing:(id)sender;
// Dismiss keyboard when user clicks outside Comment textView (big invisible button in background)
- (IBAction)textViewDoneEditing:(id)sender;

// Establish timer to update feed status
- (void)setFeedStatusTimer;
// Autorelease pool for pollFeed
- (void)feedStatusAutoPool;
// Poll live show status feed
- (void)pollFeedStatus;

// 
- (void)setNextShowTimer;
// 
- (void)nextShowAutoPool;
// 
- (void)pollNextShow;

@end
