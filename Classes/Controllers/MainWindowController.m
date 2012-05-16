//
//  MainWindowController.m
//  Bubble
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"
#import "PathController.h"

@implementation MainWindowController
- (id)init {
	self = [super initWithWindowNibName:@"MainWindow"];
    if(self){
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(didShowErrorInfo:) 
				   name:HTTPConnectionErrorNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didStartHTTPConnection:) 
				   name:HTTPConnectionStartNotification
				 object:nil];
		[nc addObserver:self selector:@selector(didFinishedHTTPConnection:) 
				   name:HTTPConnectionFinishedNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didUpdateTimelineSegmentedControl:) 
				   name:UpdateTimelineSegmentedControlNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didDisplayImage:) 
				   name:DisplayImageNotification object:nil];
		[nc addObserver:self selector:@selector(enableBack:) 
				   name:PathChangedNotification object:nil];
		[nc addObserver:self selector:@selector(handleAccountVerified:) 
				   name:AccountVerifiedNotification object:nil];
        [nc addObserver:self selector:@selector(didNewNotification:) 
				   name:NewNotification object:nil];
        [nc release],nc = nil;
        
        composeController = [[ComposeController alloc]init];
        imagePanelController = [[ImagePanelController alloc] init];
        previewController = [[PreviewController alloc] init];
        
        // 设置通知时间
        NSInteger NotificationTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"NotificationTime"];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:NotificationTime * 60
                                                          target:self 
                                                        selector:@selector(didCheckUnread) 
                                                        userInfo:nil 
                                                         repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	}
    
	return self;
}

-(void)awakeFromNib{
	[webView setUIDelegate:self];
	htmlController = [[HTMLController alloc] initWithWebView:webView];
	[htmlController loadMainPage];
	[self updateTimelineSegmentedControl];
    [self reloadUsersMenu];
    [self showStatusItem];
}

-(void)reloadUsersMenu{
	const int kUsersMenuPresetItems = 6;
	while ([userMenu numberOfItems]>kUsersMenuPresetItems) {
		[userMenu removeItemAtIndex:kUsersMenuPresetItems];
	}
    
	NSDictionary *accounts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"accounts"];
//    for (NSString *account in accounts){
//        NSLog(@"userid: %@", account);
//        for (NSString *key in [accounts objectForKey:account]) {
//            NSLog(@"%@: %@",key,[[accounts objectForKey:account] objectForKey:key]);
//        }
//    }
    
    NSString *userid = nil;
    NSString *screenName = nil;
    
    for(NSString *account in accounts){
        userid = account;
        screenName = [[accounts objectForKey:account] objectForKey:@"screenName"];
        
		NSMenuItem *item = [self menuItemWithTitle:screenName action:@selector(selectAccount:) representedObject:userid indentationLevel:1];
		if ([screenName isEqualToString:[[AccountController instance] currentAccount].screenName]) {
			[item setState:NSOnState];
		} else {
			NSTextAttachment* attachment = [[[NSTextAttachment alloc] init] autorelease];
			NSTextAttachmentCell *cell=[[[NSTextAttachmentCell alloc] init] autorelease];
			NSImage *image = [NSImage imageNamed:@"black_dot"];
			[cell setImage:image];
			[attachment setAttachmentCell:cell];
			NSAttributedString* imageAttributedString = [NSAttributedString attributedStringWithAttachment:attachment];
            
			NSFont *font = [NSFont menuFontOfSize:[NSFont systemFontSize]];			
			NSMutableAttributedString *attributedTitle =
			[[NSMutableAttributedString alloc] initWithString:screenName
												   attributes:[NSDictionary dictionaryWithObjectsAndKeys:
															   font,NSFontAttributeName,nil]];
			
			[attributedTitle appendAttributedString:imageAttributedString];
			[item setAttributedTitle:attributedTitle];
		}
        
		[userMenu addItem:item];
	}
    NSMenuItem *item = [self menuItemWithTitle:@"注销" action:@selector(logoutAccount:) representedObject:userid indentationLevel:0];
    [userMenu addItem:item];
}

- (NSMenuItem*)menuItemWithTitle:(NSString *)title action:(SEL)action representedObject:(id)representedObject indentationLevel:(int)indentationLevel {
	NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
	menuItem.title = title;
	menuItem.target = self;
	menuItem.action = action;
	menuItem.representedObject = representedObject;
	menuItem.indentationLevel = indentationLevel;
	return menuItem;
}

- (IBAction)selectAccount:(id)sender{
//	NSString *username = [sender representedObject];
//	[[self window] setTitle:username];
//	[self reloadUsersMenu];
}

- (IBAction)logoutAccount:(id)sender
{
    NSString *userid = [sender representedObject];
    [[AccountController instance] delCurrentAccount:userid];
    //[[self window] close];
    exit(0);
}

-(IBAction)selectBackWithSegmentControl:(id)sender{
	int index = [sender selectedSegment];
	switch (index) {
		case 0:
			[[PathController instance] backward];
			break;
		case 1:
			[[PathController instance] forward];
			break;
		default:
			break;
	}
}

-(void)enableBack:(NSNotification*)notification{
	int index = [PathController instance].currentIndex;
	int count = [[PathController instance].pathArray count];
	if (index < 0) {
		[backSegmentedControl setEnabled:NO forSegment:0];
	} else {
		[backSegmentedControl setEnabled:YES forSegment:0];
	}
	if (index + 1 < count) {
		[backSegmentedControl setEnabled:YES forSegment:1];
	} else {
		[backSegmentedControl setEnabled:NO forSegment:1];
	}
}

-(void)handleAccountVerified:(NSNotification*)notification{
	NSDictionary *user = [notification object];

    NSString *screenName = [user objectForKey:@"screen_name"];
    NSString *proFileImageURL = [user objectForKey:@"profile_image_url"];
    NSImage *proFileImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:proFileImageURL]];
    
	[avatarView setImage:proFileImage];
    [avatarView setToolTip:screenName];
    [htmlController selectHome];
}

-(void)didCheckUnread{
    [[AccountController instance] checkUnread];
}

-(void)didNewNotification:(NSNotification*)notification{
    NSDictionary *dic = [notification object];
    NSNumber *unreadStatusCount = [dic objectForKey:@"new_status"];
    NSNumber *statusCount = [dic objectForKey:@"status"];
    NSNumber *unreadMentionsCount = [dic objectForKey:@"mentions"];
    NSNumber *unreadCommentsCount = [dic objectForKey:@"comments"];
    NSNumber *unreadFollowersCount = [dic objectForKey:@"followers"];
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    if([unreadStatusCount intValue] > 0 || [unreadCommentsCount intValue] > 0 || [unreadFollowersCount intValue] > 0 || [unreadMentionsCount intValue] > 0){
        
        [statusItem setImage:[NSImage imageNamed:@"status_new_icon"]];
        
        if ([unreadStatusCount intValue] > 0) {
            [menu addItemWithTitle:[NSString stringWithFormat:@"有 %@ 条新微博",statusCount] action:nil keyEquivalent:@""];
        }
        if ([unreadMentionsCount intValue] > 0) {
            [menu addItemWithTitle:[NSString stringWithFormat:@"有 %@ 条微博/评论@我",unreadMentionsCount] action:nil keyEquivalent:@""];
        }
        if ([unreadCommentsCount intValue] > 0) {
            [menu addItemWithTitle:[NSString stringWithFormat:@"有 %@ 条新评论",unreadCommentsCount] action:nil keyEquivalent:@""];
        }
        if ([unreadFollowersCount intValue] > 0) {
            [menu addItemWithTitle:[NSString stringWithFormat:@"有 %@ 位新粉丝",unreadFollowersCount] action:nil keyEquivalent:@""];
        }
        
        [statusItem setMenu:menu];
    }
}

-(IBAction)selectViewWithSegmentControl:(id)sender{
	[self updateTimelineSegmentedControl];
	[[PathController instance] resetPath];
    
	int index = [sender selectedSegment];
	switch (index) {
		case 0:
			[htmlController selectHome];
			break;
		case 1:
			[htmlController selectMentions];
			break;
		case 2:
			[htmlController selectComments];
			break;
		case 3:
            [htmlController selectFavorites];
			break;
		default:
			break;
	}
}

- (void)updateTimelineSegmentedControl{
	if(timelineSegmentedControl == nil){
		return;
	}
    
	NSArray *imageNames = [NSArray arrayWithObjects:@"home",@"mentions",@"comments",@"favorites",nil];
	NSString *imageName = [[[NSString alloc] init] autorelease];
	BOOL unread[4];
	unread[0] = htmlController.weiboAccount.homeTimeline.unread;
	unread[1] = htmlController.weiboAccount.mentions.unread;
	unread[2] = htmlController.weiboAccount.comments.unread;
	unread[3] = NO;
    
	for(int index = 0; index < imageNames.count; index++){
		imageName = [imageNames objectAtIndex:index];
		NSString *dotImageName = [[[NSString alloc] initWithString:@"blue_dot.png"] autorelease];
		if([timelineSegmentedControl isSelectedForSegment:index]){
			imageName = [imageName stringByAppendingString:@"_down"];
			dotImageName = [[NSString alloc] initWithString:@"white_dot.png"];
		}
		imageName = [imageName stringByAppendingString:@".png"];
        NSImage *image = [NSImage imageNamed:imageName];
        
		if (index < 4 && unread[index]) {
			NSImage *dot = [NSImage imageNamed:dotImageName];
            [image lockFocus];
			[dot drawInRect:NSMakeRect([image size].width-[dot size].width, [image size].height-[dot size].height, [dot size].width, [dot size].height) fromRect:NSMakeRect(0, 0, [dot size].width, [dot size].height) operation:NSCompositeSourceOver fraction:1.0];
			[image unlockFocus];
		}
        
        [timelineSegmentedControl setImage:image forSegment:index];
	}
}

-(IBAction)compose:(id)sender {
	[composeController composeNew:[avatarView toolTip] avatar:[avatarView image]];
}

-(void)didShowErrorInfo:(NSNotification*)notification{
	NSError* error = [notification object];
	[connectionProgressIndicator setHidden:YES];
	[connectionProgressIndicator stopAnimation:nil];
    //NSLog(@"error: %@",[error localizedDescription]);
    [htmlController hideMessageBar];
    [htmlController setInnerHTML:[error localizedDescription] forElement:@"spinner"];
}

-(void)didStartHTTPConnection:(NSNotification*)notification{
	[connectionProgressIndicator setHidden:NO];
	[connectionProgressIndicator startAnimation:nil];
}

-(void)didFinishedHTTPConnection:(NSNotification*)notification{
	[connectionProgressIndicator setHidden:YES];
	[connectionProgressIndicator stopAnimation:nil];
}

-(void)didUpdateTimelineSegmentedControl:(NSNotification*)notification{
	[self updateTimelineSegmentedControl];
}

-(void)didDisplayImage:(NSNotification*)notification{
	NSString *url = [notification object];
    [previewController loadWithURL:url type:@"image"];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
	WebView *_hiddenWebView = [[WebView alloc] init];
	[_hiddenWebView setPolicyDelegate:self];
	return _hiddenWebView;
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    //NSLog(@"main webview:%@",[[actionInformation objectForKey:WebActionOriginalURLKey] absoluteString]);
	[[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
	[sender release];
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    return nil;
}

-(IBAction)refreshTimeline:(id)sender{
	[[PathController instance].currentTimeline reset]; 
	[[PathController instance].currentTimeline loadRecentTimeline];
}

-(IBAction)popUpUserMenu:(id)sender{
	NSRect frame = [(NSView *)sender frame];
	NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y-4)
                                                               toView:nil];
	NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
                                         location:menuOrigin
                                    modifierFlags:NSLeftMouseDownMask // 0x100
                                        timestamp:0.00
                                     windowNumber:[[(NSView *)sender window] windowNumber]
                                          context:[[(NSView *)sender window] graphicsContext]
                                      eventNumber:0
                                       clickCount:1
                                         pressure:1];
	
	[NSMenu popUpContextMenu:userMenu withEvent:event forView:[(NSView *)sender superview]];
	
}

-(IBAction)showMyProfile:(id)sender{
	NSString *screenName = [AccountController instance].currentAccount.screenName;
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"weibo://user?fetch_with=screen_name&value=%@",[screenName encodeAsURIComponent]]]];
}

- (void)showStatusItem
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setImage:[NSImage imageNamed:@"status_icon"]];
    [statusItem setAlternateImage:[NSImage imageNamed:@"status_alert_icon"]];
    [statusItem setHighlightMode:YES];
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"还没有未读消息" action:nil keyEquivalent:@""];
    [statusItem setMenu:menu];
}

-(void)dealloc{
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    [statusItem release];
	[webView release];
    [timelineSegmentedControl release];
    [backSegmentedControl release];
    [connectionProgressIndicator release];
    [composeWindow release];
    [avatarView release];
    [userMenu release];
    [htmlController release];
    [composeController release];
    [imagePanelController release];
	[super dealloc];
}

@end
