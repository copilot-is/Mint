//
//  MenuController.m
//  Bubble
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuController.h"
#import "AppPrefsWindowController.h"

@implementation MenuController

- (IBAction)preferences:(id)sender
{
	[[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil];
	(void)sender;
}

@end
