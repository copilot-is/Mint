//
//  WeiboURLConnection.m
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboURLConnection.h"

@implementation WeiboURLConnection

@synthesize data,identifier,completionTarget,completionAction;

- (id)initWithRequest:(NSMutableURLRequest*)request delegate:(id)delegate
{
	if ((self = [super initWithRequest:request delegate:delegate])) {
		self.data = [[[NSMutableData alloc] initWithCapacity:0] autorelease];
        self.identifier = [[[NSString stringWithUUID] retain] autorelease];
	}
	return self;
}

- (void)appendData:(NSData *)aData
{
    [self.data appendData:aData];
}

- (void)resetDataLength
{
    [self.data setLength:0];
}

- (void)dealloc
{
	[data release];
	[identifier release];
	[super dealloc];
}
@end
