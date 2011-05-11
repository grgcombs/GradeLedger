//
//  CCDGrowingTextField.m
//  GradeLedger
//
//  Created by Gregory Combs on 5/25/10.
//  Found on CocoaDev, written by Sailesh Agrawal.
//

#import "CCDGrowingTextField.h"

@interface CCDGrowingTextField(Private)

- (void)updateDefaultMargins;
- (void)viewDidMoveToSuperview;
- (void)resetFrameToDefault;
- (void)sizeToFit;
- (void)textDidChange: (NSNotification *)notification;
- (void)textDidEndEditing:(NSNotification *)notification;

@end

@implementation CCDGrowingTextField


- (id)initWithFrame: (NSRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		defaultFrame = frame;
	}
	return self;
}


- (id)initWithCoder: (NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder])) {
		defaultFrame = [self frame];
	}
	return self;
}


- (void)awakeFromNib
{
	[self updateDefaultMargins];
}


@end // CCDGrowingTextField


@implementation CCDGrowingTextField(Private)


- (void)updateDefaultMargins
{
	NSRect myFrame = [self frame];
	NSRect superBounds = [[self superview] bounds];
	defaultLeftMargin = NSMinX(myFrame);
	defaultRightMargin = superBounds.size.width - NSMaxX(myFrame);
}


- (void)viewDidMoveToSuperview
{
	[super viewDidMoveToSuperview];
	[self updateDefaultMargins];
}


- (void)resetFrameToDefault
{
	NSRect myFrame = [self frame];
	if (([self autoresizingMask] & NSViewWidthSizable) != 0) {
		myFrame.size.width = [[self superview] bounds].size.width -
		(myFrame.origin.x + defaultRightMargin);
	} else {
		myFrame.size.width = defaultFrame.size.width;
	}
	[self setFrame:myFrame];
}


- (void)sizeToFit
{
	if ([[self stringValue] isEqualToString:@""] && ![self currentEditor]) {
		/*
		 * If we're not in the middle of an editing scession and the text field
		 * is empty then reset our frame to the default size.
		 */
		[self resetFrameToDefault];
	} else {
		[super sizeToFit];
		NSRect myFrame = [self frame];
		
		if (([self autoresizingMask] & NSViewWidthSizable) != 0) {
			CGFloat curRightMargin = [[self superview] bounds].size.width - NSMaxX(myFrame);
			if (curRightMargin < defaultRightMargin) {
				[self resetFrameToDefault];
			}
		} else {
			if (myFrame.size.width > defaultFrame.size.width) {
				[self resetFrameToDefault];
			}
		}
	}
}


- (void)textDidChange: (NSNotification *)notification
{
	[super textDidChange:notification];
	[self sizeToFit];
}


- (void)textDidEndEditing:(NSNotification *)notification
{
	[super textDidEndEditing:notification];
	[self sizeToFit];
}


@end // CCDGrowingTextField(Private)