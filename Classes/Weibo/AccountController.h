//
//  WeiboAccount.h
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboConnector.h"
#import "WeiboGlobal.h"
#import "WeiboTimeline.h"
#import "WeiboAccount.h"

//1. 评论数，2. @me数，3. 关注数
typedef enum {
	CommentCount=1,
	AtCount,
	FollowerCount
}StatusResetType;

@interface AccountController : NSObject {
    __weak WeiboAccount *currentAccount;
	WeiboConnector *weiboConnector;
	WeiboTimeline *homeTimeline;
	WeiboTimeline *mentions;
	WeiboTimeline *comments;
	WeiboTimeline *favorites;
}

@property(nonatomic,assign) WeiboAccount *currentAccount;
@property(nonatomic,retain) WeiboConnector *weiboConnector;
@property(nonatomic,retain) WeiboTimeline *homeTimeline;
@property(nonatomic,retain) WeiboTimeline *mentions;
@property(nonatomic,retain) WeiboTimeline *comments;
@property(nonatomic,retain) WeiboTimeline *favorites;

+(AccountController*)instance;

-(void)verifyCurrentAccount;
-(void)didVerifyCurrentAccount:(id)result;
-(void)checkUnread;
-(void)didCheckUnread:(NSDictionary*)result;
-(void)resetCount:(StatusResetType)resetType;
-(void)didResetCount:(NSDictionary*)result;

-(WeiboAccount*)getCurrentAccount;
-(void)delCurrentAccount:(NSString*)screenName;
-(void)setCurrentAccount:(WeiboAccount *)account;

-(void)resetTimelines;

//weibo api related
-(void)destroyStatus:(NSString *)statusId;
-(void)createFriendships:(NSString *)userId;
-(void)postWithStatus:(NSString*)status;
-(void)postWithStatus:(NSString*)status image:(NSData*)data imageName:(NSString*)imageName;
-(void)didPost:(id)result;
-(void)reply:(id)data;
-(void)repost:(id)data;
-(void)createFavorites:(NSString *)statusId;
-(void)destroyFavorites:(NSString *)statusId;
-(void)getUserTimeline:(NSDictionary*)param;
-(void)didGetUserTimeline:(NSArray*)result;
-(void)getFollowers:(NSDictionary*)param;
-(void)didGetFollowers:(NSArray*)result;
-(void)expandShortURL:(NSString *)urlShort;
-(void)didExpandShortURL:(NSDictionary*)result;

@end
