//
//  WeiboURLConnection.h
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSStringAdditions.h"

@interface WeiboURLConnection : NSURLConnection {
	NSMutableData *data;
	NSString *identifier;

	id completionTarget;
	SEL completionAction;
}
@property(nonatomic,retain) NSMutableData *data;
@property(nonatomic,retain) NSString *identifier;
@property(assign) id completionTarget;
@property(assign) SEL completionAction;

- (id)initWithRequest:(NSMutableURLRequest*) request delegate:(id)delegate;
- (void)appendData:(NSData *)data;
- (void)resetDataLength;

@end
