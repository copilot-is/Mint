//
//  MainWindowController.h
//  Bubble
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "HTMLController.h"
#import "ComposeController.h"
#import "ImagePanelController.h"
#import "PreviewController.h"

@interface MainWindowController : NSWindowController {
	IBOutlet WebView *webView;
	IBOutlet NSSegmentedControl *timelineSegmentedControl;
	IBOutlet NSSegmentedControl *backSegmentedControl;
	IBOutlet NSProgressIndicator * connectionProgressIndicator;
	IBOutlet NSWindow *composeWindow;
	IBOutlet NSImageView *avatarView;
	IBOutlet NSMenu *userMenu;
	HTMLController *htmlController;
	ComposeController *composeController;
	ImagePanelController *imagePanelController;
    PreviewController *previewController;
    NSStatusItem *statusItem;
}

-(IBAction)selectViewWithSegmentControl:(id)sender;
-(IBAction)selectBackWithSegmentControl:(id)sender;
-(IBAction)compose:(id)sender;

-(void)reloadUsersMenu;
-(NSMenuItem*)menuItemWithTitle:(NSString *)title 
                          action:(SEL)action 
               representedObject:(id)representedObject 
                indentationLevel:(int)indentationLevel;

-(void)updateTimelineSegmentedControl;

-(void)didShowErrorInfo:(NSNotification*)notification;
-(void)didStartHTTPConnection:(NSNotification*)notification;
-(void)didFinishedHTTPConnection:(NSNotification*)notification;

- (void)showStatusItem;

-(IBAction)refreshTimeline:(id)sender;
-(IBAction)popUpUserMenu:(id)sender;
-(IBAction)showMyProfile:(id)sender;

@end
