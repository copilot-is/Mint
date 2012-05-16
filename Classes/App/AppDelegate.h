//
//  AppDelegate.h
//  Rainbow
//
//  Created by Luke on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/SUUpdater.h>
#import "MainWindowController.h"
#import "OAuthWindowController.h"
#import "AppURLHandler.h"
#import "AppGrowl.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    MainWindowController *mainWindow;
    OAuthWindowController *oauthWindow;
	AppURLHandler *urlHandler;
	AppGrowl *growl;
    SUUpdater *updater;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (void)openMainWindow;

@end
