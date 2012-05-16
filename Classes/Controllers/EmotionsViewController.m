//
//  EmotionsViewController.m
//  Mint
//
//  Created by 马 军 on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EmotionsViewController.h"

@implementation EmotionsViewController
@synthesize popOver,webView,templates;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"EmotionsView" bundle:nil];
    if (self) {
        self.popOver = [[NSPopover alloc] init];
        self.popOver.contentViewController = self;
    }
    
    return self;
}

- (void)initWebView
{
    templates = [[TemplateController alloc] init];
    [self.webView setUIDelegate:self];
    [self.webView setFrameLoadDelegate:self];
    [self.webView setPolicyDelegate:self];
    [self loadMainPage];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame
{
    [self setInnerHTML:@"11" forElement:@"preview"];
}

- (void)loadMainPage{
	[[self.webView mainFrame] loadHTMLString:[templates getPreview] baseURL:[templates getBaseURL]];
}

- (void)setInnerHTML:(NSString*)innerHTML forElement:(NSString*)elementId{
	DOMDocument *dom = [[webView mainFrame] DOMDocument];
	DOMHTMLElement *element = (DOMHTMLElement *)[dom getElementById:elementId];
	[element setInnerHTML:innerHTML];
}

- (IBAction)dismissPopover:(id)sender {
    [self.popOver performClose:sender];
    [self.popOver setAnimates:YES];
}

- (void)dealloc
{
    [popOver release];
    [super release];
}

@end
