//
//  DetailViewController.m
//  KATG.com
//
//  Created by iPhone SDK Articles on 3/8/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
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

#import "DetailViewController.h"
#import "KATG_comAppDelegate.h"

@implementation DetailViewController

@synthesize detailTitle;
@synthesize detailDate;
@synthesize detailBody;
@synthesize TitleTemp;
@synthesize DateTemp;
@synthesize BodyTemp;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Event Details";
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Done", @"")
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(addAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = addButton;
	
	
	detailTitle.text = TitleTemp;
	detailDate.text = DateTemp;
	detailBody.text = BodyTemp;
}

- (void)addAction:(id)sender{
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

@end

