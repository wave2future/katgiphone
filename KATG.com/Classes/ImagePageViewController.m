//
//  ImagePageViewController.m
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

#import "ImagePageViewController.h"

BOOL hiRes;

@implementation ImagePageViewController

@synthesize activityIndicator, imageView, lblTitle, lblDescription, hiResURL;

- (void)loadView {
	[super loadView];
	
	// Create a UIView that will fit in the UIScrollView this will be added to and assign it to self.view
	CGRect rect = CGRectMake(0, 0, 270, 190);
	view = [[UIView alloc] initWithFrame:rect];
	[self.view addSubview:view];
	[view setBackgroundColor:[UIColor clearColor]];
	
	// Make a label for the image title and  add it to self.view
	rect = CGRectMake(10, 5, 250, 35);
	lblTitle = [[UILabel alloc] initWithFrame:rect];
	[lblTitle setTextAlignment:UITextAlignmentCenter];
	[lblTitle setTextColor:[UIColor whiteColor]];
	[lblTitle setBackgroundColor:[UIColor clearColor]];
	lblTitle.font = [UIFont systemFontOfSize: 12];
	lblTitle.numberOfLines = 3;
	[view addSubview:lblTitle];
	[lblTitle release];
	
	imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	imageView.multipleTouchEnabled = YES;
	imageView.userInteractionEnabled = YES;
	[view addSubview:imageView];
	[imageView release];
	
	// Make a label for the image description and add it to self.view
	rect = CGRectMake(15, 140, 250, 40);
	[[UILabel alloc] initWithFrame:rect];
	[lblDescription setTextAlignment:UITextAlignmentCenter];
	[lblDescription setTextColor:[UIColor blackColor]];
	[lblDescription setBackgroundColor:[UIColor clearColor]];
	lblDescription.font = [UIFont systemFontOfSize: 12];
	lblDescription.numberOfLines = 3;
	[view addSubview:lblDescription];
	[lblDescription release];
	
	// 
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicator.frame = CGRectMake(view.center.x - 30, view.center.y - 30, 60, 60);
	activityIndicator.hidesWhenStopped = YES;
	[view insertSubview:activityIndicator aboveSubview:imageView];
	[activityIndicator release];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	if (touch.tapCount == 2) {
		imageView.multipleTouchEnabled = NO;
		imageView.userInteractionEnabled = NO;
		[activityIndicator startAnimating];
		[NSThread detachNewThreadSelector:@selector(hiResPool) toTarget:self withObject:nil];
	}
}

- (void)hiResPool {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self getHiRes];
	hiRes = NO;
	[pool release];
}

- (void)getHiRes {
	if (hiRes) {
		[activityIndicator stopAnimating];
		return;
	}
	hiRes = YES;
	
	NSData *imData = [self readPlist:[hiResURL absoluteString]];
	if (imData == nil) {
		imData = [[NSData alloc] initWithContentsOfURL:hiResURL];
		[self writeToPlist:[hiResURL absoluteString] withValue:imData];
	}
	
	UIImage *imageHi = [[UIImage alloc] initWithData:imData];
	[imData release];
	
	CGSize size = imageHi.size;
	CGRect rect;
	
	if (size.height > size.width) {
		CGFloat scalingFactor = size.height / 190;
		CGFloat y = size.width / scalingFactor;
		CGFloat x = 270 - y;
		x = x / 2;
		rect = CGRectMake(x, 0, y, 190);
	} else if (size.height < size.width) {
		CGFloat scalingFactor = size.width / 270;
		CGFloat y = size.height / scalingFactor;
		CGFloat x = 190 - y;
		x = x / 2;
		rect = CGRectMake(0, x, 270, y);
	} else if (size.height == size.width) {
		rect = CGRectMake(40, 0, 190, 190);
	}
	
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.frame = rect;
	[imageView setImage:imageHi];
	[activityIndicator stopAnimating];
}

- (id)readPlist:(NSString *)key {
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	NSString * imageFilePath = [documentsPath stringByAppendingPathComponent: @"hires.plist"];
	
	if ([fileManager fileExistsAtPath:imageFilePath]) {
		NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:imageFilePath];
		[fileManager release];
		return [plistDict objectForKey:key];
	} else {
		[fileManager release];
		return nil;
	}
}

- (BOOL)writeToPlist:(NSString *)key withValue:(id)value {
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	NSString * imageFilePath = [documentsPath stringByAppendingPathComponent: @"hires.plist"];
	
	NSMutableDictionary *plistDict;
	
	if ([fileManager fileExistsAtPath:imageFilePath]) {
		plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:imageFilePath];
	} else {
		plistDict = [[NSMutableDictionary alloc] init];
	}
	
	[plistDict setValue:value forKey:key];
	BOOL success = [plistDict writeToFile:imageFilePath atomically:YES];
	[plistDict release];
	[fileManager release];
	return success;
}

- (void)didReceiveMemoryWarning {
	[view removeFromSuperview];
	[imageView removeFromSuperview];
	[activityIndicator removeFromSuperview];
	[lblTitle release];
	[lblDescription release];
	[hiResURL release];
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[view removeFromSuperview];
	[imageView removeFromSuperview];
	[activityIndicator removeFromSuperview];
	[lblTitle release];
	[lblDescription release];
	[hiResURL release];
    [super dealloc];
}


@end