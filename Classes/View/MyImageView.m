//
//  MyImageView.m
//  Bubble
//
//  Created by Luke on 2/7/11.
//  Change by John
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyImageView.h"

#define ARROW_WIDTH		8
#define ARROW_HEIGHT	(ARROW_WIDTH/2.0)
#define ARROW_XOFFSET	2
#define ARROW_YOFFSET	3

@implementation MyImageView

- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:[self action] to:[self target] from:self];
}

- (void)drawRect:(NSRect)inRect
{
	[NSGraphicsContext saveGraphicsState];
	
	inRect = NSInsetRect(inRect, 0, 0);
	
    // 设置图片圆角
	NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:inRect xRadius:0 yRadius:0];
	
    // 设置图片边框
	//[[NSColor windowFrameColor] set];
	//[clipPath setLineWidth:1];
	//[clipPath stroke];
	
	//Ensure we have an even/odd winding rule in effect
	[clipPath setWindingRule:NSEvenOddWindingRule];
	[clipPath addClip];
	
	[super drawRect:inRect];
	
	if (hovered) {
		[[[NSColor blackColor] colorWithAlphaComponent:0.10f] set];
		[clipPath fill];
		
		//Draw the arrow
		NSBezierPath	*arrowPath = [NSBezierPath bezierPath];
		NSRect			frame = [self frame];
		[arrowPath moveToPoint:NSMakePoint(frame.size.width - ARROW_XOFFSET - ARROW_WIDTH, (ARROW_YOFFSET + (CGFloat)ARROW_HEIGHT))];
		[arrowPath relativeLineToPoint:NSMakePoint(ARROW_WIDTH, 0)];
		[arrowPath relativeLineToPoint:NSMakePoint(-(ARROW_WIDTH/2.0f), -((CGFloat)ARROW_HEIGHT))];
		
		[[NSColor darkGrayColor] set];
		[arrowPath fill];
	}
	
	[NSGraphicsContext restoreGraphicsState];
}

- (void)setHovered:(BOOL)inHovered
{
	hovered = inHovered;
	
	[self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)inEvent
{
	[self setHovered:YES];
	
	[super mouseEntered:inEvent];	
}

- (void)mouseExited:(NSEvent *)inEvent
{
	[self setHovered:NO];
	
	[super mouseExited:inEvent];
}

#pragma mark Tracking rects
//Remove old tracking rects when we change superviews
- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
	if (trackingTag != -1) {
		[self removeTrackingRect:trackingTag];
		trackingTag = -1;
	}
	
	[super viewWillMoveToSuperview:newSuperview];
}

- (void)viewDidMoveToSuperview
{
	[super viewDidMoveToSuperview];
	
	[self resetCursorRects];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	if (trackingTag != -1) {
		[self removeTrackingRect:trackingTag];
		trackingTag = -1;
	}
	
	[super viewWillMoveToWindow:newWindow];
}

- (void)viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	
	[self resetCursorRects];
}

- (void)frameDidChange:(NSNotification *)inNotification
{
	[self resetCursorRects];
}

- (void)resetCursorRects
{
	//Stop any existing tracking
	if (trackingTag != -1) {
		[self removeTrackingRect:trackingTag];
		trackingTag = -1;
	}
	
	//Add a tracking rect if our superview and window are ready
	if ([self superview] && [self window]) {
		NSRect	myFrame = [self frame];
		NSRect	trackRect = NSMakeRect(0, 0, myFrame.size.width, myFrame.size.height);
		
		if (trackRect.size.width > myFrame.size.width) {
			trackRect.size.width = myFrame.size.width;
		}
		
		NSPoint	localPoint = [self convertPoint:[[self window] convertScreenToBase:[NSEvent mouseLocation]]
									   fromView:nil];
		BOOL	mouseInside = NSPointInRect(localPoint, myFrame);
		
		trackingTag = [self addTrackingRect:trackRect owner:self userData:nil assumeInside:mouseInside];
		if (mouseInside) [self mouseEntered:nil];
	}
}

@end
