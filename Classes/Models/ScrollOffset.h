//
//  ScrollPosition.h
//  Bubble
//  主要用来描述timeline的偏移位置，需要根据item的id以及相对与此item的偏移位置来计算
//  Created by Luke on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ScrollOffset : NSObject {
	NSString *itemId;
	NSInteger relativeOffset;
}
@property(nonatomic,retain) NSString *itemId;
@property(nonatomic) NSInteger relativeOffset;
@end
