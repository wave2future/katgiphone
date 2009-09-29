//
//  linkList.h
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


@interface linkList : UIViewController {
	IBOutlet UIButton *button1;
	IBOutlet UIButton *button2;
	IBOutlet UIButton *button3;
	IBOutlet UIButton *button4;
	IBOutlet UIButton *infoButton;
	NSMutableArray *feedEntries;
	NSMutableArray *list;
	NSString *url1;
	NSString *url2;
	NSString *url3;
	NSString *url4;
}

@property(nonatomic, retain) IBOutlet UIButton *button1;
@property(nonatomic, retain) IBOutlet UIButton *button2;
@property(nonatomic, retain) IBOutlet UIButton *button3;
@property(nonatomic, retain) IBOutlet UIButton *button4;
@property(nonatomic, retain) IBOutlet UIButton *infoButton;

- (void)pollFeed;
- (IBAction)pressedButton1:(id)sender;
- (IBAction)pressedButton2:(id)sender;
- (IBAction)pressedButton3:(id)sender;
- (IBAction)pressedButton4:(id)sender;
- (void)setButtonImages;
- (IBAction)infoSheet;

@end
