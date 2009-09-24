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
#import "Reachability.h"


@class AudioStreamer; // This is the shoutcast radio class

@interface OnAirViewController : UIViewController {
	// Live Feed Play Button
	IBOutlet UIButton		*audioButton;
	
	// Instantiate radio object
	AudioStreamer			*streamer;
}

// Ensures textFields and Labels will persist in memory until they've been used
@property (nonatomic, retain) IBOutlet UIButton		*audioButton;

// Play Button
- (IBAction)audioButtonPressed:(id)sender;
- (void)setAudioButtonImage:(UIImage *)image;
- (void)spinButton;

@end
