//
//  DetailViewController.m
//  DrillDownApp
//
//  Created by iPhone SDK Articles on 3/8/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "DetailViewController.h"
#import "KATG_comAppDelegate.h"

@implementation DetailViewController

@synthesize detailTitle;
@synthesize detailDate;
@synthesize detailBody;
@synthesize TitleTemp;
@synthesize DateTemp;
@synthesize BodyTemp;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"Event Details";
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Done", @"")
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(addAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = addButton;
	
	
	detailTitle.text = TitleTemp;
	detailDate.text = DateTemp;
	detailBody.text = BodyTemp;
}

- (void)addAction:(id)sender{
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

@end

