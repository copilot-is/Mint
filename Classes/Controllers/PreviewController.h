//
//  PreviewController.h
//  Mint
//
//  Created by 马 军 on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebPolicyDelegate.h>
#import "TemplateController.h"
#import "NSWindowAdditions.h"

@interface PreviewController : NSWindowController {
    IBOutlet WebView *webView;
    TemplateController *templates;
    NSRect fromRect;
	NSRect initPanelRect;
}

@property (nonatomic,retain) WebView *webView;
@property(nonatomic)NSRect fromRect;

- (void)loadWithURL:(NSString *)url type:(NSString *)type;

- (void)loadMainPage;
- (void)setInnerHTML:(NSString*)innerHTML forElement:(NSString*)elementId;
- (void)addNewInnerHTML:(NSString *)newInnerHTML ForElement:(NSString*)elementId;

@end
