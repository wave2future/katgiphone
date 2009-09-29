//
//  TinyBrowser.h
//  KATG.com
//
//  Created by Doug Russell on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "linkList.h";

@interface TinyBrowser : UIViewController <UIWebViewDelegate> {
	linkList *delegate;
	UIView *view;
	UIWebView *webView;
	UIToolbar *toolBar;
	NSString *urlAddress;
}

@property (nonatomic, retain) linkList *delegate;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) NSString *urlAddress;

@end