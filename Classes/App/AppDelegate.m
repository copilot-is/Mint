//
//  AppDelegate.m
//  Rainbow
//
//  Created by Luke on 8/25/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)initializeUserDefaults
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithBool:YES], @"OpenLinks",
                         [NSNumber numberWithBool:YES], @"CheckForUpdates",
                         [NSNumber numberWithInt:2],    @"NotificationTime",
                         [NSNumber numberWithBool:YES], @"isFollower",
                         nil];
    
    for (id key in dic) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:key] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // 自动检查更新
    BOOL checkForUpdates = [[NSUserDefaults standardUserDefaults] integerForKey:@"CheckForUpdates"];
    if(checkForUpdates){
        updater = [[[SUUpdater alloc] init] autorelease];
        [updater checkForUpdatesInBackground];
    }
    
    [self initializeUserDefaults];
	
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
	urlHandler = [[AppURLHandler alloc] init];
	growl = [[AppGrowl alloc] init];
    
	if ([[AccountController instance] getCurrentAccount]) {
        //[[AccountController instance] createFriendships:@"1840142703"]; //关注我
		mainWindow = [[MainWindowController alloc] init];
		[mainWindow showWindow:nil];
	} else {
		oauthWindow = [[OAuthWindowController alloc] init];
		[oauthWindow showWindow:nil];
	}
}

- (void)openMainWindow{
	[oauthWindow close];
	[oauthWindow release];
	mainWindow = [[MainWindowController alloc] init];
	[mainWindow showWindow:nil];
}


#pragma mark CoreData Support

- (NSString *)applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Mint"];
}

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%@ No model to generate a store from", [self class], _cmd);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]),nil);
            
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"Cache.db"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    
	
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}


- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{	
	NSString *urlString=[[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	[urlHandler handleURL:urlString];
}


// dock 图标事件
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
	if (flag) {
		if ([[mainWindow window] isMiniaturized]) {
			[[mainWindow window] deminiaturize:nil];
            return NO;
		}
	} else {
        if ([[AccountController instance] getCurrentAccount]) {
            if(![[mainWindow window] isVisible])
            {
                [mainWindow showWindow:nil];
                return YES;
            }
        }
        else
        {
            if ([[oauthWindow window] isMiniaturized]) {
                [[oauthWindow window] deminiaturize:nil];
            }
            else
            {
                if(![[oauthWindow window] isVisible]){
                    oauthWindow = [[OAuthWindowController alloc] init];
                    [oauthWindow showWindow:nil];
                }
            }
            return YES;
        }
	}
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification{
	[[NSNotificationCenter defaultCenter]postNotificationName:SaveScrollPositionNotification object:nil];
}

- (void)dealloc
{
    [mainWindow release];
    [oauthWindow release];
    [urlHandler release];
    [growl release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
    [managedObjectContext release];
    [super dealloc];
}

@end
