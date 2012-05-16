//
//  NSStringAdditions.m
//  Rainbow
//
//  Created by Luke on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSStringAdditions.h"


@implementation NSString(Additions)
+ (NSString*)stringWithUUID
{
    // Create a new UUID
	/* kCFAllocatorDefault is a synonym for NULL, if you'd rather use a named constant. */
    CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of the UUID
    NSString *uuidStr = (NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidObj);
    CFRelease(uuidObj);
    return [uuidStr autorelease];
}

-(NSString *) urlEncoded
{
	CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
																	NULL,
																	(CFStringRef)self,
																	NULL,
																	(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																	kCFStringEncodingUTF8 );
    return [(NSString *)urlString autorelease];
}

- (NSString*)encodeAsURIComponent
{
	const char* p = [self UTF8String];
	NSMutableString* result = [NSMutableString string];
	
	for (;*p ;p++) {
		unsigned char c = *p;
		if (('0' <= c && c <= '9') || ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || c == '-' || c == '_') {
			[result appendFormat:@"%c", c];
		} else {
			[result appendFormat:@"%%%02X", c];
		}
	}
	return result;
}

@end
