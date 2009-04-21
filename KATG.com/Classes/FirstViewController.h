//
//  FirstViewController.h
//  KATG.com
//
//  Live Show Tab with: 
//  Live Feed Playback
//  Submit Feedback
//  Next live show time
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

@class AudioStreamer; // This is the shoutcast radio class

@interface FirstViewController : UIViewController {
	// Live Feed Play Button
	IBOutlet UIButton		*button;
	
	// Instantiate radio object
	AudioStreamer			*streamer;
	
	// Feed status
	NSMutableArray			*feedEntries;
	IBOutlet UILabel		*statusText;
	
	// Feedback fields and button
	IBOutlet UIButton		*feedButton;
	IBOutlet UITextField	*nameField;
	IBOutlet UITextField	*locField;
	IBOutlet UITextView		*comField;
}

// Insures textFields and Labels will persist in memory until they've been used
@property (nonatomic, retain) IBOutlet UILabel		*statusText;
@property (nonatomic, retain) IBOutlet UITextField	*nameField;
@property (nonatomic, retain) IBOutlet UITextField	*locField;
@property (nonatomic, retain) IBOutlet UITextView	*comField;


// Set up actions for GUI to perform
// Play Button
- (IBAction)buttonPressed:(id)sender;
// Submit feedback
- (IBAction)feedButtonPressed:(id)sender;
// Dismiss keyboard when DONE is pressed
- (IBAction)textFieldDoneEditing:(id)sender;
// Dismiss keyboard when user clicks outside Comment textView (big invisible button in background)
- (IBAction)textViewDoneEditing:(id)sender;
// Poll live show status feed
- (void)pollFeed;
// Establish timer to update feed status
- (void)setTimer;

@end
