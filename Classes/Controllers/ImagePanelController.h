//
//  ImagePanelController.h
//  Bubble
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "NSWindowAdditions.h"

@class IKImageView;

@interface ImagePanelController : NSWindowController {
    IBOutlet IKImageView            *imageView;
	IBOutlet NSProgressIndicator    *progressIndicator;
	NSRect                          fromRect;
	NSRect                          initPanelRect;
    NSDictionary                    *imageProperties;
    NSString                        *imageUTType;
    IBOutlet NSButton               *zoomIn;
    IBOutlet NSButton               *zoomOut;
    IBOutlet NSButton               *zoomActualFit;
}

@property(nonatomic)NSRect fromRect;

- (void)loadImagefromURL:(NSString *)url;
- (NSImage*)imageFromCGImageRef:(CGImageRef)image;

@end
