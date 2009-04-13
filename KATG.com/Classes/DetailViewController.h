//
//  DetailViewController.h
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
#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController {
	IBOutlet UILabel *detailTitle;
	IBOutlet UILabel *detailDate;
	IBOutlet UITextView *detailBody;
	NSString *TitleTemp;
	NSString *DateTemp;
	NSString *BodyTemp;
}

@property (nonatomic, retain) IBOutlet UILabel *detailTitle;
@property (nonatomic, retain) IBOutlet UILabel *detailDate;
@property (nonatomic, retain) IBOutlet UITextView *detailBody;
@property (nonatomic, retain) NSString *TitleTemp;
@property (nonatomic, retain) NSString *DateTemp;
@property (nonatomic, retain) NSString *BodyTemp;

@end