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


@implementation DetailViewController

@synthesize detailTitle; // Label to display event title
@synthesize detailDate;  // Label to display event date
@synthesize detailBody;  // Label to display event description
@synthesize TitleTemp;   // Variable to store title passed from SecondViewController
@synthesize TimeTemp;    // Variable to store time passed from SecondViewController
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
	
	CGRect rect = CGRectMake(20, 90, 280, 240);
	
	detailBody = [[[UITextView alloc] initWithFrame:rect] autorelease];
	detailBody.textColor = [UIColor blackColor];
	detailBody.backgroundColor = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.667 alpha:(CGFloat)1.0]; 
	detailBody.editable = NO;
	detailBody.font = [UIFont systemFontOfSize:15.0];
	//detailBody.textAlignment = UITextAlignmentCenter;
	
	[self.view addSubview:detailBody];
	
	detailTitle.text = TitleTemp;
	detailTime.text = TimeTemp;
	detailDate.text = DateTemp;
	detailBody.text = BodyTemp;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

@end

