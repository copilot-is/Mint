//
//  AccountViewController.h
//  Mint
//
//  Created by  on 11-9-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AccountViewController : NSView
{
    IBOutlet NSTableView *tableView;
    NSMutableArray *accounts;
}

@property (retain) NSMutableArray *accounts;

@end
