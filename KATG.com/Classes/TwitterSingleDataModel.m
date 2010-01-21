//
//  TwitterSingleDataModel.m
//  KATG.com
//
//  Created by Doug Russell on 1/20/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#import "TwitterSingleDataModel.h"
#import "TwitterSingleDataModel+PrivateMethods.h"

@implementation TwitterSingleDataModel

@synthesize delegate, shouldStream;

+ (id)model
{
	return [[self alloc] init];
}
- (NSArray *)tweetsForUser:(NSString *)user
{
	return [self _getTweetsForUser:(NSString *)user];
}
- (void)cancelTweets
{
	[self _cancelTweets];
}
- (UIImage *)image:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath
{
	return [self _getImage:imageURL forIndexPath:indexPath];
}

@end
