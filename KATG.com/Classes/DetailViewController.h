//
//  DetailViewController.h
//  DrillDownApp
//
//  Created by iPhone SDK Articles on 3/8/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

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