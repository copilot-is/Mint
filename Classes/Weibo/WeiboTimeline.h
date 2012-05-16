//
//  WeiboHomeTimeline.h
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboConnector.h"
#import "WeiboGlobal.h"
#import "ScrollOffset.h"

typedef enum {
	None=0,
	Reload,
	Switch
}OperationType;

@interface WeiboTimeline : NSObject{
	//类型 
	TimelineType timelineType;
	NSString *typeName;
	WeiboConnector *weiboConnector;
	
	//data 中记录当前timeline的维护数据 theNewData记录最近收到的数据
	NSMutableArray *data;
	NSArray *theNewData;
	
	//NSNumber *lastReadId;
	NSNumber *lastReceivedId;
	NSNumber *oldestReceivedId;
	BOOL unread;
	BOOL firstReload;
	OperationType operation;
}

@property(nonatomic,retain) NSMutableArray *data;
@property(nonatomic,retain) NSArray *theNewData;
@property(nonatomic) BOOL unread;
@property(nonatomic) BOOL firstReload;
@property(nonatomic) TimelineType timelineType;
@property(nonatomic,retain) NSString *typeName;
@property(nonatomic,retain) NSNumber *lastReceivedId;
@property(nonatomic,retain) NSNumber *oldestReceivedId;
@property(nonatomic) OperationType operation;
@property(nonatomic,retain) WeiboConnector *weiboConnector;

-(id)initWithWeiboConnector:(WeiboConnector*)connector 
			   timelineType:(TimelineType)type;

-(void)loadRecentTimeline;
-(void)didLoadRecentTimeline:(NSArray*)statuses;

-(void)loadNewerTimeline;
-(void)didLoadNewerTimeline:(NSArray*)statuses;


-(void)loadOlderTimeline;
-(void)didLoadOlderTimeline:(NSArray*)statuses;

-(void)loadTimelineWithPage:(NSString*)pageNumber;
-(void)didLoadTimelineWithPage:(NSArray*)statuses;

//重置,当切换用户时进行重置
-(void)reset;

@end
