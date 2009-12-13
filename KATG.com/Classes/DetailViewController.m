//
//  DetailViewController.m
//  KATG.com
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

#import "DetailViewController.h"
//#import "EventsViewController.h"


@implementation DetailViewController

@synthesize detailTitle; // Label to display event title
@synthesize detailDate;  // Label to display event date
@synthesize detailBody;  // Label to display event description
@synthesize TitleTemp;   // Variable to store title passed from SecondViewController
@synthesize TimeTemp;    // Variable to store time passed from SecondViewController
@synthesize DateTemp;    // Variable to store date passed from SecondViewController
@synthesize BodyTemp;     // Variable to store description passed from SecondViewController


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
	
	CGRect rect = CGRectMake(5, 125, 315, 230);
	
	detailBody = [[[UITextView alloc] initWithFrame:rect] autorelease];
	detailBody.textColor = [UIColor blackColor];
	detailBody.backgroundColor = [UIColor clearColor]; 
	detailBody.dataDetectorTypes = UIDataDetectorTypeAll;
	
	detailBody.editable = NO;
	detailBody.font = [UIFont systemFontOfSize:15.0];
	
	[self.view addSubview:detailBody];
	
	detailTitle.text = TitleTemp;
	detailTime.text = TimeTemp;
	detailDate.text = DateTemp;
	detailBody.text = BodyTemp;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    //NSLog(@"Event Details View Did Receive Memory Warning");
}


- (void)dealloc {
    [super dealloc];
}

@end

