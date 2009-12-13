//
//  DetailViewController.h
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
#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController {
	IBOutlet UILabel *detailTitle;    // Label to display event title
	IBOutlet UILabel *detailTime;     // Label to display event date
	IBOutlet UILabel *detailDate;     // Label to display event date
	UITextView *detailBody;			  // TextView to display event description
	NSString *TitleTemp;              // Variable to store title passed from SecondViewController
	NSString *TimeTemp;               // Variable to store time passed from SecondViewController
	NSString *DateTemp;               // Variable to store date passed from SecondViewController
	NSString *BodyTemp;               // Variable to store description passed from SecondViewController
}

@property (nonatomic, retain) IBOutlet UILabel *detailTitle;
@property (nonatomic, retain) IBOutlet UILabel *detailDate;
@property (nonatomic, retain) UITextView *detailBody;
@property (nonatomic, retain) NSString *TitleTemp;
@property (nonatomic, retain) NSString *TimeTemp;
@property (nonatomic, retain) NSString *DateTemp;
@property (nonatomic, retain) NSString *BodyTemp;

@end