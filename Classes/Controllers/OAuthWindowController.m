//
//  OAuthWindowController.m
//  Mint
//
//  Created by  on 11-8-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "OAuthWindowController.h"

@implementation OAuthWindowController

@synthesize pinTextField;

- (id)init
{
    self = [super initWithWindowNibName:@"OAuthWindow"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)requestTokenURL:(id)sender
{
    login = [[OAuthLogin alloc] init];
    login.delegate = self;
    [login requestToken];
}

- (IBAction)loginMint:(id)sender
{
    login.pin = [pinTextField stringValue];
    if (login.pin) {
        [login requestAccessToken];
    }
}

- (void)oauthSuccess:(NSArray *)toKen user:(NSObject *)user
{
    NSDictionary *dic = (NSDictionary*)user;
    WeiboAccount *account = [[WeiboAccount alloc] init];
    account.tokenKey = [toKen objectAtIndex:0];
    account.tokenSecret = [toKen objectAtIndex:1];
    account.userID = [dic objectForKey:@"id"];
    account.screenName = [dic objectForKey:@"screen_name"];
    //NSLog(@"token: %@, user:%@", toKen, dic);
    
    [[AccountController instance] setCurrentAccount:account];
    [self close];
	mainWindow = [[MainWindowController alloc] init];
	[mainWindow showWindow:nil];
}

- (void)dealloc
{
    [login release];
    [pinTextField release];
    [mainWindow release];
    [super dealloc];
}

@end
