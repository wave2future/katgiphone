//
//  extractURL.h
//  KATG.com
//
//  Created by Doug Russell on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface extractURL : NSObject {
	NSMutableArray	*urlList;
	NSMutableArray	*urlArray;
	NSString		*urlAddress;
}

@property (nonatomic, retain) NSMutableArray	*urlList;
@property (nonatomic, retain) NSMutableArray	*urlArray;
@property (nonatomic, retain) NSString			*urlAddress;

- (id)makeURLList:(NSString *)tweetString;
- (id)makeURL:(NSString *)tweetString;

@end
