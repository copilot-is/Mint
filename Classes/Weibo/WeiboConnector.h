//
//  WeiboConnector.h
//  Rainbow
//
//  Created by Luke on 8/28/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "OAuthConsumer.h"
#import "NSDataAdditions.h"
#import "NSURLAdditions.h"
#import "NSStringAdditions.h"
#import "JSON.h"
#import "WeiboGlobal.h"
#import "WeiboAccount.h"
#import "WeiboURLConnection.h"

#define WEIBO_BASE_URL @"http://api.t.sina.com.cn"

@interface WeiboConnector : NSObject {
	NSMutableDictionary *_connections;
	NSString *multipartBoundary;
    
    OAToken *accessToken;
    OAConsumer *consumer;
}

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret;
#pragma mark properties


#pragma mark REST API methods

//verify_credentials
-(NSString *) verifyAccountWithParameters:(NSMutableDictionary*)params 
						 completionTarget:(id)target  
						 completionAction:(SEL)action;

//check unread
-(NSString *)checkUnreadWithParameters:(NSMutableDictionary*)params 
					  completionTarget:(id)target  
					  completionAction:(SEL)action;

-(NSString *) createFriendshipsWithParameters:(NSMutableDictionary*)params
                             completionTarget:(id)target
                             completionAction:(SEL)action;
//timeline
-(NSString *) getHomeTimelineWithParameters:(NSMutableDictionary*)params 
						   completionTarget:(id)target
                           completionAction:(SEL)action;

-(NSString *) getMentionsWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action;

-(NSString *) getCommentsWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action;

-(NSString *) getFavoritesWithParameters:(NSMutableDictionary*)params
                        completionTarget:(id)target
                        completionAction:(SEL)action;

-(NSString *) destroyStatusWithParameters:(NSMutableDictionary*)params
                         completionTarget:(id)target
                         completionAction:(SEL)action;

-(NSString *) updateWithStatus:(NSString*)status					   
			  completionTarget:(id)target
			  completionAction:(SEL)action;

-(NSString*) updateWithStatus:(NSString *)status 
						image:(NSData*)imageData
					imageName:(NSString*)imageName
			 completionTarget:(id)target 
			 completionAction:(SEL)action;

-(NSString *) getUserWithParameters:(NSMutableDictionary*)params 
                   completionTarget:(id)target
                   completionAction:(SEL)action;

-(NSString *) getFriendsWithParameters:(NSMutableDictionary*)params 
                      completionTarget:(id)target
                      completionAction:(SEL)action;

-(NSString *) getStatusCommentsWithParameters:(NSMutableDictionary*)params 
                             completionTarget:(id)target
                             completionAction:(SEL)action;

-(NSString *) replyWithParameters:(NSMutableDictionary*)params
                 completionTarget:(id)target
                 completionAction:(SEL)action;

-(NSString *) repostWithParamters:(NSMutableDictionary*)params
				 completionTarget:(id)target
				 completionAction:(SEL)action;

-(NSString *) showStatusWithParameters:(NSMutableDictionary*)params 
                      completionTarget:(id)target
                      completionAction:(SEL)action;


-(NSString *) destroyFavoritesWithParameters:(NSMutableDictionary*)params
							completionTarget:(id)target
							completionAction:(SEL)action;

-(NSString *) createFavoritesWithParameters:(NSMutableDictionary*)params
						   completionTarget:(id)target
						   completionAction:(SEL)action;

-(NSString *) getUserTimelineWithParameters:(NSMutableDictionary*)params
                           completionTarget:(id)target
                           completionAction:(SEL)action;

-(NSString *) getFollowersWithParameters:(NSMutableDictionary*)params
                        completionTarget:(id)target
                        completionAction:(SEL)action;

-(NSString *) resetCountWithParameters:(NSMutableDictionary*)params 
                      completionTarget:(id)target
                      completionAction:(SEL)action;

-(NSString *)shortenShortURLWithParameters:(NSMutableDictionary*)params
                          completionTarget:(id)target
                          completionAction:(SEL)action;

-(NSString *)expandShortURLWithParameters:(NSMutableDictionary*)params
                         completionTarget:(id)target
                         completionAction:(SEL)action;

-(NSString *)_generateTimestamp;
-(NSString *)_generateNonce;

@end