//
//  NSWindowAdditions.h
//  Bubble
//
//  Created by Luke on 10/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWindow (Additions)
- (void)animateToFrame:(NSRect)frameRect duration:(NSTimeInterval)duration;
- (void)zoomOnFromRect:(NSRect)startRect;
- (void)zoomOffToRect:(NSRect)endRect;
@end
