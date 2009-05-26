//
//  linkList.m
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

#import "linkList.h"


@implementation linkList

@synthesize button1, button2, button3;

- (void)viewDidLoad {
	[self setButtonImages];
}

- (IBAction)pressedButton1:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=253167631"]];
}

- (IBAction)pressedButton2:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://keithandthegirl.com/donate"]];
}

- (IBAction)pressedButton3:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://keithandthegirl.com/store"]];
}

- (void)setButtonImages {
	UIImage *feedButtonImage = [UIImage imageNamed:@"feedButtonNormal.png"];
	UIImage *normal = [feedButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	UIImage *feedButtonHighlightedImage = [UIImage imageNamed:@"feedButtonPressed.png"];
	UIImage *highlight = [feedButtonHighlightedImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	[button1 setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button1 setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
	[button2 setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button2 setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
	[button3 setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button3 setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[button1 release];
	[button2 release];
	[button3 release];
    [super dealloc];
}


@end
