//
//  DetailViewController.h
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