//
//  ImagePageViewController.h
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


@interface ImagePageViewController : UIViewController {
	UIView *view;
	UIActivityIndicatorView *activityIndicator;
	UIImageView *imageView;
	UILabel *lblTitle;
	UILabel *lblDescription;
	NSURL *hiResURL;	
	NSThread *hiResThread;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) UILabel *lblDescription;
@property (nonatomic, retain) NSURL *hiResURL;

- (void)getHiRes;
- (id)readImageData:(NSString *)fileName;
- (BOOL)writeImageData:(NSString *)filename withValue:(NSData *)data;

@end

@interface UIImage (INResizeImageAllocator)
+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
- (UIImage*)scaleImageToSize:(CGSize)newSize;
@end
