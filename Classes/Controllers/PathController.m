//
//  PathController.m
//  Bubble
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PathController.h"

static PathController *pathController;

@implementation PathController

@synthesize currentTimeline,currentIndex,pathArray,currentType,idWithCurrentType;

+(PathController *)instance{
	if (pathController == nil) {
		pathController = [[PathController alloc] init];
	}
	return pathController;
}

-(id)init{
	if (self = [super init]) {
		pathArray = [[NSMutableArray alloc] init];
		currentIndex = -1;
	}
	return self;
}

-(void)resetPath{
	currentIndex = -1;
	[pathArray removeAllObjects];
	[[NSNotificationCenter defaultCenter] postNotificationName:PathChangedNotification
														object:nil];
}

-(void)add:(NSString*)urlString{
	//这里需要删除index之后的object
	self.currentIndex++;
	if (self.currentIndex < [pathArray count]) {
		[pathArray removeObjectsInRange:NSMakeRange(self.currentIndex, [pathArray count]-self.currentIndex)];
	}
	[pathArray addObject:urlString];
	[[NSNotificationCenter defaultCenter] postNotificationName:PathChangedNotification
														object:nil];
}

-(void)forward{
	if (self.currentIndex + 1 < [pathArray count]) {
		self.currentIndex++;
		NSString *urlString = [pathArray objectAtIndex:self.currentIndex];
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&add=false",urlString]]];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:PathChangedNotification
														object:nil];
	
}

-(void)backward{
	self.currentIndex--;
	if (self.currentIndex >= 0) {
		NSString *urlString = [pathArray objectAtIndex:self.currentIndex];
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&add=false",urlString]]];
	}else {
		[[NSNotificationCenter defaultCenter] postNotificationName:ReloadTimelineNotification
															object:nil];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:PathChangedNotification
                                                    object:nil];
}

-(void)dealloc{
	[pathArray release];
	[super dealloc];
}
@end
