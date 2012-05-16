//
//  HTMLController.h
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebPolicyDelegate.h>
#import "WeiboGlobal.h"
#import "AccountController.h"
#import "PathController.h"
#import "TemplateController.h"
#import "PreviewController.h"

@interface HTMLController : NSObject {
	WebView *webView;
	NSString *spinner;
    TemplateController *templates;
	AccountController *weiboAccount;
    PreviewController *previewController;
}

-(id) initWithWebView:(WebView*) webView;
-(void)loadRecentTimeline;
-(void)loadTimelineWithPage;
-(void)reloadTimeline;
-(void)selectHome;
-(void)selectMentions;
-(void)selectComments;
-(void)selectFavorites;

#pragma mark 接受通知的方法
-(void)didReloadTimeline:(NSNotification *)notification;
-(void)didLoadNewerTimeline:(NSNotification*)notification;
-(void)startLoadOlderTimeline:(NSNotification*)notification;
-(void)didLoadNewerTimeline:(NSNotification*)notification;
-(void)didStartHTTPConnection:(NSNotification*)notification;

-(void)saveScrollPosition;
-(void)resumeScrollPosition;

-(void)hideMessageBar;
-(void)showMessageBar:(NSString*)message;

-(void)loadMainPage;
-(void)setInnerHTML:(NSString*)innerHTML forElement:(NSString*)elementId;
-(void)addNewInnerHTML:(NSString *)newInnerHTML ForElement:(NSString*)elementId;
-(void)addOldInnerHTML:(NSString *)oldInnerHTML ForElement:(NSString*)elementId;
-(void)openURL:(NSURL *)url inBackground:(BOOL)background;

@property(nonatomic,retain) WebView *webView;
@property(nonatomic,retain) AccountController *weiboAccount;

@end
