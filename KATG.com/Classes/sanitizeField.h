//
//  sanitizeField.h
//  KATG.com
//
//  Created by Doug Russell on 4/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface sanitizeField : NSObject {
	NSString *cleanString;
}

- (id)init;

- (id)stringCleaner:(NSString *)dirtString;

@end
