//
//  FifthViewController.h
//  KATG.com
//
//  Created by Doug Russell on 4/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FifthViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
}

@property (nonatomic, retain) UIWebView *webView;

- (IBAction) goBack:(id)sender;

@end
