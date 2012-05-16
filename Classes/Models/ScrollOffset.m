//
//  ScrollPosition.m
//  Bubble
//
//  Created by Luke on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollOffset.h"


@implementation ScrollOffset
@synthesize itemId,relativeOffset;
-(void)dealloc{
	[itemId release];
	[super dealloc];
}
@end
