//
//  stripHTML.h
//  KATG.com
//
//  Created by Doug Russell on 4/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface stripHTML : NSObject {
    NSString* resultString;
}

@property (nonatomic, retain) NSString* resultString;

-(id)processHtml:(NSString *)input;

@end
