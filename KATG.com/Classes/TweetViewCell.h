//
//  TweetViewCell.h
//  KaTGTwitters
//
//  Created by Ashley Mills on 10/04/2009.
//  Copyright 2009 Joylord Systems Ltd.. All rights reserved.
//

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
