//
//  SpreadsheetTableView.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "SpreadsheetTableView.h"

@implementation SpreadsheetTableView

@synthesize lastRow;
@synthesize lastCol;

- (void)dealloc {
	[super dealloc];
}

- (void)mouseDown:(NSEvent *)event
{
    [super mouseDown:[NSEvent mouseEventWithType:[event type] location:[event locationInWindow] modifierFlags:[event modifierFlags] timestamp:[event timestamp] windowNumber:[event windowNumber] context:[event context] eventNumber:[event eventNumber] clickCount:1 pressure:[event pressure]]];
	[self updateLastRowAndCol];
}

- (void)getLastRow:(NSInteger *)row column:(NSInteger *)col
{
	*row = lastRow;
	*col = lastCol;
}

- (void)updateLastRowAndCol
{
	lastRow = [self editedRow];
	lastCol = [self editedColumn];
}

- (BOOL)validIndex:(NSInteger)index {
	return (index != NSNotFound && index != -1);
}

- (BOOL)validateLastRowAndCol
{
	if (![self validIndex:self.lastRow])
		self.lastRow = [self editedRow];
	if (![self validIndex:self.lastCol])
		self.lastCol = [self editedColumn];
	
	return ([self validIndex:self.lastRow] && [self validIndex:self.lastCol]);
}


/*


- (void)moveDown
{
	NSInteger r = (lastRow + 1) % [self numberOfRows];
	NSPoint p = [self pointForRow:r column:lastCol];
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown 
										location:p
								   modifierFlags:0
									   timestamp:0
									windowNumber:[[NSApp keyWindow] windowNumber]
										 context:nil
									 eventNumber:0
									  clickCount:1
										pressure:1];
	[self mouseDown:event];
}

- (NSPoint)pointForRow:(NSInteger)r column:(NSInteger)c
{
	NSRect rowRect = [self rectOfRow:r];
	NSRect colRect = [self rectOfColumn:c];
	
	NSRect intersect = NSIntersectionRect(rowRect,colRect);
	
	NSPoint p = NSMakePoint(NSMidX(intersect), NSMidY(intersect));
	return [self convertPoint:p toView:[[self window] contentView]];
}



- (void)moveUp
{
	NSInteger r = lastRow - 1;
	if(r < 0)
		r = [self numberOfRows] - 1;
	NSPoint p = [self pointForRow:r column:lastCol];
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown 
							  location:p
							  modifierFlags:0
							  timestamp:0
							  windowNumber:[[NSApp keyWindow] windowNumber]
							  context:nil
							  eventNumber:0
							  clickCount:1
							  pressure:1];
							  
	[self mouseDown:event];
}


- (void)moveLeft
{
	NSInteger c = lastCol - 1;
	if(c < 0)
		c = [self numberOfColumns] - 1;
	NSPoint p = [self pointForRow:lastRow column:c];
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown 
							  location:p
							  modifierFlags:0
							  timestamp:0
							  windowNumber:[[NSApp keyWindow] windowNumber]
							  context:nil
							  eventNumber:0
							  clickCount:1
							  pressure:1];
	[self mouseDown:event];
}

- (void)moveRight
{
	NSInteger c = (lastCol + 1) % [self numberOfColumns];
	NSPoint p = [self pointForRow:lastRow column:c];
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown 
							  location:p
							  modifierFlags:0
							  timestamp:0
							  windowNumber:[[NSApp keyWindow] windowNumber]
							  context:nil
							  eventNumber:0
							  clickCount:1
							  pressure:1];
	[self mouseDown:event];
}

- (void)endEditing
{
	NSPoint p = NSMakePoint(0,0);
	NSEvent *event = [NSEvent mouseEventWithType:NSLeftMouseDown 
							  location:p
							  modifierFlags:0
							  timestamp:0
							  windowNumber:[[NSApp keyWindow] windowNumber]
							  context:nil
							  eventNumber:0
							  clickCount:1
							  pressure:1];
	[self mouseDown:event];
}
*/


@end
