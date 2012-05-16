//
//  NSStringAdditions.h
//  Rainbow
//
//  Created by Luke on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString(Additions)

+ (NSString*) stringWithUUID;
- (NSString*) urlEncoded;
- (NSString*)encodeAsURIComponent;

@end
