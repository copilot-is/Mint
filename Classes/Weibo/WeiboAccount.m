//
//  WeiboAccount.m
//  Bubble
//
//  Created by Luke on 12/9/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboAccount.h"

@implementation WeiboAccount

@synthesize userID,screenName,tokenKey,tokenSecret;

- (void)dealloc
{
    [userID release];
    [screenName release];
    [tokenKey release];
    [tokenSecret release];
    [super dealloc];
}

@end
