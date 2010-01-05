//
//  OnAirViewController.h
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

#define kPhoneNumber @"tel:+16465028682"

#import "GrabXMLFeed.h"
#import "EventsDataModel.h"
#import "ImageAdditions.h"

@class AudioStreamer; // This is the shoutcast radio class
@interface OnAirViewController : UIViewController
<UITextViewDelegate, GrabXMLFeedDelegate, EventsDataModelDelegate>
{
	id               delegate;
	NSNumber         *shouldStream;
	
	NSUserDefaults   *userDefaults;
		
	// Feedback
	UITextField		 *nameTextField;
	UITextField		 *locationTextField;
	UITextView		 *commentTextView;
	UIButton		 *feedbackButton;
	
	// Live Show Status
	UILabel			 *liveShowStatusLabel;
	NSAutoreleasePool *feedPool;
	
	// Next Live Show Countdown
	UILabel			 *nextLiveShowCountdownLabel;
	NSInteger        timeSince;
	
	// Shoutcast
	UIButton		 *audioButton;
	AudioStreamer    *streamer;
	BOOL             playOnConnection;
	
	// Volume Slider
	UIView			 *volumeSliderContainer;
	
	// Phone In Button
	UIButton		 *callButton;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSNumber *shouldStream;
// Feedback
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *locationTextField;
@property (nonatomic, retain) IBOutlet UITextView  *commentTextView;
@property (nonatomic, retain) IBOutlet UIButton    *feedbackButton;
// Live Show Status
@property (nonatomic, retain) IBOutlet UILabel	   *liveShowStatusLabel;
// Next Live Show Countdown
@property (nonatomic, retain) IBOutlet UILabel	   *nextLiveShowCountdownLabel;
// Shoutcast
@property (nonatomic, retain) IBOutlet UIButton	   *audioButton;
// Volume Slider
@property (nonatomic, retain) IBOutlet UIView      *volumeSliderContainer;
// Phone In Button
@property (nonatomic, retain) IBOutlet UIButton	   *callButton;

@end
