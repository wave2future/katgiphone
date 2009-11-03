//
//  ImagePageViewController.h
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
