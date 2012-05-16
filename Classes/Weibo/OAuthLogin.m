//
//  OAuthEngine.m
//  Mint
//
//  Created by john on 11-8-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "OAuthLogin.h"

@implementation OAuthLogin

@synthesize delegate,pin;

- (id)init
{
    self = [super init];
    if (self) {
        consumer = [[OAConsumer alloc] initWithKey:OAuthConsumerKey secret:OAuthConsumerSecret];
    }
    
    return self;
}

#pragma mark -
#pragma mark Token
- (void)requestToken
{
    NSURL *url = [NSURL URLWithString:@"http://api.t.sina.com.cn/oauth/request_token"];
    
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil 
                                                                      realm:nil
                                                          signatureProvider:nil] autorelease];
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request 
                         delegate:self 
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:) 
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    if (ticket.didSucceed) {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                        encoding:NSUTF8StringEncoding];
        requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [responseBody release];
        //NSLog(@"Token: %@", requestToken.key);
        [self authorize];
    }
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSData *)data {
    NSLog(@"oauth token error: %@", data);
}

#pragma mark -
#pragma mark 用户认证
- (void)authorize
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.t.sina.com.cn/oauth/authorize?oauth_token=%@", requestToken.key]];

    [[NSWorkspace sharedWorkspace] openURL:url];
}

#pragma mark -
#pragma mark accessToken
- (void)requestAccessToken
{
    //requestToken.verifier = pin;
    NSURL *url = [NSURL URLWithString:@"http://api.t.sina.com.cn/oauth/access_token"];
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:requestToken
                                                                      realm:nil
                                                          signatureProvider:nil] autorelease];
    [request setHTTPMethod:@"POST"];
    [request setOAuthParameterName:@"oauth_callback" withValue:@"oob"];
    [request setOAuthParameterName:@"oauth_verifier" withValue:self.pin];
    
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request 
                         delegate:self 
                didFinishSelector:@selector(requestAccessTokenTicket:didFinishWithData:) 
                  didFailSelector:@selector(requestAccessTokenTicket:didFailWithError:)];
}

- (void)requestAccessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed){
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];

		accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        [responseBody release];
        //NSLog(@"key: %@, secret: %@", accessToken.key, accessToken.secret);
        [self requestVerify];
	}
}

- (void)requestAccessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSData *)data {
    NSLog(@"oauth access token error: %@", data);
}

//用户验证
- (void)requestVerify {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://api.t.sina.com.cn/account/verify_credentials.json"]];
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:accessToken   // requestToken 
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil] autorelease];
	[request prepare];
    
	OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestVerifyTicket:didFinishWithData:)
                  didFailSelector:@selector(requestVerifyTicket:didFailWithError:)];
}

- (void)requestVerifyTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *responseBody = [[NSString alloc] initWithData:data
												   encoding:NSUTF8StringEncoding];
    
    NSArray* arguments = [NSArray arrayWithObjects:accessToken.key, accessToken.secret, nil];
    
    [self.delegate performSelector:@selector(oauthSuccess:user:) withObject:arguments withObject:[responseBody JSONValue]];
    
    [responseBody release];
}

- (void)requestVerifyTicket:(OAServiceTicket *)ticket didFailWithError:(NSData *)data {
    NSLog(@"oauth verify error: %@", data);
}

-(void)dealloc
{
    [consumer release];
    [accessToken release];
    [requestToken release];
    [pin release];
    [super dealloc];
}

@end
