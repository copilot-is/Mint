//
//  ComposeController.m
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComposeController.h"
#import "NSWindowAdditions.h"

@implementation ComposeController
@synthesize data,postType,weiboAccount,popEmotions;

- (id)init {
	self = [super initWithWindowNibName:@"Compose"];
	weiboAccount = [AccountController instance];
    self.popEmotions = [[EmotionsViewController alloc] init];
    popShow = NO;
    
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(didShowErrorInfo:) 
               name:HTTPConnectionErrorNotification 
             object:nil];
    
	[nc addObserver:self selector:@selector(didPost:) 
			   name:DidPostStatusNotification
			 object:nil];
	
	[nc addObserver:self selector:@selector(handleReply:) 
			   name:ReplyNotification
			 object:nil];
	
	[nc addObserver:self selector:@selector(handleRePost:) 
			   name:RepostNotification
			 object:nil];
    
	[nc addObserver:self selector:@selector(handleSendMessage:) 
			   name:SendMessageNotification
			 object:nil];
	
	return self;
}

-(void)awakeFromNib{

}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    // 最大字数
    int characterMax = 140;
    NSString *string = [textView stringValue];
    int remaining = characterMax - [[string precomposedStringWithCanonicalMapping] length];
    // 剩余字数
    [charactersRemaining setStringValue:[NSString stringWithFormat:@"%d", remaining]];
    if (remaining < 0) {
        [statusLabel setStringValue:@"已超出字数最大限制"];
    } else {
        [postButton setEnabled:YES];
        [statusLabel setStringValue:@""];
    }
    // 如果超出字数限制禁用按钮
    [postButton setEnabled: (remaining < characterMax) && (remaining >= 0)];
}

-(void)composeNew:(NSString *)user avatar:(NSImage *)avatar{
	self.postType = NormalPost;

    [self initTools];
    [avatarView setImage:avatar];
    [avatarView setToolTip:user];
    [reTextField setStringValue:[NSString stringWithFormat:@"%@:\r\n有什么新鲜事想告诉大家？", user]];
	[self popUp];
}

// 评论 回复
-(void)handleReply:(NSNotification*)notification{
	self.postType = ReplyPost;
	self.data = [notification object];

	NSString *user = [data objectForKey:@"user"];
    NSString *content = [data objectForKey:@"content"];
    NSString *avatar = [data objectForKey:@"avatar"];
    NSString *type = [data objectForKey:@"type"];
    
    if ([type isEqualToString:@"reply"]) {
        [[self window] setTitle:@"回复评论"];
    }
    else if([type isEqualToString:@"comment"])
    {
        [[self window] setTitle:@"评论微博"];
    }
    
    [self initTools];
    
    [avatarView setImage:[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:avatar]]];
    [avatarView setToolTip:user];
    [reTextField setStringValue:[NSString stringWithFormat:@"%@:\r\n%@",user,content]];
	[self popUp];
    
    // 控制发布按钮
    NSString *string = [textView stringValue];
    if([[string precomposedStringWithCanonicalMapping] length]==0)
    {
        [postButton setEnabled:NO];
    }
    else
    {
        [postButton setEnabled:YES];
    }
}

// 转发
-(void)handleRePost:(NSNotification*)notification{
	self.postType = Repost;
	self.data = [notification object];
    
	NSString *content = [data objectForKey:@"content"];
	NSString *user = [data objectForKey:@"user"];
	NSString *rtContent = [data objectForKey:@"rt_content"];
	NSString *rtUser = [data objectForKey:@"rt_user"];
    NSString *avatar = [data objectForKey:@"avatar"];
    [self initTools];
    
    [avatarView setImage:[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:avatar]]];
    [avatarView setToolTip:user];
    
	if (rtContent) {
        [reTextField setStringValue:[NSString stringWithFormat:@"%@:\r\n%@",rtUser,rtContent]];
		[textView setStringValue:[NSString stringWithFormat:@"//@%@:%@",user,content]];
        NSText* textEditor = [[self window] fieldEditor:YES forObject:textView];
        [textEditor setSelectedRange:NSMakeRange(0, 0)];
        [self controlTextDidChange:notification];
	}
    else
    {
        [reTextField setStringValue:[NSString stringWithFormat:@"%@:\r\n%@",user,content]];
	}
    
    // 控制发布按钮
    NSString *string = [textView stringValue];
    if([[string precomposedStringWithCanonicalMapping] length]==0)
    {
        [postButton setEnabled:NO];
    }
    else
    {
        [postButton setEnabled:YES];
    }
	[self popUp];
}

-(IBAction)post:(id)sender{
	BOOL upload = NO;
    
    if (uploadImage.image && uploadImage.toolTip) {
        NSData *imageDate = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:uploadImage.toolTip]];
        NSString *fileName = [uploadImage.toolTip lastPathComponent];
//        NSLog(@"image: %lu, fileName:%@",[imageDate length],fileName);
        [weiboAccount postWithStatus:[textView stringValue] image:imageDate imageName:fileName];
        upload = YES;
    }
    
	if (!upload) {
		switch (postType) {
			case NormalPost:
                [weiboAccount postWithStatus:[textView stringValue]];
				break;
			case ReplyPost:
				[self.data setObject:[textView stringValue] forKey:@"comment"];
				[weiboAccount reply:self.data];
				break;
			case Repost:
				[self.data setObject:[textView stringValue] forKey:@"status"];
                if (isComment.state) {
                    [self.data setObject:@"3" forKey:@"isComment"];
                }
				[weiboAccount repost:self.data];
				break;
			default:
				break;
		}
	}
	[postProgressIndicator setHidden:NO];
	[postProgressIndicator startAnimation:self];
	
}

-(void)didPost:(NSNotification*)notification{
	[postProgressIndicator setHidden:YES];
	[postProgressIndicator stopAnimation:self];
    
	[self close];
}

-(void)didShowErrorInfo:(NSNotification*)notification{
	NSError* error = [notification object];
	[postProgressIndicator setHidden:YES];
	[postProgressIndicator stopAnimation:self];
    //NSLog(@"error: %@",[error localizedDescription]);
    [statusLabel setStringValue:[error localizedDescription]];
}

-(void)popUp{
	NSWindow *window=[self window];
	NSPoint mouseLoc = [NSEvent mouseLocation];
	fromRect.origin=mouseLoc;
	fromRect.size.width=1;
	fromRect.size.height=1;
	if (![window isVisible]) {
		[window zoomOnFromRect:fromRect];
	}
	[window display];
	[window orderFront:self];
	[window makeKeyWindow];
}

- (BOOL)windowShouldClose:(id)sender{
	[[self window] zoomOffToRect:fromRect];
    [postButton setEnabled:NO];
    [isComment setHidden:YES];
    [picButton setHidden:YES];
    [uploadImage setHidden:YES];
    [delUploadImage setHidden:YES];
    
    self.data = nil;
	[[self window] setTitle:@""];
    [textView setStringValue:@""];
	[reTextField setStringValue:@""];
    [statusLabel setStringValue:@""];
    [avatarView setImage:nil];
    [uploadImage setImage:nil];
	[charactersRemaining setStringValue:[NSString stringWithFormat:@"%d",140]];
	return YES;
}

#pragma mark -
#pragma mark 根据类型初始化相应工具栏
- (void)initTools
{
    [textView setStringValue:@""];
    switch (postType) {
        case NormalPost:
            [[self window] setTitle:@"发新微博"];
            [picButton setHidden:NO];
            [isComment setHidden:YES];
            [uploadImage setHidden:YES];
            [uploadImage setImage:nil];
            [delUploadImage setHidden:YES];
            break;
        case ReplyPost:
            [picButton setHidden:YES];
            [isComment setHidden:YES];
            [uploadImage setHidden:YES];
            [uploadImage setImage:nil];
            [delUploadImage setHidden:YES];
            break;
        case Repost:
            [[self window] setTitle:@"转发微博"];
            [picButton setHidden:YES];
            [isComment setHidden:NO];
            [uploadImage setHidden:YES];
            [uploadImage setImage:nil];
            [delUploadImage setHidden:YES];
            [isComment setFrameOrigin:CGPointMake(49, 6)];
            break;
        default:
            break;
    }
}

- (NSArray *)supportedImageTypes {
	return [NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", @"gif", nil];
}

- (IBAction)picture:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    
    void (^openPanelHandler)(NSInteger) = ^( NSInteger result )
	{
	    if (result == NSOKButton) {
            NSURL *file = [panel URL];
            if (file) {
                //NSLog(@"image file: %@",file);
                [uploadImage setImage:[[NSImage alloc] initWithContentsOfURL:[panel URL]]];
                [uploadImage setToolTip:[NSString stringWithFormat:@"%@",file]];
                [uploadImage setHidden:NO];
                [delUploadImage setHidden:NO];
            }
	    }
	};

	[panel setAllowedFileTypes:[self supportedImageTypes]];
	[panel beginSheetModalForWindow:[self window] completionHandler:openPanelHandler];
}

- (IBAction)pound:(id)sender
{
    if (![[textView stringValue] isEqualToString:@"#请在这里输入话题#"]) {
        [textView setStringValue:[NSString stringWithFormat:@"#请在这里输入话题#%@",[textView stringValue]]];
        NSText* textEditor = [[self window] fieldEditor:YES forObject:textView];
        [textEditor setSelectedRange:NSMakeRange(1, 8)];
    }
}

- (IBAction)emot:(id)sender
{
    [self.popEmotions.popOver setAnimates:YES];
    if(!popShow){
        [self.popEmotions initWebView];
        [self.popEmotions.popOver showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
        popShow = YES;
    }
    else
    {
        [self.popEmotions.popOver performClose:sender];
        popShow = NO;
    }
}

- (IBAction)cancel:(id)sender
{
    [[self window] zoomOffToRect:fromRect];
}

- (IBAction)delUploadImage:(id)sender
{
    uploadImage.toolTip = nil;
    [uploadImage setImage:nil];
    [uploadImage setHidden:YES];
    [delUploadImage setHidden:YES];
}

- (void)dealloc
{
    [popEmotions release];
    [super dealloc];
}

@end
