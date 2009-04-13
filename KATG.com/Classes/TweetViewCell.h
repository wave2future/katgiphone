//
//  TweetViewCell.h
//  KATG.com
//
//  Created by Ashley Mills on 10/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
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

@interface TweetViewCell : UITableViewCell {
	IBOutlet UIImageView *icon;
	IBOutlet UITextView *tweet;
	IBOutlet UILabel *since;
	NSString * tweetText;
	NSString * fromText;
	NSString * sinceText;
	NSString *imageURL;
	
	UIImage * iconImage;
}

static CGFunctionRef createFunctionForRGB(CGFunctionEvaluateCallback evaluationFunction);
static void KaTGGreenShading (void * info, const float * in, float * out);
void addRoundedRectPathToContext(CGContextRef ctx, CGRect rect, CGFloat lineWidth, CGFloat cornerRadius);

@property (nonatomic, retain) NSString * tweetText;
@property (nonatomic, retain) NSString * sinceText;
@property (nonatomic, retain) NSString * fromText;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) UIImage * iconImage;

@end
