//
//  linkList.h
//  KATG.com
//


#import <UIKit/UIKit.h>


@interface linkList : UIViewController {
	IBOutlet UIButton *button1;
	IBOutlet UIButton *button2;
	IBOutlet UIButton *button3;
}

@property(nonatomic, retain) IBOutlet UIButton *button1;
@property(nonatomic, retain) IBOutlet UIButton *button2;
@property(nonatomic, retain) IBOutlet UIButton *button3;

- (IBAction)pressedButton1:(id)sender;
- (IBAction)pressedButton2:(id)sender;
- (IBAction)pressedButton3:(id)sender;

@end
