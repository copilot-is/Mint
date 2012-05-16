//
//  PathController.h
//  Bubble
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboTimeline.h"

typedef enum {
	StatusDetail=0,
	UserDetail,
	Followers,
	Following,
	UserTimeline,
	UserFavorites,
	MessageSent
}PathType;

@interface PathController : NSObject {
	__weak WeiboTimeline *currentTimeline;
	NSMutableArray *pathArray;
	int currentIndex;
	PathType currentType;
	//idWithPathType 是可以对当前pathtype进行唯一标识的一个值，比如用户的id，状态的id等等
	NSString *idWithCurrentType;
}

+(PathController *)instance;
-(void)add:(NSString*)urlString;
-(void)forward;
-(void)backward;
-(void)resetPath;

@property(nonatomic,assign) WeiboTimeline *currentTimeline;
@property(nonatomic) int currentIndex;
@property(nonatomic,retain) NSMutableArray *pathArray; 
@property(nonatomic)PathType currentType;
@property(nonatomic,retain)NSString *idWithCurrentType;

@end
