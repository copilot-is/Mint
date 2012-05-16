//
//  OAuthEngine.h
//  Mint
//
//  Created by john on 11-8-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "OAuthConsumer.h"
#import "WeiboAccount.h"
#import "AccountController.h"

@protocol OAuthLoginDelegate;

@interface OAuthLogin : NSObject {
    id <OAuthLoginDelegate> delegate;
    OAToken *requestToken;
    OAToken *accessToken;
    OAConsumer *consumer;
    NSString *pin;
}

@property(nonatomic,assign) id <OAuthLoginDelegate> delegate;
@property(nonatomic,retain) NSString *pin;

- (void)requestToken;
- (void)authorize;
- (void)requestAccessToken;
- (void)requestVerify;

@end

@protocol OAuthLoginDelegate <NSObject>

- (void)oauthSuccess:(NSArray*)toKen user:(NSObject*)user;

@end
