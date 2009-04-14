//
//  DetailViewController.m
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

#import "DetailViewController.h"
#import "KATG_comAppDelegate.h" // This gives access to the navigation controller

@implementation DetailViewController

@synthesize detailTitle; // Label to display event title
@synthesize detailDate;  // Label to display event date
@synthesize detailBody;  // Label to display event description
@synthesize TitleTemp;   // Variable to store title passed from SecondViewController
@synthesize DateTemp;    // Variable to store date passed from SecondViewController
@synthesize BodyTemp;    // Variable to store description passed from SecondViewController


//*******************************************************
//* viewDidLoad:
//*
//* Set navigation controller title
//* Add button to navigate back to SecondView
//* Set text of Title, Date and Body
//*
//*******************************************************
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Event Details";
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Done", @"")
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(dismissView:)] autorelease];
    self.navigationItem.leftBarButtonItem = addButton;
	
	
	detailTitle.text = TitleTemp;
	detailDate.text = DateTemp;
	detailBody.text = BodyTemp;
}

//*******************************************************
//* dismissView
//*
//* Return to view from which this view was pushed
//* in this case SecondView
//*
//*******************************************************
- (void)dismissView:(id)sender{
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

