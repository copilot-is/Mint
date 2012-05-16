//
//  DragDropTextField.m
//  Mint
//
//  Created by John on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DragDropTextField.h"

@implementation DragDropTextField

- (id) init
{
    self = [super init];
    if (self) {
        // Register to accept filename drag/drop
        [self registerForDraggedTypes:[NSArray arrayWithObject:(NSString *)kUTTypeFileURL]];
    }
    return self;
}

#pragma mark NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationGeneric;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSLog(@"1");
	int i;
	NSPasteboard *pboard;
	pboard = [sender draggingPasteboard];
	if ([[pboard types] containsObject:NSFilenamesPboardType])
	{
		id delegate = [self delegate];
		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
		if ([delegate respondsToSelector:@selector(acceptFilenameDrag:)])
		{
			for (i=0;i<[filenames count];i++)
			{
				[delegate performSelector:@selector(acceptFilenameDrag:) withObject:[filenames objectAtIndex:i]];
			}
		}
		return YES;
	}
	return NO;
}

@end
