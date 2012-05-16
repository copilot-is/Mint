//
//  NSScroller-MyScroller.m
//  Mint
//
//  Created by John on 11-8-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSScroller+MyScroller.h"

#define SCROLLER_WIDTH 15

@implementation NSScroller (MyScroller)

+ (CGFloat)scrollerWidth {
    return SCROLLER_WIDTH;
}

+ (CGFloat)scrollerWidthForControlSize: (NSControlSize)controlSize {
    return SCROLLER_WIDTH;
}

@end
