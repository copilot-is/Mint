//
//  ImagePanelController.m
//  Bubble
//
//  Created by Luke on 9/12/10.
//  Change by John
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImagePanelController.h"

#define ZOOM_IN_FACTOR  1.414214
#define ZOOM_OUT_FACTOR 0.7071068

@implementation ImagePanelController

@synthesize fromRect;

- (id)init {
	self = [super initWithWindowNibName:@"ImagePanel"];
	if (self) {
		NSWindow *window=[self window];
		initPanelRect =[window frame];
	}
	return self;
}


- (void)loadImagefromURL:(NSString *)url 
{
	NSWindow *window = [self window];
	NSPoint mouseLoc = [NSEvent mouseLocation];
	fromRect.origin = mouseLoc;
	fromRect.size = CGSizeMake(1, 1);
	
	if (![window isVisible]) {
        [imageView setHidden:YES];
        [imageView setImage:nil imageProperties:nil];
		[[self window] setFrame:initPanelRect display:NO];
		[[self window] zoomOnFromRect:fromRect];
	}
	[progressIndicator display];
	[progressIndicator startAnimation:self];
    
    NSURL *imageURL = [NSURL URLWithString:url];
    
    CGImageRef          image = NULL;
    CGImageSourceRef    isr = CGImageSourceCreateWithURL( (CFURLRef)imageURL, NULL);
    if (isr)
    {
		NSDictionary *options = [NSDictionary dictionaryWithObject: (id)kCFBooleanTrue  forKey: (id) kCGImageSourceShouldCache];
        image = CGImageSourceCreateImageAtIndex(isr, 0, (CFDictionaryRef)options);
        
        if (image)
        {
            imageProperties = (NSDictionary*)CGImageSourceCopyPropertiesAtIndex(isr, 0, (CFDictionaryRef)imageProperties);
            imageUTType = (NSString*)CGImageSourceGetType(isr);
            [imageUTType retain];
        }
		CFRelease(isr);
    }
    
    if (image) {
        //屏幕大小
        NSRect screenFrame = [[NSScreen mainScreen] frame];
        NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
        
		//图片
	    NSImage	*newImage = [self imageFromCGImageRef:image];
		NSSize imageSize = [newImage size];
        
		NSRect frame = [window frame];
        
        frame.size.width = imageSize.width+20;
        frame.size.height = imageSize.height+50;
        
		if (imageSize.height+50 > visibleFrame.size.height) {
			frame.size.width = imageSize.width;
			frame.size.height = visibleFrame.size.height;
		}
        if(imageSize.width+20 > visibleFrame.size.width)
        {
            frame.size.width = visibleFrame.size.width;
			frame.size.height = imageSize.height;
        }
        if(imageSize.width+20 > visibleFrame.size.width && imageSize.height+50 > visibleFrame.size.height)
        {
            frame.size.width = visibleFrame.size.width;
			frame.size.height = visibleFrame.size.height;
        }
        
        //显示屏幕中间
        frame.origin.x = (visibleFrame.size.width-frame.size.width)/2+(screenFrame.size.width-visibleFrame.size.width);
        frame.origin.y = (visibleFrame.size.height-frame.size.height)/2+(screenFrame.size.height-visibleFrame.size.height-22);
        
        //NSLog(@"frame:%f,%f",frame.size.width,frame.size.height);
        
        [zoomIn setFrameOrigin:CGPointMake(frame.size.width-22, -(frame.size.height-142))];
        [zoomOut setFrameOrigin:CGPointMake(frame.size.width-40, -(frame.size.height-142))];
        [zoomActualFit setFrameOrigin:CGPointMake(frame.size.width-60, -(frame.size.height-142))];
        [zoomIn setHidden:NO];
        [zoomOut setHidden:NO];
        [zoomActualFit setHidden:NO];
        
        [progressIndicator stopAnimation:self];
        
        [window setFrame:frame display:YES animate:YES];
        [imageView setHidden:NO];
        [imageView setImage:image imageProperties:imageProperties];
		CGImageRelease(image);
        [imageView setDoubleClickOpensImageEditPanel:NO];
        [imageView setCurrentToolMode:IKToolModeMove];
        [imageView zoomImageToActualSize: self];
        [imageView setDelegate: self];
    }
}

#pragma mark -
#pragma mark Zoom
- (IBAction)doZoomIn:(id)sender
{
    CGFloat zoomFactor = [imageView zoomFactor];
    [imageView setZoomFactor:zoomFactor * ZOOM_IN_FACTOR];
}
- (IBAction)doZoomOut:(id)sender
{
    CGFloat zoomFactor = [imageView zoomFactor];
    [imageView setZoomFactor:zoomFactor * ZOOM_OUT_FACTOR];
}
- (IBAction)doZoomActualFit:(id)sender
{
    NSButton *button = (NSButton*)sender;
    
    switch (button.state)
    {
        case 0:
            [imageView zoomImageToActualSize: self];
            break;
        case 1:
            [imageView zoomImageToFit: self];
            break;
    }
}

- (BOOL)windowShouldClose:(id)sender{
	[[self window] zoomOffToRect:fromRect];
	return YES;
}

- (NSImage*)imageFromCGImageRef:(CGImageRef)image
{ 
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0); 
    CGContextRef imageContext = nil; 
    NSImage* newImage = nil; // Get the image dimensions. 
    imageRect.size.height = CGImageGetHeight(image); 
    imageRect.size.width = CGImageGetWidth(image); 
    
    // Create a new image to receive the Quartz image data. 
    newImage = [[NSImage alloc] initWithSize:imageRect.size]; 
    [newImage lockFocus]; 
    
    // Get the Quartz context and draw. 
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];    
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image); [newImage unlockFocus]; 
    return newImage;
}

@end
