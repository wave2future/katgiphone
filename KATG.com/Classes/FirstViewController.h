//
//  FirstViewController.h
//  KATG.com
//
//  Created by Doug Russell on 4/5/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface FirstViewController : UIViewController {
	IBOutlet UIButton *button;
	AudioStreamer *streamer;
}

- (IBAction)buttonPressed:(id)sender;

@end
