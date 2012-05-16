//
//  MyImageView.h
//  Bubble
//
//  Created by Luke on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyImageView : NSImageView {
	BOOL				hovered;
	NSTrackingRectTag	trackingTag;
}

@end
