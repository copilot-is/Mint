//
//  NSDateAdditions.m
//  Bubble
//
//  Created by Luke on 10/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDateAdditions.h"


@implementation NSDate(Additions)
- (NSString*)stringWithFormat:(NSString*)fmt {
    static NSDateFormatter *fmtter;
	
    if (fmtter == nil) {
        fmtter = [[NSDateFormatter alloc] init];
    }
	
    if (fmt == nil || [fmt isEqualToString:@""]) {
        fmt = @"HH:mm:ss";
    }
	
    [fmtter setDateFormat:fmt];
	
    return [fmtter stringFromDate:self];
}

+ (NSDate*)dateFromString:(NSString*)str withFormat:(NSString*)fmt {
    static NSDateFormatter *fmtter;
	
    if (fmtter == nil) {
        fmtter = [[NSDateFormatter alloc] init];
    }
	
    if (fmt == nil || [fmt isEqualToString:@""]) {
        fmt = @"HH:mm:ss";
    }
	
    [fmtter setDateFormat:fmt];
	
    return [fmtter dateFromString:str];
}
@end
