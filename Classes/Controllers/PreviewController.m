//
//  PreviewController.m
//  Mint
//
//  Created by 马 军 on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PreviewController.h"

@implementation PreviewController
@synthesize webView,fromRect;

- (id)init
{
    self = [super initWithWindowNibName:@"PreviewWindow"];
    if(self){
        NSWindow *window=[self window];
		initPanelRect =[window frame];
    }
    return self;
}

- (void)awakeFromNib
{
    templates = [[TemplateController alloc] init];
    [self.webView setUIDelegate:self];
    [self.webView setFrameLoadDelegate:self];
    [self.webView setPolicyDelegate:self];
    [self loadMainPage];
}

- (void)loadWithURL:(NSString *)url type:(NSString *)type
{
    NSWindow *window = [self window];
	NSPoint mouseLoc = [NSEvent mouseLocation];
	fromRect.origin = mouseLoc;
	fromRect.size = CGSizeMake(1, 1);
	
	if (![window isVisible]) {
		[[self window] setFrame:initPanelRect display:NO];
        [[self window] zoomOnFromRect:fromRect];
	}
    if ([type isEqualToString:@"image"]) {
        NSString *html = [[NSString alloc] initWithFormat:@"<img src='%@' />",url];
        [self setInnerHTML:html forElement:@"preview"];
    }
    else if([type isEqualToString:@"video"])
    {
        NSString *html = [[NSString alloc] initWithFormat:@"<embed id=\"STK_1335530954115126\" height=\"356\" allowscriptaccess=\"never\" style=\"visibility: visible;\" pluginspage=\"http://get.adobe.com/cn/flashplayer/\" flashvars=\"playMovie=true&amp;auto=1\" width=\"440\" allowfullscreen=\"true\" quality=\"hight\" src=\"http://www.tudou.com/v/FgMoEcPBgaQ/&amp;resourceId=100311153_03_05_02/v.swf\" type=\"application/x-shockwave-flash\" wmode=\"transparent\">%@",url];
        [self setInnerHTML:html forElement:@"preview"];
    }
    
}

- (BOOL)windowShouldClose:(id)sender{
	[[self window] zoomOffToRect:fromRect];
	return YES;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame
{

}

-(void)loadMainPage{
	[[self.webView mainFrame] loadHTMLString:[templates getPreview] baseURL:[templates getBaseURL]];
}

-(void)setInnerHTML:(NSString*)innerHTML forElement:(NSString*)elementId{
	DOMDocument *dom = [[self.webView mainFrame] DOMDocument];
	DOMHTMLElement *element = (DOMHTMLElement *)[dom getElementById:elementId];
	[element setInnerHTML:innerHTML];
}

-(void)addNewInnerHTML:(NSString *)newInnerHTML ForElement:(NSString*)elementId{
	DOMDocument *dom = [[self.webView mainFrame] DOMDocument];
	DOMHTMLElement *element = (DOMHTMLElement *)[dom getElementById:elementId];    
	[element setInnerHTML:[NSString stringWithFormat:@"%@%@",newInnerHTML,[element innerHTML]]];
}

@end
