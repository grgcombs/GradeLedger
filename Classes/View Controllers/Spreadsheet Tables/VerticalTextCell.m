//
//  VerticalTextCell.m
//
//  Created by Gregory Combs on 4/29/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "VerticalTextCell.h"

@implementation VerticalTextCell

/*
- (id)init {
	if (self = [super init]) {
		[self setControlSize:NSSmallControlSize];
	}
	return self;
}
*/

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
		
	NSMutableDictionary *atr = [NSMutableDictionary dictionary];
    NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:12];
	
	if (self.customFont != nil)
		[atr setObject:self.customFont forKey:NSFontAttributeName];
	else
		[atr setObject:font forKey:NSFontAttributeName];
	
	if ([self drawsBackground]) {
		[[[self backgroundColor] colorWithAlphaComponent:0.7] set];
	}
//	else {
//		[[[self backgroundColor] colorWithAlphaComponent:0.10] set];
		
//	}
	
	NSRectFillUsingOperation(cellFrame, NSCompositeSourceOver);
	
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    [currentContext saveGraphicsState];
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:NSMinX(cellFrame) yBy:NSMinY(cellFrame)];
    [transform rotateByDegrees:-90];
    [transform concat];
			  
	CGFloat anX = -NSHeight(cellFrame);
	CGFloat anY = 0;
	CGFloat anHeight = NSHeight(cellFrame);
	CGFloat anWidth = NSWidth(cellFrame);

	// vertical inset 5 pixels
    [[self stringValue] drawInRect:NSMakeRect(anX,anY,anHeight,anWidth) withAttributes:atr]; 
	    
    [currentContext restoreGraphicsState];
	
}

- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view {
	return NSZeroRect; // remove this to show tool tip thingy
}

/*
- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view {
	return;
	
	NSMutableDictionary *atr = [NSMutableDictionary dictionary];
    NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:12];
	
	if (self.customFont != nil)
		[atr setObject:self.customFont forKey:NSFontAttributeName];
	else
		[atr setObject:font forKey:NSFontAttributeName];
	
	[[[self backgroundColor] colorWithAlphaComponent:0.7] set];
	NSRectFillUsingOperation(cellFrame, NSCompositeSourceOver);
	
	[[self stringValue] drawInRect:cellFrame withAttributes:atr]; 

}
*/
@synthesize customFont;

@end
