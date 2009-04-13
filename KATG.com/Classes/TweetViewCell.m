//
//  TweetViewCell.m
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

#import "TweetViewCell.h"


@implementation TweetViewCell
@synthesize tweetText;
@synthesize fromText;
@synthesize sinceText;
@synthesize iconImage;
@synthesize imageURL;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGFunctionRef shadingFunction = createFunctionForRGB(KaTGGreenShading);
	CGShadingRef shadingRef = CGShadingCreateAxial(CGColorSpaceCreateDeviceRGB(), rect.origin, CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), shadingFunction, false, false);
	CGFunctionRelease(shadingFunction);
	
	addRoundedRectPathToContext(ctx, rect, 1.5f, 5.0f);
	CGContextClip(ctx);
	
	CGContextDrawShading(ctx, shadingRef);
	CGShadingRelease(shadingRef);
	
	CGContextSetLineWidth(ctx, 1.5f);
	CGContextSetStrokeColorWithColor(ctx, [[UIColor blackColor] CGColor]);
	CGContextStrokePath(ctx);
	
	[[UIColor blackColor] setFill];
	[fromText drawAtPoint: CGPointMake(50.0, 2.0) withFont: [UIFont boldSystemFontOfSize: 12.0f]];
	
	CGRect textRect = CGRectMake(50.0, 17.0, 220.0, rect.size.height - 20.0);
	[tweetText drawInRect: textRect withFont: [UIFont systemFontOfSize: 12.0f]];
	
	CGSize textSize = [sinceText sizeWithFont: [UIFont systemFontOfSize: 12.0f]];
	textRect = CGRectMake(315.0 - textSize.width, 3.0, textSize.width, textSize.height);
	[[UIColor blueColor] setFill];
	[sinceText drawInRect: textRect withFont: [UIFont systemFontOfSize: 12.0f]];
	
	if (iconImage != nil) {
		CGRect iconRect = CGRectMake(5.0, (rect.size.height - 36.0) / 2.0f, 36.0, 36.0);
		addRoundedRectPathToContext(ctx, iconRect, 1.0f, 4.0f);
		CGContextClip(ctx);
		[iconImage drawInRect: iconRect];
	}
}

void addRoundedRectPathToContext(CGContextRef ctx, CGRect rect, CGFloat lineWidth, CGFloat cornerRadius)
{
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, 
						 rect.origin.x + lineWidth, 
						 rect.origin.y + rect.size.height - cornerRadius);
	CGContextAddArcToPoint(ctx, 
						   rect.origin.x + lineWidth, 
						   rect.origin.y + lineWidth, 
						   rect.origin.x + cornerRadius, 
						   rect.origin.y + lineWidth, cornerRadius);
	CGContextAddArcToPoint(ctx, 
						   rect.origin.x + rect.size.width - lineWidth, 
						   rect.origin.y + lineWidth, 
						   rect.origin.x + rect.size.width - lineWidth, 
						   rect.origin.y + cornerRadius, cornerRadius);
	CGContextAddArcToPoint(ctx, 
						   rect.origin.x + rect.size.width - lineWidth, 
						   rect.origin.y + rect.size.height - lineWidth, 
						   rect.origin.x + rect.size.width - lineWidth - cornerRadius, 
						   rect.origin.y + rect.size.height - lineWidth, cornerRadius);
	CGContextAddArcToPoint(ctx, 
						   rect.origin.x + lineWidth, 
						   rect.origin.y + rect.size.height - lineWidth, 
						   rect.origin.x + lineWidth, 
						   rect.origin.y + rect.size.height - lineWidth - cornerRadius, cornerRadius);
	CGContextClosePath(ctx);
	
}

static CGFunctionRef createFunctionForRGB(CGFunctionEvaluateCallback evaluationFunction)
{
	CGFunctionRef function;
	float domain[] = {0,1};
	float range[] = {0,1,0,1,0,1,0,1};
	CGFunctionCallbacks shadingCallbacks;
	shadingCallbacks.version = 0;
	shadingCallbacks.evaluate = evaluationFunction;
	shadingCallbacks.releaseInfo = NULL;
	
	function = CGFunctionCreate(NULL, 1, domain, 4, range, &shadingCallbacks);
	return function;
}

static void KaTGGreenShading (void * info, const float * in, float * out)
{
	out[0] = (50.0f - (in[0] * 30.0f)) / 256.0;
	out[1] = (180.0f - (in[0] * 40.0f)) / 256.0;
	out[2] = 0.0f;
	out[3] = 1.0f;
}


- (void)dealloc {
	tweetText = nil;
	fromText = nil;
	sinceText = nil;
	imageURL = nil;
	iconImage = nil;
    [super dealloc];
}


@end
