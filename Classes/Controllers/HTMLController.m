//
//  HTMLController.m
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HTMLController.h"

@implementation HTMLController

@synthesize webView,weiboAccount;

-(id) initWithWebView:(WebView*) webview{
	if(self = [super init]){
		spinner = @"<img class='status_spinner_image' src='spinner.gif'> Loading...</div>";
		//data received notification
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(showLoadingPage:) 
				   name:ShowLoadingPageNotification
				 object:nil];
		[nc addObserver:self selector:@selector(didStartHTTPConnection:) 
				   name:HTTPConnectionStartNotification
				 object:nil];
		[nc addObserver:self selector:@selector(didFinishedHTTPConnection:) 
				   name:HTTPConnectionFinishedNotification
				 object:nil];
		[nc addObserver:self selector:@selector(didReloadTimeline:) 
				   name:ReloadTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(startLoadOlderTimeline:) 
				   name:StartLoadOlderTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didLoadOlderTimeline:) 
				   name:DidLoadOlderTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didLoadNewerTimeline:) 
				   name:DidLoadNewerTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didLoadTimelineWithPage:) 
				   name:DidLoadTimelineWithPageNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didClickTimeline:)
				   name:DidClickTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didGetUser:)
				   name:DidGetUserNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didGetFriends:)
				   name:DidGetFriendsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didGetFollowers:)
				   name:DidGetFollowersNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didSaveScrollPosition:) 
				   name:SaveScrollPositionNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didShowStatus:) 
				   name:DidShowStatusNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(setWaitingForComments:)
				   name:GetStatusCommentsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didGetStatusComments:) 
				   name:DidGetStatusCommentsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(showTip:) 
				   name:ShowTipMessageNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didGetUserTimeline:) 
				   name:DidGetUserTimelineNotification 
				 object:nil];
		
        [nc addObserver:self selector:@selector(didExpandShortURL:) 
				   name:DidExpandShortURLNotification 
				 object:nil];
        
		templates = [[TemplateController alloc] init];
		weiboAccount = [AccountController instance];
        previewController = [[PreviewController alloc] init];
		
        self.webView = webview;
		[self.webView setFrameLoadDelegate:self];
		[self.webView setPolicyDelegate:self];
        
		//scroll 事件
		NSScrollView *scrollView = [[[[self.webView mainFrame] frameView] documentView] enclosingScrollView];
		[[scrollView contentView] setPostsBoundsChangedNotifications:YES];
        [scrollView hasVerticalScroller];
        
		[nc addObserver:self
			   selector:@selector(webviewContentBoundsDidChange:) 
                   name:NSViewBoundsDidChangeNotification 
                 object:[scrollView contentView]];
        
	}
	return self;
}

// 滚动时操作
-(void)webviewContentBoundsDidChange:(NSNotification *)notification{
	NSScrollView *scrollView = [[[[self.webView mainFrame] frameView] documentView] enclosingScrollView];
	int y = [[scrollView contentView] bounds].origin.y;
	int height = [[scrollView contentView] bounds].size.height;
	if (y == 0) {
		//if ([PathController instance].currentTimeline.operation==None) {
        //这个地方是有问题的，当从另外一个tab切回来的时候，也会触发这里
        [PathController instance].currentTimeline.unread = NO;
        //[[NSNotificationCenter defaultCenter] postNotificationName:UpdateTimelineSegmentedControlNotification object:nil];
		//}
        
	}
    else if (y + height == [[scrollView documentView] bounds].size.height) {
        if([[PathController instance].pathArray count] == 0)
        {
           [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"weibo://load_older_timeline"]]; 
        }
	}
//	NSLog(@"%f",[scrollView bounds].size.height);
//	NSLog(@"%d",y);
//	NSLog(@"%d",height);
}

//当页面点击加载更多的时候接受到这个通知，进行加载历史信息
-(void)startLoadOlderTimeline:(NSNotification*)notification{
	//开始加载历史信息的时候显示等待的图标
	DOMDocument *dom = [[webView mainFrame] DOMDocument];
	DOMHTMLElement *spinnerEle = (DOMHTMLElement *)[dom getElementById:@"spinner"];
	[spinnerEle setInnerHTML:spinner];
	[[PathController instance].currentTimeline loadOlderTimeline];
}

-(void)loadRecentTimeline{
	[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification object:nil];
	[[PathController instance].currentTimeline loadRecentTimeline];
}

-(void)loadTimelineWithPage{
	[[PathController instance].currentTimeline loadTimelineWithPage:@"1"];
}

-(void)didReloadTimeline:(NSNotification *)notification{
    //NSLog(@"%@",[PathController instance].currentTimeline.data);
	[self reloadTimeline];
}

-(void)didSaveScrollPosition:(NSNotification *)notification{
	[self saveScrollPosition];
}

#pragma mark Select View
//选择home，未读状态设置为NO，将hometimeline中的statusArray渲染出来，设置lastReadStatusId为最新的status的id
-(void) reloadTimeline{
	if ([PathController instance].currentIndex > -1) {
		return;
	}
    
	if ([PathController instance].currentTimeline.data == nil) {
        [self loadRecentTimeline];
		return;
	}
    
	if (![PathController instance].currentTimeline.firstReload) {
		[self saveScrollPosition];
	} else {
		[PathController instance].currentTimeline.firstReload = NO;
        [self resumeScrollPosition];
	}
    
    NSDictionary *statuses = [NSDictionary dictionaryWithObject:[PathController instance].currentTimeline.data forKey:@"statuses"];
    
    switch ([PathController instance].currentTimeline.timelineType) {
        case Home:
            [self setInnerHTML:[templates getStatuses:statuses] forElement:@"content"];
            break;
        case Mentions:
            [self setInnerHTML:[templates getMentions:statuses] forElement:@"content"];
            break;
        case Comments:
            [self setInnerHTML:[templates getComments:statuses] forElement:@"content"];
            break;
        case Favorites:
            [self setInnerHTML:[templates getFavorites:statuses] forElement:@"content"];
            break;
        default:
            break;
    }
    
    [self setInnerHTML:@"" forElement:@"spinner"];
	[self hideMessageBar];
}

-(void)selectHome{
	[PathController instance].currentTimeline.firstReload = YES;
	[self saveScrollPosition];
	[PathController instance].currentTimeline = weiboAccount.homeTimeline;
	[self reloadTimeline];
}
-(void)selectMentions{
	[PathController instance].currentTimeline.firstReload = YES;
	[self saveScrollPosition];
    [PathController instance].currentTimeline = weiboAccount.mentions;
	[self reloadTimeline];
}
-(void)selectComments{
	[PathController instance].currentTimeline.firstReload = YES;
	[self saveScrollPosition];
	[PathController instance].currentTimeline = weiboAccount.comments;
	[self reloadTimeline];
}
-(void)selectFavorites{
	[PathController instance].currentTimeline.firstReload = YES;
	[self saveScrollPosition];
	[PathController instance].currentTimeline = weiboAccount.favorites;
	[self reloadTimeline];
}

-(void)didStartHTTPConnection:(NSNotification*)notification{
}

-(void)didFinishedHTTPConnection:(NSNotification*)notification{
}

//called when the frame finishes loading
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame
{
    if([webFrame isEqual:[webView mainFrame]])
    {
		[self resumeScrollPosition];
		[webView setNeedsDisplay:YES];
		[[AccountController instance] verifyCurrentAccount];
		[self showMessageBar:@"登录中..."];
    }
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request
   newFrameName:(NSString *)frameName
decisionListener:(id<WebPolicyDecisionListener>)listener{
    if ([[NSString stringWithFormat:@"%@",[request URL]] hasPrefix:@"http://t.cn/"]) {
        [[AccountController instance] expandShortURL:[NSString stringWithFormat:@"%@",[request URL]]];
    }else{
        BOOL OpenLinks = [[NSUserDefaults standardUserDefaults] boolForKey:@"OpenLinks"];
        [self openURL:[request URL] inBackground:OpenLinks];
    }
    
}

-(void)didLoadOlderTimeline:(NSNotification*)notification{
	WeiboTimeline *sender = (WeiboTimeline *)[notification object];
	if ([PathController instance].currentIndex < 0 && [PathController instance].currentTimeline == sender) {
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:0];
		NSArray *statuses = sender.theNewData;
        [data setObject:statuses forKey:@"statuses"];
		[self addOldInnerHTML:[templates getStatuses:data] ForElement:@"content"];
	}
	[self setInnerHTML:@"" forElement:@"spinner"];
}

-(void)didLoadNewerTimeline:(NSNotification*)notification{
//	WeiboTimeline *sender = (WeiboTimeline*)[notification object];
//	if ([PathController instance].currentIndex < 0 && [PathController instance].currentTimeline == sender) {
//		[self saveScrollPosition];
//		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:0];
//		NSArray *statuses = sender.theNewData;
//		[data setObject:statuses forKey:@"statuses"];
//		[self addNewInnerHTML:[templates getStatuses:data] ForElement:@"content"];
//		[self resumeScrollPosition];
//	}
    // Growl 提醒
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GrowlNotification" object:nil];
}

-(void)didLoadTimelineWithPage:(NSNotification*)notification{
	WeiboTimeline *sender = (WeiboTimeline*)[notification object];
	if ([PathController instance].currentIndex < 0 && [PathController instance].currentTimeline == sender) {
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:0];
		NSArray *statuses = sender.theNewData;
		[data setObject:statuses forKey:@"statuses"];
		DOMDocument *dom = [[webView mainFrame] DOMDocument];
		DOMHTMLElement *oldStatusElement = (DOMHTMLElement *)[dom getElementById:@"status_old"];
		[oldStatusElement setInnerHTML:[NSString stringWithFormat:@"%@%@",[oldStatusElement innerHTML],[templates getStatuses:data]]];
	}
}

-(void)didGetUser:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[notification object] forKey:@"user"];
    
	[self setInnerHTML:[templates getUserInfo:data] forElement:@"content"];
	[self setInnerHTML:@"" forElement:@"spinner"];
}

-(void)didGetFriends:(NSNotification*)notification{
	NSDictionary *result=(NSDictionary *)[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[PathController instance].idWithCurrentType forKey:@"screen_name"];
	[data setObject:@"friends" forKey:@"host"];
	[data setObject:[result objectForKey:@"users"] forKey:@"users"];
	[data setObject:[result objectForKey:@"next_cursor"] forKey:@"next_cursor"];
	[data setObject:[result objectForKey:@"previous_cursor"] forKey:@"prev_cursor"];
    
	[self setInnerHTML:[templates getUserList:data] forElement:@"user_content"];
	[self setInnerHTML:@"" forElement:@"spinner"];
}

-(void)didGetFollowers:(NSNotification*)notification{
	NSDictionary *result=(NSDictionary *)[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[PathController instance].idWithCurrentType forKey:@"screen_name"];
	[data setObject:[result objectForKey:@"users"] forKey:@"users"];
	[data setObject:@"followers" forKey:@"host"];
	[data setObject:[result objectForKey:@"next_cursor"] forKey:@"next_cursor"];
	[data setObject:[result objectForKey:@"previous_cursor"] forKey:@"prev_cursor"];
	
	[self setInnerHTML:[templates getUserList:data] forElement:@"user_content"];
	[self setInnerHTML:@"" forElement:@"spinner"];
}

-(void)setWaitingForComments:(NSNotification*)notification{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *commentsElement=(DOMHTMLElement *)[dom getElementById:@"comments"];
	DOMHTMLElement *spinnerElement=(DOMHTMLElement *)[dom getElementById:@"spinner"];
	
	[commentsElement setInnerHTML:@""];
	[spinnerElement setInnerHTML:spinner];
}

-(void)didGetStatusComments:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	NSString *pathId=[PathController instance].idWithCurrentType;
	NSArray *idArray=[pathId componentsSeparatedByString:@":"];
	[data setObject:[idArray objectAtIndex:0] forKey:@"status_id"];
	int page=[(NSString *)[idArray objectAtIndex:1] intValue];
    [data setObject:[NSString stringWithFormat:@"%d",page] forKey:@"current_page"];
	[data setObject:[NSString stringWithFormat:@"%d",page+1] forKey:@"next_page"];
	[data setObject:[NSString stringWithFormat:@"%d",page-1] forKey:@"prev_page"];
	[data setObject:[notification object] forKey:@"comments"];
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *commentsElement=(DOMHTMLElement *)[dom getElementById:@"comments"];
	DOMHTMLElement *spinnerElement=(DOMHTMLElement *)[dom getElementById:@"spinner"];
    
	[commentsElement setInnerHTML:[templates getStatusesComments:data]];
	[spinnerElement setInnerHTML:@""];
}

-(void)didShowStatus:(NSNotification*)notification{
	NSDictionary *status=[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:status   forKey:@"status"];
	[data setObject:spinner forKey:@"spinner"];
	[self setInnerHTML:[templates getStatusesDetails:data] forElement:@"content"];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"weibo://get_comments?id=%@&page=",[status objectForKey:@"id"],@"1"]]];
}

-(void)didGetUserTimeline:(NSNotification*)notification{
    NSDictionary *userStatuses = [NSDictionary dictionaryWithObject:[notification object] forKey:@"statuses"];
	[self setInnerHTML:[templates getUserStatuses:userStatuses] forElement:@"user_content"];
	[self setInnerHTML:@"" forElement:@"spinner"];
}

-(void)showLoadingPage:(NSNotification*)notification{	
	[self setInnerHTML:@"" forElement:@"user_content"];
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *spinnerElement=(DOMHTMLElement *)[dom getElementById:@"spinner"];
	[spinnerElement setInnerHTML:@"<div class='spinner'><img class='status_spinner_image' src='spinner.gif'/></div>"];
}

-(void)showTip:(NSNotification*)notification{
	NSString *tipString=[notification object];
	if ([tipString isNotEqualTo:@""]) {
		[self showMessageBar:[notification object]];
	}else {
		[self hideMessageBar];
	}
}

-(void)didExpandShortURL:(NSNotification*)notification{
    NSDictionary *shortURL = [NSDictionary dictionaryWithObject:[notification object] forKey:@"urls"];
    NSString *urlLong = [[[shortURL objectForKey:@"urls"] objectAtIndex:0] objectForKey:@"url_long"];
    NSURL *url = [NSURL URLWithString:urlLong];
    BOOL OpenLinks = [[NSUserDefaults standardUserDefaults] boolForKey:@"OpenLinks"];
    
    if([urlLong rangeOfRegex:@"v.youku.com"].location != NSNotFound){
        [previewController loadWithURL:urlLong type:@"video"];
    }
    else if([urlLong rangeOfRegex:@"www.tudou.com"].location != NSNotFound)
    {
        [previewController loadWithURL:urlLong type:@"video"];
    }
    else if([urlLong rangeOfRegex:@"v.ku6.com"].location != NSNotFound)
    {
        [previewController loadWithURL:urlLong type:@"video"];
    }
    else if([urlLong rangeOfRegex:@"6.cn"].location != NSNotFound)
    {
        [previewController loadWithURL:urlLong type:@"video"];
    }
    else if([urlLong rangeOfRegex:@"56.com"].location != NSNotFound)
    {
        [previewController loadWithURL:urlLong type:@"video"];
    }
    else if([urlLong rangeOfRegex:@"letv.com"].location != NSNotFound)
    {
        [previewController loadWithURL:urlLong type:@"video"];
    }
    else if(([urlLong rangeOfRegex:@"itunes.apple.com"].location != NSNotFound) && ([urlLong rangeOfRegex:@"/app/"].location != NSNotFound))
    {
        NSURL *linkShare = [NSURL URLWithString:[NSString stringWithFormat:@"http://click.linksynergy.com/fs-bin/stat?id=zr4dq5m07Z8&offerid=146261&type=3&subid=0&tmpid=1826&RD_PARM1=%@",[urlLong urlEncoded]]];
        [self openURL:linkShare inBackground:OpenLinks];
    }
    else
    {
        [self openURL:url inBackground:OpenLinks];
    }
}

-(void)showMessageBar:(NSString*)message{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *tipElement=(DOMHTMLElement *)[dom getElementById:@"message_bar"];
	[tipElement setInnerHTML:message];
	[tipElement setAttribute:@"style" value:@"visibility:visible"];
    
}

-(void)hideMessageBar{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *tipElement=(DOMHTMLElement *)[dom getElementById:@"message_bar"];
	[tipElement setInnerHTML:@""];
	[tipElement setAttribute:@"style" value:@"visibility:hidden"];
	
}

-(void)saveScrollPosition{
	//记录当前的scroll的位置
	NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
    //[[scrollView documentView] scrollPoint:NSMakePoint(0, 0)]; // 初始化滚动条位置
	// get the current scroll position of the document view
	NSRect scrollViewBounds = [[scrollView contentView] bounds];
	//currentTimeline.scrollPosition=scrollViewBounds.origin; // keep track of position to restore
	DOMElement *element = [[[webView mainFrame] DOMDocument] elementFromPoint:4 y:0];
//	if ([[element getAttribute:@"class"] isNotEqualTo:@"stream-item-content status"]) {
//		element = [[[webView mainFrame] DOMDocument] elementFromPoint:4 y:8];
//	}
	NSString *itemId = [element getAttribute:@"id"];
	NSInteger relativeOffset = scrollViewBounds.origin.y-[element offsetTop];
	NSDictionary *scrollPosition = [NSDictionary dictionaryWithObjectsAndKeys:itemId,@"itemId",
                                    [NSNumber numberWithInt:relativeOffset],@"relativeOffset",nil];
	[[NSUserDefaults standardUserDefaults] setValue:scrollPosition forKey:[NSString stringWithFormat:@"statuses/%@/%@.scrollPosition",[[AccountController instance] currentAccount].screenName,[PathController instance].currentTimeline.typeName]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)resumeScrollPosition{
	NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];	
	NSDictionary *scrollPosiotion = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"statuses/%@/%@.scrollPosition",[[AccountController instance] currentAccount].screenName,[PathController instance].currentTimeline.typeName]];
	NSString *itemId = [scrollPosiotion valueForKey:@"itemId"];
	NSNumber *relativeOffset = [scrollPosiotion valueForKey:@"relativeOffset"];
	DOMElement* element = [[[webView mainFrame] DOMDocument] getElementById:itemId];
	int y = [element offsetTop] + [relativeOffset intValue];
	[[scrollView documentView] scrollPoint:NSMakePoint(0, y)];
}

-(void)loadMainPage{
	[[webView mainFrame] loadHTMLString:[templates getMain] baseURL:[templates getBaseURL]];
}

//Set InnerHTML For Element
-(void)setInnerHTML:(NSString*)innerHTML forElement:(NSString*)elementId{
	DOMDocument *dom = [[webView mainFrame] DOMDocument];
	DOMHTMLElement *element = (DOMHTMLElement *)[dom getElementById:elementId];
	[element setInnerHTML:innerHTML];
}

-(void)addNewInnerHTML:(NSString *)newInnerHTML ForElement:(NSString*)elementId{
	DOMDocument *dom = [[webView mainFrame] DOMDocument];
	DOMHTMLElement *element = (DOMHTMLElement *)[dom getElementById:elementId];    
	[element setInnerHTML:[NSString stringWithFormat:@"%@%@",newInnerHTML,[element innerHTML]]];
}

-(void)addOldInnerHTML:(NSString *)oldInnerHTML ForElement:(NSString*)elementId{
	DOMDocument *dom = [[webView mainFrame] DOMDocument];
	DOMHTMLElement *element = (DOMHTMLElement *)[dom getElementById:elementId];
	[element setInnerHTML:[NSString stringWithFormat:@"%@%@",[element innerHTML],oldInnerHTML]];
}

// 控制浏览器是否在后台打开
- (void)openURL:(NSURL *)url inBackground:(BOOL)background
{
    if (background)
    {
        NSArray* urls = [NSArray arrayWithObject:url];
        [[NSWorkspace sharedWorkspace] openURLs:urls withAppBundleIdentifier:nil options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:nil];    
    }
    else
    {
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

-(void)dealloc{
	[webView release];
	[super dealloc];
}

@end