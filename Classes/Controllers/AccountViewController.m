//
//  AccountViewController.m
//  Mint
//
//  Created by  on 11-9-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AccountViewController.h"

@implementation AccountViewController

@synthesize accounts;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    NSDictionary *accountsDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"accounts"];
    //NSString *userid = nil;
    NSString *screenName = nil;
    
    for(NSString *account in accountsDic){
        //userid = account;
        screenName = [[accountsDic objectForKey:account] objectForKey:@"screenName"];
        self.accounts = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:screenName, nil]];
    }
    //NSLog(@"%@",self.accounts);
}

#pragma mark TableView Data Source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.accounts count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return nil;
}

#pragma mark -
#pragma mark TableView Delegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20.0;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    [aCell setTitle:[self.accounts objectAtIndex:rowIndex]];
    [aCell setWraps:YES];
}

- (void)dealloc
{
    [accounts release];
    [super dealloc];
}

@end
