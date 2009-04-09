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
//  Created by Doug Russell on 4/5/09.
//  Copyright Radio Dysentery 2009. All rights reserved.
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
#import	"TouchXML.h"

@class AudioStreamer; // This is the shoutcast radio class

@interface FirstViewController : UIViewController {
	// Live Feed Play Button
	IBOutlet UIButton    *button;
	
	// Instantiate radio object
	AudioStreamer        *streamer;
	
	// Feed status, button only temporary
	IBOutlet UIButton    *statButton;
	IBOutlet UILabel     *statusText;
	
	// Feedback fields and button
	IBOutlet UIButton    *feedButton;
	IBOutlet UITextField *nameField;
	IBOutlet UITextField *locField;
	IBOutlet UITextField *comField;
	
	// Array for xml feeds
	NSMutableArray       *blogEntries;
}

// Insures textFields and Labels will persist in memory until they've been used
@property (nonatomic, retain) UILabel *statusText;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *locField;
@property (nonatomic, retain) UITextField *comField;


// Set up actions for GUI to perform
// Play Button
- (IBAction)buttonPressed:(id)sender;
// Check feed status, this is temporary
- (IBAction)statButtonPressed:(id)sender;
// Submit feedback
- (IBAction)feedButtonPressed:(id)sender;
// Dismiss keyboard when DONE is pressed
- (IBAction)textFieldDoneEditing:(id)sender;

@end
