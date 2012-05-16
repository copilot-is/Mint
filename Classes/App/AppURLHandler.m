//
//  AppURLHandler.m
//  Bubble
//
//  Created by Luke on 10/20/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppURLHandler.h"
#import "AccountController.h"

@implementation AppURLHandler

-(void)handleURL:(NSString*)urlString{	
	NSURL *url=[NSURL URLWithString:urlString];
	if (!url) {
		return;
	}
    
	if (![[url resourceSpecifier] hasPrefix:@"//"]) {
		urlString = [NSString stringWithFormat:@"%@://%@", [url scheme], [url resourceSpecifier]];
		url = [NSURL URLWithString:urlString];
	}
	
	NSString *schema = [url scheme];
	NSString *host = [url host];
	NSString *add=[[url queryArgumentForKey:@"add"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
	if ([schema isEqualToString:@"weibo"]) {		
		if ([host isEqualToString:@"load_older_timeline"]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:StartLoadOlderTimelineNotification object:nil];
		}
		if ([host isEqualToString:@"home_timeline_status_click"]) {
			NSString *statusId = [[url queryArgumentForKey:@"id"] 
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[NSNotificationCenter defaultCenter] postNotificationName:DidClickTimelineNotification object:statusId];
		}
		if ([host isEqualToString:@"user"]) {
			if (!add) {
				[[PathController instance] add:urlString];
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification object:nil];
            
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			[data setObject:[url queryArgumentForKey:@"fetch_with"] forKey:@"fetch_with"];
			[data setObject:[[url queryArgumentForKey:@"value"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"value"];
			[[NSNotificationCenter defaultCenter] postNotificationName:GetUserNotification object:data];
			
		}
		if ([host isEqualToString:@"image"]) {
			NSString *imageUrl=[[url queryArgumentForKey:@"url"] 
								stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[NSNotificationCenter defaultCenter]postNotificationName:DisplayImageNotification object:imageUrl];
		}
		if ([host isEqualToString:@"friends"]) {
			NSString *screenName=[[url queryArgumentForKey:@"screen_name"] 
								  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			if (!add) {
				[[PathController instance] add:urlString];
				[PathController instance].currentType=Following;
				[PathController instance].idWithCurrentType=screenName;
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification object:nil];
            
            
			NSString *cursor=[[url queryArgumentForKey:@"cursor"] 
                              stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			[data setObject:screenName forKey:@"screen_name"];
			[data setObject:cursor forKey:@"cursor"];
			[[NSNotificationCenter defaultCenter]postNotificationName:GetFriendsNotification object:data];
		}
		if ([host isEqualToString:@"followers"]) {
			NSString *screenName=[[url queryArgumentForKey:@"screen_name"] 
								  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			if (!add) {
				[[PathController instance] add:urlString];
				[PathController instance].currentType=Followers;
				[PathController instance].idWithCurrentType=screenName;
			}
			
			NSString *cursor=[[url queryArgumentForKey:@"cursor"] 
							  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			[data setObject:screenName forKey:@"screen_name"];
			[data setObject:cursor forKey:@"cursor"];
			[[AccountController instance] getFollowers:data];
		}
		if ([host isEqualToString:@"status_comments"]) {
			NSString *statusId=[[url queryArgumentForKey:@"sid"] 
								stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			if (!add) {
				[[PathController instance] add:urlString];
				[PathController instance].currentType=StatusDetail;
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification object:nil];
            
            
            
			[[NSNotificationCenter defaultCenter]postNotificationName:ShowStatusNotification object:statusId];
		}
		if ([host isEqualToString:@"get_comments"]) {
			NSString *statusId=[[url queryArgumentForKey:@"id"] 
								stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *page=[[url queryArgumentForKey:@"page"] 
							stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[PathController instance].idWithCurrentType=[NSString stringWithFormat:@"%@:%@",statusId,page];
            
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			[data setObject:statusId forKey:@"id"];
			[data setObject:page forKey:@"page"];
			[[NSNotificationCenter defaultCenter] postNotificationName:GetStatusCommentsNotification 
																object:data];
		}
		if ([host isEqualToString:@"timeline"]) {
			NSString *screenName=[[url queryArgumentForKey:@"screen_name"] 
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *page=[[url queryArgumentForKey:@"page"]
							stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			if (!add) {
				[[PathController instance] add:urlString];
				[PathController instance].currentType=UserTimeline;
				[PathController instance].idWithCurrentType=[NSString stringWithFormat:@"%@:%@",screenName,page];
			}
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			[data setObject:screenName forKey:@"screen_name"];
			[data setObject:page forKey:@"page"];
			[[AccountController instance] getUserTimeline:data];
            
		}
		if ([host isEqualToString:@"reply"]) {
			NSString *sid=[[url queryArgumentForKey:@"id"] 
                           stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *cid=[[url queryArgumentForKey:@"cid"] 
                           stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *user=[[url queryArgumentForKey:@"user"] 
                            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *content=[[url queryArgumentForKey:@"content"] 
                               stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *avatar = [[url queryArgumentForKey:@"avatar"] 
                                stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *type = [[url queryArgumentForKey:@"type"] 
                                stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			if (cid!=nil) {
				[data setObject:cid forKey:@"cid"];
			}
			if (sid!=nil) {
				[data setObject:sid forKey:@"id"];
			}
			[data setObject:user forKey:@"user"];
			[data setObject:content forKey:@"content"];
            [data setObject:avatar forKey:@"avatar"];
            [data setObject:type forKey:@"type"];
			[[NSNotificationCenter defaultCenter]postNotificationName:ReplyNotification object:data];
		}
		if ([host isEqualToString:@"repost"]) {
			NSString *sid=[[url queryArgumentForKey:@"id"] 
						   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *content=[[url queryArgumentForKey:@"content"] 
							   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *user=[[url queryArgumentForKey:@"user"] 
                            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *rt_content=[[url queryArgumentForKey:@"rt_content"] 
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *rt_user=[[url queryArgumentForKey:@"rt_user"] 
                               stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *avatar = [[url queryArgumentForKey:@"avatar"] 
                                stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			if (sid) {
				[data setObject:sid forKey:@"id"];
			}
			if (content) {
				[data setObject:content forKey:@"content"];
			}
			if (user) {
				[data setObject:user forKey:@"user"];
			}
			if (rt_content) {
				[data setObject:rt_content forKey:@"rt_content"];
			}
			if (rt_user) {
				[data setObject:rt_user forKey:@"rt_user"];
			}
            [data setObject:avatar forKey:@"avatar"];
			[[NSNotificationCenter defaultCenter]postNotificationName:RepostNotification object:data];
            
		}
        if ([host isEqualToString:@"destroy"])
        {
            NSString *sid=[[url queryArgumentForKey:@"id"] 
						   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[AccountController instance] destroyStatus:sid];
        }
		if ([host isEqualToString:@"send_message"]) {
			NSString *screenName=[[url queryArgumentForKey:@"screen_name"] 
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			[data setObject:screenName forKey:@"screen_name"];
			[[NSNotificationCenter defaultCenter]postNotificationName:SendMessageNotification object:data];
            
            
		}
		if ([host isEqualToString:@"create_favorites"]) {
			NSString *sid=[[url queryArgumentForKey:@"id"] 
						   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[AccountController instance] createFavorites:sid];
		}
        
        if ([host isEqualToString:@"destroy_favorites"]) {
			NSString *sid=[[url queryArgumentForKey:@"id"] 
						   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[AccountController instance] destroyFavorites:sid];
		}
	}
	
}

@end
