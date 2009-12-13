//
//  OnAirViewController.h
//  KATG.com
//
//  Live Show Tab with: 
//  Live Feed Playback
//  Submit Feedback
//  Live Feed Status
//  
//  Copyright 2008 Doug Russell
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
	
	// Feedback fields and button
	IBOutlet UIButton		*feedbackButton;
	IBOutlet UITextField	*nameField;
	IBOutlet UITextField	*locField;
	IBOutlet UITextView		*comField;
	
	NSUserDefaults			*userDefaults;
	
	IBOutlet UIButton		*callButton;
	
	// Feed status
	IBOutlet UILabel		*statusText;
	
	// Timers
	NSTimer					*feedTimer;
	NSTimer					*showTimer;
	
	// Next Live Show
	IBOutlet UILabel		*days;
	IBOutlet UILabel		*hours;
	IBOutlet UILabel		*minutes;
}

// Ensures textFields and Labels will persist in memory until they've been used
@property (nonatomic, retain) IBOutlet UIButton		*audioButton;
@property (nonatomic, retain) IBOutlet UIView		*volumeSliderContainer;
@property (nonatomic, retain) IBOutlet UIButton		*feedbackButton;
@property (nonatomic, retain) IBOutlet UITextField	*nameField;
@property (nonatomic, retain) IBOutlet UITextField	*locField;
@property (nonatomic, retain) IBOutlet UITextView	*comField;
@property (nonatomic, retain) IBOutlet UIButton		*callButton;
@property (nonatomic, retain) IBOutlet UILabel		*statusText;
@property (nonatomic, retain) IBOutlet UILabel		*days;
@property (nonatomic, retain) IBOutlet UILabel		*hours;
@property (nonatomic, retain) IBOutlet UILabel		*minutes;

// Play Button
- (IBAction)audioButtonPressed:(id)sender;
- (void)setAudioButtonImage:(UIImage *)image;
- (void)spinButton;
// Set up user default to automatically launch audiostreamer
- (void)setDefaults;
- (void)createNotificationForTermination;
// System Volume Slider
- (void)drawVolumeSlider;
// Submit feedback
- (IBAction)feedbackButtonPressed:(id)sender;
// Custom feedback button image
- (void)setFeedbackButtonImage;
// Dismiss keyboard when DONE is pressed
- (IBAction)textFieldDoneEditing:(id)sender;
// Dismiss keyboard when user clicks outside Comment textView (big invisible button in background)
- (IBAction)textViewDoneEditing:(id)sender;
// Call Button
- (IBAction)phoneButtonPressed:(id)sender;
// 
- (IBAction)infoSheet:(id)sender;
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