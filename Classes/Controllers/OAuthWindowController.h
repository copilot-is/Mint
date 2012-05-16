//
//  OAuthWindowController.h
//  Mint
//
//  Created by  on 11-8-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OAuthLogin.h"
#import "AccountController.h"
#import "MainWindowController.h"

@class AppDelegate;

@interface OAuthWindowController : NSWindowController<OAuthLoginDelegate>
{
    IBOutlet NSTextField *pinTextField;
    OAuthLogin *login;
    MainWindowController *mainWindow;
}

@property(nonatomic,retain) IBOutlet NSTextField *pinTextField;

@end
