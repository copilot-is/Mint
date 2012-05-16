//
//  NSDateAdditions.h
//  Bubble
//
//  Created by Luke on 10/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSDate(Additions)
	- (NSString*)stringWithFormat:(NSString*)fmt;
	+ (NSDate*)dateFromString:(NSString*)str withFormat:(NSString*)fmt;
@end
