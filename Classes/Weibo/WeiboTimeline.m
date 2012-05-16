//
//  WeiboHomeTimeline.m
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboTimeline.h"

@implementation WeiboTimeline

@synthesize data,theNewData,lastReceivedId,oldestReceivedId,timelineType,weiboConnector,typeName,unread,firstReload,operation;

#pragma mark  初始化
-(id)initWithWeiboConnector:(WeiboConnector*)connector timelineType:(TimelineType)type{
	if (self = [super init]) {
		self.weiboConnector = connector;
		self.timelineType = type;
		self.data = nil;
		self.theNewData = nil;
		self.firstReload = YES;
		self.operation = Reload;
		switch (self.timelineType) {
			case Home:
				self.typeName = @"home";
				break;
			case Mentions:
				self.typeName = @"mentions";
				break;
			case Comments:
				self.typeName = @"comments";
				break;
			case Favorites:
				self.typeName = @"favorites";
				break;
			default:
				break;
		}
	}
	return self;
}


#pragma mark 最近信息请求的发起和处理
-(void) loadRecentTimeline{
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ShowTipMessageNotification
														object:@"加载中..."];
	//when app started,execute this first
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	//不同类型的timeline不同的方法调用
	switch (timelineType) {
		case Home:
			[self.weiboConnector getHomeTimelineWithParameters:params
										 completionTarget:self
										 completionAction:@selector(didLoadRecentTimeline:)];
			break;
		case Mentions:
			[self.weiboConnector getMentionsWithParameters:params
									completionTarget:self
									 completionAction:@selector(didLoadRecentTimeline:)];
			break;
		case Comments:
			[self.weiboConnector getCommentsWithParameters:params
									 completionTarget:self
									 completionAction:@selector(didLoadRecentTimeline:)];
			break;
		case Favorites:
			[self.weiboConnector getFavoritesWithParameters:params
									  completionTarget:self
									  completionAction:@selector(didLoadRecentTimeline:)];
			break;
		default:
			break;
	}
}

-(void)didLoadRecentTimeline:(NSArray*)statuses{
	self.data = [statuses mutableCopy];
    //[[[NSMutableArray alloc] initWithArray:statuses] autorelease];
	
    //[[self.data lastObject] setObject:[NSNumber numberWithInt:1] forKey:@"gap"];
    //NSMutableDictionary *gapStatus=[[statuses lastObject] mutableCopy];
	//[gapStatus setObject:[NSNumber numberWithInt:1] forKey:@"gap"];
	//[statusArray replaceObjectAtIndex:[statusArray count]-1 withObject:gapStatus];
	//NSLog(@"%@",[[statusArray lastObject] objectForKey:"gap"]);
    
	if (statuses != nil && [statuses count] > 0) {		
		self.lastReceivedId = [[statuses objectAtIndex:0] objectForKey:@"id"];
        //self.lastReadId = [[statuses objectAtIndex:0] objectForKey:@"id"];
		self.oldestReceivedId = [[statuses lastObject] objectForKey:@"id"];
		[[NSNotificationCenter defaultCenter] postNotificationName:ReloadTimelineNotification
																			object:self];
	}
}

#pragma mark 新信息请求的发起和处理
-(void)loadNewerTimeline{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	switch (timelineType) {
		case Home:
			[weiboConnector getHomeTimelineWithParameters:params
										 completionTarget:self
										 completionAction:@selector(didLoadNewerTimeline:)];
			break;
		case Mentions:
			[weiboConnector getMentionsWithParameters:params
									 completionTarget:self
									 completionAction:@selector(didLoadNewerTimeline:)];
			break;
		case Comments:
			[weiboConnector getCommentsWithParameters:params
									 completionTarget:self
									 completionAction:@selector(didLoadNewerTimeline:)];
			break;
		case Favorites:
			[weiboConnector getFavoritesWithParameters:params
										   completionTarget:self
										   completionAction:@selector(didLoadNewerTimeline:)];
			break;
		default:
			break;
	}
}

-(void)didLoadNewerTimeline:(NSArray*)statuses{
	if (statuses != nil && [statuses count] > 0) {
        self.theNewData = [[[NSArray alloc] initWithArray:statuses] autorelease];
		NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
		NSUInteger i, count = [statuses count];
		for(i = 0; i<count; i++){
			[indexes addIndex:i];
		}

		[data insertObjects:statuses atIndexes:indexes];
		self.lastReceivedId = [[statuses objectAtIndex:0] objectForKey:@"id"];
		self.unread = YES;
		//[[NSNotificationCenter defaultCenter] postNotificationName:UpdateTimelineSegmentedControlNotification object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:DidLoadNewerTimelineNotification object:self];
	}
}

#pragma mark 历史信息请求的发起和处理
-(void)loadOlderTimeline{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	//由于max_id是指获取不大于max_id的，所以有重复，需要减去1
    long maxId = [oldestReceivedId longLongValue] - 1;
	[params setObject:[NSString stringWithFormat:@"%llu",maxId] forKey:@"max_id"];

	switch (timelineType) {
		case Home:
			[weiboConnector getHomeTimelineWithParameters:params
										 completionTarget:self
										 completionAction:@selector(didLoadOlderTimeline:)];
			break;
		case Mentions:
			[weiboConnector getMentionsWithParameters:params
									 completionTarget:self
									 completionAction:@selector(didLoadOlderTimeline:)];
			break;
		case Comments:
			[weiboConnector getCommentsWithParameters:params
									 completionTarget:self
									 completionAction:@selector(didLoadOlderTimeline:)];
			break;
		default:
			break;
	}
}

-(void)didLoadOlderTimeline:(NSArray*)statuses{
	if (statuses != nil && [statuses count] > 0) {
		self.theNewData = statuses;
		self.oldestReceivedId = [[statuses lastObject] objectForKey:@"id"];
		[data addObjectsFromArray:statuses];
		[[data lastObject] setObject:[NSNumber numberWithInt:1] forKey:@"gap"];
		[[NSNotificationCenter defaultCenter] postNotificationName:DidLoadOlderTimelineNotification
															object:self];
	}
}

-(void)loadTimelineWithPage:(NSString*)pageNumber{
	NSMutableDictionary* params = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:@"20" forKey:@"count"];
	[params setObject:pageNumber forKey:@"page"];
	switch (timelineType) {
		case Favorites:
			[weiboConnector getFavoritesWithParameters:params
									 completionTarget:self
									 completionAction:@selector(didLoadTimelineWithPage:)];
			break;
		default:
			break;
	}

}

-(void)didLoadTimelineWithPage:(NSArray*)statuses{
	self.data = [[statuses mutableCopy] autorelease];
	if (statuses != nil && [statuses count] > 0) {
		self.lastReceivedId = [[statuses objectAtIndex:0] objectForKey:@"id"];
        //self.lastReadId = [[statuses objectAtIndex:0] objectForKey:@"id"];
		self.oldestReceivedId = [[statuses lastObject] objectForKey:@"id"];
		[[NSNotificationCenter defaultCenter] postNotificationName:ReloadTimelineNotification
															object:self];
	}
}

-(void)reset{
    self.data=nil;
	self.theNewData=nil;
	self.oldestReceivedId=nil;
	self.lastReceivedId=nil;
}

- (void)dealloc
{
    [typeName release];
    [data release];
	[theNewData release];
	[oldestReceivedId release];
	[lastReceivedId release];
    [weiboConnector release];
    [super dealloc];
}

@end
