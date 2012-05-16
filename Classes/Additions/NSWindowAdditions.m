//
//  NSWindowAdditions.m
//  Bubble
//
//  Created by Luke on 10/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSWindowAdditions.h"


@implementation NSWindow (Additions)

- (void)animateToFrame:(NSRect)frameRect duration:(NSTimeInterval)duration
{
    NSViewAnimation     *animation;
	
    animation = [[NSViewAnimation alloc] initWithViewAnimations:
				 [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
										   self, NSViewAnimationTargetKey,
										   [NSValue valueWithRect:frameRect], NSViewAnimationEndFrameKey, nil]]];
    
    [animation setDuration:duration];
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation setAnimationCurve:NSAnimationLinear];
    [animation startAnimation];
    
    [animation release];
}

- (NSWindow *)_createZoomWindowWithRect:(NSRect)rect
{
    NSWindow        *zoomWindow;
    NSImageView     *imageView;
    NSImage         *image;
    NSRect          frame;
    BOOL            isOneShot;
    
    frame = [self frame];
	
    isOneShot = [self isOneShot];
	if (isOneShot)
	{
		[self setOneShot:NO];
	}
    
	if ([self windowNumber] <= 0)
	{
		CGFloat		alpha;
		
        // Force creation of window device by putting it on-screen. We make it transparent to minimize the chance of
		// visible flicker.
		alpha = [self alphaValue];
		[self setAlphaValue:0.0];
        [self orderBack:self];
        [self orderOut:self];
		[self setAlphaValue:alpha];
	}
    
    image = [[NSImage alloc] initWithSize:frame.size];
    [image lockFocus];
    // Grab the window's pixels
    NSCopyBits([self gState], NSMakeRect(0.0, 0.0, frame.size.width, frame.size.height), NSZeroPoint);
    [image unlockFocus];
	[image setDataRetained:YES];
	[image setCacheMode:NSImageCacheNever];
    
    zoomWindow = [[NSWindow alloc] initWithContentRect:rect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    [zoomWindow setBackgroundColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.0]];
    [zoomWindow setHasShadow:[self hasShadow]];
	[zoomWindow setLevel:[self level]];
    [zoomWindow setOpaque:NO];
    [zoomWindow setReleasedWhenClosed:YES];
    [zoomWindow useOptimizedDrawing:YES];
    
    imageView = [[NSImageView alloc] initWithFrame:[zoomWindow contentRectForFrameRect:frame]];
    [imageView setImage:image];
    [imageView setImageFrameStyle:NSImageFrameNone];
    [imageView setImageScaling:NSScaleToFit];
    [imageView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    
    [zoomWindow setContentView:imageView];
    [image release];	
    [imageView release];
    
    // Reset one shot flag
    [self setOneShot:isOneShot];
    
    return zoomWindow;
}

- (void)zoomOnFromRect:(NSRect)startRect
{
    NSRect              frame;
    NSWindow            *zoomWindow;
	
    if ([self isVisible])
    {
        return;
    }
	
    frame = [self frame];
    
    zoomWindow = [self _createZoomWindowWithRect:startRect];
	
	[zoomWindow orderFront:self];
	
    [zoomWindow animateToFrame:frame duration:[zoomWindow animationResizeTime:frame] * 0.3];
    
	[self makeKeyAndOrderFront:self];	
	[zoomWindow close];
}

- (void)zoomOffToRect:(NSRect)endRect
{
    NSRect              frame;
    NSWindow            *zoomWindow;
    
    frame = [self frame];
    
    if (![self isVisible])
    {
        return;
    }
    
    zoomWindow = [self _createZoomWindowWithRect:frame];
    
	[zoomWindow orderFront:self];
    [self orderOut:self];
    
    [zoomWindow animateToFrame:endRect duration:[zoomWindow animationResizeTime:endRect] * 0.3];
    
	[zoomWindow close];    
}

@end
