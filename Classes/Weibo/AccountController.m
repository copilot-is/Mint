//
//  WeiboAccount.m
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountController.h"
#import "PathController.h"

@implementation AccountController

@synthesize homeTimeline,mentions,comments,favorites,currentAccount,weiboConnector;

+(AccountController*)instance  {
    static AccountController *instance;
    @synchronized(self) {
        if(!instance) {
            instance = [[self alloc] init]; 
        }
    }
    return instance;
}

#pragma mark Initializers
-(id)init{
	if (self = [super init]) {
        NSString *tokenKey = [currentAccount tokenKey];
        NSString *tokenSecret = [currentAccount tokenSecret];
        self.weiboConnector = [[[WeiboConnector alloc] initWithKey:tokenKey secret:tokenSecret] autorelease];
        
        self.homeTimeline = [[[WeiboTimeline alloc] initWithWeiboConnector:self.weiboConnector timelineType:Home] autorelease];
		self.mentions = [[[WeiboTimeline alloc] initWithWeiboConnector:self.weiboConnector timelineType:Mentions] autorelease];
		self.comments = [[[WeiboTimeline alloc] initWithWeiboConnector:self.weiboConnector timelineType:Comments] autorelease];
		self.favorites = [[[WeiboTimeline alloc] initWithWeiboConnector:self.weiboConnector timelineType:Favorites] autorelease];
        
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
		[nc addObserver:self selector:@selector(getUser:)
				   name:GetUserNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(getFriends:)
				   name:GetFriendsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(getStatusComments:)
				   name:GetStatusCommentsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(showStatus:)
				   name:ShowStatusNotification 
				 object:nil];
    }
	return self;
}

-(void)checkUnread{
	if (self.currentAccount) {
		//定期刷新页面，使得显示的时间定期更新
		[[NSNotificationCenter defaultCenter] postNotificationName:ReloadTimelineNotification object:self];
		
		NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
		[params setObject:@"1" forKey:@"with_new_status"];
		[params setObject:[NSString stringWithFormat:@"%@",self.homeTimeline.lastReceivedId] forKey:@"since_id"];
		[self.weiboConnector checkUnreadWithParameters:params
								 completionTarget:self
								 completionAction:@selector(didCheckUnread:)];
	}
}

// 检查新消息数
-(void)didCheckUnread:(NSDictionary*)result{    
    [[NSNotificationCenter defaultCenter] postNotificationName:NewNotification
														object:result];
}


-(void)resetCount:(StatusResetType)resetType{
	NSMutableDictionary *params=[NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:[NSString stringWithFormat:@"%d",resetType] forKey:@"type"];
	[self.weiboConnector resetCountWithParameters:params 
							completionTarget:self 
							completionAction:@selector(didResetCount:)];
}
-(void)didResetCount:(NSDictionary*)result{
	
}

-(void)getUserTimeline:(NSMutableDictionary*)param{
	[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification
														object: nil];
	[self.weiboConnector getUserTimelineWithParameters:param
							 completionTarget:self
							 completionAction:@selector(didGetUserTimeline:)];
}
-(void)didGetUserTimeline:(NSArray*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetUserTimelineNotification
														object:result];
}

-(void)getFollowers:(NSMutableDictionary*)param{
	[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification
														object: nil];
	[self.weiboConnector getFollowersWithParameters:param
								 completionTarget:self
								 completionAction:@selector(didGetFollowers:)];
}
-(void)didGetFollowers:(NSArray*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetFollowersNotification
														object:result];
}

#pragma mark Account
-(WeiboAccount*)getCurrentAccount{
	if (!self.currentAccount) {
        NSDictionary *accounts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"accounts"];
        if ([accounts count]>0) {
            
            for (NSString *account in accounts){
                if ([[accounts objectForKey:account] objectForKey:@"default"]) {
                    currentAccount = [[WeiboAccount alloc] init];
                    currentAccount.userID = account;
                    currentAccount.screenName = [[accounts objectForKey:account] objectForKey:@"screenName"];
                    currentAccount.tokenKey = [[accounts objectForKey:account] objectForKey:@"tokenKey"];
                    currentAccount.tokenSecret = [[accounts objectForKey:account] objectForKey:@"tokenSecret"];
                }
            }
            [self init];
        }
	}
	return currentAccount;
}

-(void)delCurrentAccount:(NSString*)userid
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *accounts = [defaults dictionaryForKey:@"accounts"];
    [defaults removeObjectForKey:@"accounts"];
    if ([accounts count] > 0) {
        for (NSString *account in accounts){            
            if (![account isEqualToString:userid]) {
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[accounts objectForKey:account] objectForKey:@"screenName"],@"screenName",[[accounts objectForKey:account] objectForKey:@"tokenKey"],@"tokenKey",[[accounts objectForKey:account] objectForKey:@"tokenSecret"],@"tokenSecret", nil];
                NSDictionary *dicu = [NSDictionary dictionaryWithObjectsAndKeys:dic,[NSString stringWithFormat:@"%@",account], nil];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:dicu,@"accounts", nil];
                
                [defaults setValuesForKeysWithDictionary:dict];
            }
        }
    }

    [defaults removeObjectForKey:[NSString stringWithFormat:@"statuses/%@/home.scrollPosition",currentAccount.screenName]];
    [defaults removeObjectForKey:[NSString stringWithFormat:@"statuses/%@/mentions.scrollPosition",currentAccount.screenName]];
    [defaults removeObjectForKey:[NSString stringWithFormat:@"statuses/%@/comments.scrollPosition",currentAccount.screenName]];
    [defaults removeObjectForKey:[NSString stringWithFormat:@"statuses/%@/favorites.scrollPosition",currentAccount.screenName]];
    [defaults removeObjectForKey:[NSString stringWithFormat:@"statuses/%@/directMessages.scrollPosition",currentAccount.screenName]];
    [defaults synchronize];
    currentAccount = nil;
}

-(void)setCurrentAccount:(WeiboAccount *)account{
    currentAccount = account;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool: YES], @"default",account.screenName,@"screenName",account.tokenKey,@"tokenKey",account.tokenSecret,@"tokenSecret", nil];
    NSDictionary *dicu = [NSDictionary dictionaryWithObjectsAndKeys:dic,[NSString stringWithFormat:@"%@",account.userID], nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:dicu,@"accounts", nil];
    
    //NSLog(@"NSUserDefaults: %@",dict);
    
    [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:dict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self init];
}

-(void)verifyCurrentAccount{
    if ([self getCurrentAccount]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification object:nil];
		NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
		[self.weiboConnector verifyAccountWithParameters:params
								   completionTarget:self
								   completionAction:@selector(didVerifyCurrentAccount:)];
    }
}

-(void)didVerifyCurrentAccount:(id)result{
	NSDictionary *jsonResult=(NSDictionary*)result;
	if ([jsonResult objectForKey:@"screen_name"]) {
        currentAccount.screenName=[jsonResult objectForKey:@"screen_name"];
		[[PathController instance].currentTimeline loadRecentTimeline];
		[[NSNotificationCenter defaultCenter] postNotificationName:AccountVerifiedNotification
															object:result];
	}
}

//reset all the timeline
-(void)resetTimelines{
	[homeTimeline reset];
	[mentions reset];
	[comments reset];
	[favorites reset];
}

#pragma mark 操作
-(void)destroyStatus:(NSString *)statusId{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:statusId forKey:@"id"];
	[self.weiboConnector destroyStatusWithParameters:params
                                  completionTarget:self
                                  completionAction:@selector(didDestroyStatus:)];
}
-(void)didDestroyStatus:(NSDictionary*)result{
    
}

#pragma mark - 
#pragma mark 关注用户
-(void)createFriendships:(NSString *)userId{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:userId forKey:@"id"];
	[self.weiboConnector createFriendshipsWithParameters:params
                               completionTarget:self
                               completionAction:@selector(didCreateFriendships:)];
}
-(void)didCreateFriendships:(NSDictionary*)result{
    NSLog(@"didCreateFriendships: %@",result);
}

-(void)postWithStatus:(NSString*)status{
	[self.weiboConnector updateWithStatus:status 
					completionTarget:self 
					completionAction:@selector(didPost:)];
}
-(void)postWithStatus:(NSString*)status image:(NSData*)data imageName:(NSString*)imageName{
    
	[self.weiboConnector updateWithStatus:status 
						   image:data
						   imageName:imageName
					completionTarget:self 
					completionAction:@selector(didPost:)];
}

-(void)didPost:(id)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidPostStatusNotification
														object:nil];
}

-(void)reply:(id)data{
	[self.weiboConnector replyWithParameters:data
						completionTarget:self
						completionAction:@selector(didPost:)];
}


-(void)repost:(id)data{
	[self.weiboConnector repostWithParamters:data
					  completionTarget:self
					  completionAction:@selector(didPost:)];
}


-(void)getUser:(NSNotification*)notification{
	NSDictionary *data=[notification object];
	NSString *fetchWith=[data valueForKey:@"fetch_with"];
	NSString *value=[data valueForKey:@"value"];
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:value forKey:fetchWith];
	[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification object:nil];
	[self.weiboConnector getUserWithParameters:params
						completionTarget:self
						completionAction:@selector(didGetUser:)];
}

-(void)didGetUser:(NSDictionary*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetUserNotification
														object:result];
}

-(void)getFriends:(NSNotification*)notification{
	NSMutableDictionary* params =[[[notification object] mutableCopy] autorelease];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification object:nil];
	[self.weiboConnector getFriendsWithParameters:params
						completionTarget:self
						completionAction:@selector(didGetFriends:)];
}

-(void)didGetFriends:(NSArray*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetFriendsNotification
														object:result];
}

-(void)showStatus:(NSNotification*)notification{
	NSString *statusId=[notification object];
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:statusId forKey:@"id"];
	[params setObject:@"-1" forKey:@"cursor"];
	[self.weiboConnector showStatusWithParameters:params
								  completionTarget:self
								  completionAction:@selector(didShowStatus:)];
}
-(void)didShowStatus:(NSDictionary*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidShowStatusNotification
														object:result];
}


-(void)getStatusComments:(NSNotification*)notification{
	[self.weiboConnector getStatusCommentsWithParameters:[notification object]
						   completionTarget:self
						   completionAction:@selector(didGetStatusComments:)];
}

-(void)didGetStatusComments:(NSArray*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetStatusCommentsNotification
														object:result];
}

-(void)createFavorites:(NSString *)statusId{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:statusId forKey:@"id"];
	[self.weiboConnector createFavoritesWithParameters:params
								  completionTarget:self
								  completionAction:@selector(didCreateFavorites:)];
}
-(void)didCreateFavorites:(NSDictionary*)result{
	
}

-(void)destroyFavorites:(NSString *)statusId{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:statusId forKey:@"id"];
	[self.weiboConnector destroyFavoritesWithParameters:params
								 completionTarget:self
								 completionAction:@selector(didDestroyFavorites:)];
}
-(void)didDestroyFavorites:(NSDictionary*)result{

}

-(void)expandShortURL:(NSString *)urlShort{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:urlShort forKey:@"url_short"];
	[self.weiboConnector expandShortURLWithParameters:params
                                       completionTarget:self
                                       completionAction:@selector(didExpandShortURL:)];
}
-(void)didExpandShortURL:(NSDictionary*)result{
    [[NSNotificationCenter defaultCenter] postNotificationName:DidExpandShortURLNotification
														object:result];
}

-(void)dealloc{
    [weiboConnector release];
	[homeTimeline release];
    [mentions release];
    [comments release];
    [favorites release];
    [currentAccount release];
	[super dealloc];
}
@end
