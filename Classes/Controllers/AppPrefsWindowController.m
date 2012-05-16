//
//  AppPrefsWindowController.m
//  Mint
//
//  Created by  on 11-9-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppPrefsWindowController.h"

@implementation AppPrefsWindowController

- (void)setupToolbar
{
	[self addView:generalPreferenceView label:@"通用" image:[NSImage imageNamed:@"NSPreferencesGeneral"]];
    [self addView:notificationPreferenceView label:@"通知" image:[NSImage imageNamed:@"Notification"]];
	[self addView:accountsPreferenceView label:@"帐户" image:[NSImage imageNamed:@"NSUserAccounts"]];
    [self addView:updatesPreferenceView label:@"更新" image:[NSImage imageNamed:@"Updates"]];
}

- (void)awakeFromNib
{
    NSInteger NotificationTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"NotificationTime"];
    [updateTimeLabel setStringValue:[NSString stringWithFormat:@"%d分钟",NotificationTime]];
}

- (IBAction)changeUpdateTime:(id)sender
{
    NSSlider *slider = (NSSlider*)sender;
    [updateTimeLabel setStringValue:[NSString stringWithFormat:@"%d分钟",[slider intValue]]];
    //NSLog(@"%d",[slider intValue]);
}

-(void)dealloc
{
    [super dealloc];
}

@end
