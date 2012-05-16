//
//  AppPrefsWindowController.h
//  Mint
//
//  Created by  on 11-9-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"

@interface AppPrefsWindowController : DBPrefsWindowController<NSTableViewDataSource,NSTableViewDelegate>
{
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *notificationPreferenceView;
    IBOutlet NSView *accountsPreferenceView;
    IBOutlet NSView *updatesPreferenceView;
    
    IBOutlet NSTextField *updateTimeLabel;
}

- (IBAction)changeUpdateTime:(id)sender;

@end
