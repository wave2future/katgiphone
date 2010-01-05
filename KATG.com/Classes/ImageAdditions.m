//
//  ImageAdditions.m
//  KATG.com
//
//  Created by Doug Russell on 1/4/10.
//  Copyright 2010 Paper Software. All rights reserved.
//

#import "ImageAdditions.h"

UIImage* UIImageForNameExtension(NSString* name, NSString* extension)
{
	return [UIImage imageWithContentsOfFile:
			[[NSBundle mainBundle] pathForResource:name ofType:extension]];
}
