//
//  NSDataAdditions.h
//  Rainbow
//
//  Created by Luke on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface NSData (Additions)
+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(NSUInteger) lineLength;

- (BOOL) hasPrefixBytes:(const void *) prefix length:(NSUInteger) length;
- (BOOL) hasSuffixBytes:(const void *) suffix length:(NSUInteger) length;
@end
