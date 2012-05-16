//
//  NSURLAdditions.h
//  Rainbow
//
//  Created by Luke on 9/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSURL(Additions) 

+ (NSString*) urlStringWithBaseurl:(NSString*) baseurl path:(NSString*)path queryParameters:(NSDictionary *) params;
+ (NSString *)encodeString:(NSString *)string;
@end
