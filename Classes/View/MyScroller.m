//
//  MyScroller.m
//  Bubble
//
//  Created by Luke on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyScroller.h"

@implementation MyScroller
- (id)initWithFrame:(NSRect)frameRect
{
	self=[super initWithFrame:frameRect];
	if(self){
		[self setArrowsPosition:NSScrollerArrowsNone];
		bg=[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.8 alpha:1.0]
										 endingColor:[NSColor colorWithDeviceWhite:0.7 alpha:1.0]];
        
	}
	return self;
}

-(BOOL)isOpaque {
	return NO;	
}

- (void)drawKnobSlot
{
	[[NSColor colorWithDeviceWhite:255.0/255.0 alpha:1.0] set];
	NSRectFill([self bounds]);
}

- (void)drawKnob
{
	NSRect knobRect =  NSInsetRect([self rectForPart:NSScrollerKnob], 1, 1);
	knobRect.origin.x=4;
	knobRect.size.width=8;
	NSBezierPath *path=[NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:4 yRadius:4];
	[bg drawInBezierPath:path angle:0];
}

- (void)drawRect:(NSRect)rect 
{
	[self drawKnobSlot];
	[self drawKnob];
}

- (void)dealloc
{
	[bg release];
	[super dealloc];
}

@end
