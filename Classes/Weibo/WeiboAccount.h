//
//  WeiboAccount.h
//  Bubble
//
//  Created by Luke on 12/9/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WeiboAccount : NSObject {
    NSString *userID;
	NSString *screenName;
    NSString *tokenKey;
    NSString *tokenSecret;
}

@property(nonatomic,retain) NSString *userID;
@property(nonatomic,retain) NSString *screenName;
@property(nonatomic,retain) NSString *tokenKey;
@property(nonatomic,retain) NSString *tokenSecret;

@end
