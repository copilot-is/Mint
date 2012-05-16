//
//  NSScroller-MyScroller.h
//  Mint
//
//  Created by John on 11-8-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSScroller (MyScroller)

+ (CGFloat)scrollerWidth;
+ (CGFloat)scrollerWidthForControlSize: (NSControlSize)controlSize;

@end
