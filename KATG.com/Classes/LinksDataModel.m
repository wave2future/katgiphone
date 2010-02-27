//
//  LinksDataModel.m
//  KATG.com
//
//  Created by Doug Russell on 1/20/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#import "LinksDataModel.h"
#import "LinksDataModel+PrivateMethods.h"
#import "FlurryAPI.h"

@implementation LinksDataModel

@synthesize delegate, shouldStream;

+ (id)model
{
	return [[self alloc] init];
}
- (NSArray *)links
{
	[FlurryAPI logEvent:@"links"];
	return [self _getLinks];
}
- (void)cancel
{
	[self _cancel];
}

@end
