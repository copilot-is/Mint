//
//  ComposeController.h
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AccountController.h"
#import "EmotionsViewController.h"

typedef enum {
	NormalPost=0,
	ReplyPost,
	Repost
}PostType;

@interface ComposeController : NSWindowController {
	IBOutlet NSTextField *textView;
	IBOutlet NSTextField *charactersRemaining;
	IBOutlet NSProgressIndicator * postProgressIndicator;
    IBOutlet NSTextField *statusLabel;
    IBOutlet NSTextField *reTextField;
    IBOutlet NSImageView *avatarView;
    IBOutlet NSImageView *uploadImage;
    IBOutlet NSButton *postButton;
    IBOutlet NSButton *isComment;
    IBOutlet NSButton *picButton;
    IBOutlet NSButton *delUploadImage;
    IBOutlet NSButton *emotButton;
	__weak AccountController *weiboAccount;
	NSRect fromRect;
	PostType postType;
	NSMutableDictionary *data;
    EmotionsViewController *popEmotions;
    BOOL popShow;
}

@property(nonatomic,retain) NSMutableDictionary *data;
@property(nonatomic) PostType postType;
@property(nonatomic,assign) AccountController *weiboAccount;
@property(nonatomic,retain) EmotionsViewController *popEmotions;

- (IBAction)post:(id)sender;
- (IBAction)picture:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)emot:(id)sender;
- (IBAction)pound:(id)sender;
- (IBAction)delUploadImage:(id)sender;

- (NSArray *)supportedImageTypes;
- (void)didShowErrorInfo:(NSNotification*)notification;
- (void)didPost:(NSNotification*)notification;
- (void)composeNew:(NSString*)user avatar:(NSImage*)avatar;
- (void)popUp;
- (void)initTools;

@end
