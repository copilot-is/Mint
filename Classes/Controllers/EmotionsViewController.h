//
//  EmotionsViewController.h
//  Mint
//
//  Created by 马 军 on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebPolicyDelegate.h>
#import "TemplateController.h"

@interface EmotionsViewController : NSViewController {
    NSPopover *popOver;
    IBOutlet WebView *webView;
    TemplateController *templates;
}

@property (nonatomic,retain) NSPopover *popOver;
@property (nonatomic,retain) IBOutlet WebView *webView;
@property (nonatomic,retain) TemplateController *templates;

- (IBAction)dismissPopover:(id)sender;

- (void)initWebView;
- (void)loadMainPage;
- (void)setInnerHTML:(NSString*)innerHTML forElement:(NSString*)elementId;

@end