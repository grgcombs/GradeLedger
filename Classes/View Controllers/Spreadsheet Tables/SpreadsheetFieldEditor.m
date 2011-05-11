//
//  SpreadsheetFieldEditor.m
//  GradeLedger
//
//  Created by Gregory Combs on 4/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "SpreadsheetFieldEditor.h"
#import "SpreadsheetTableView.h"


#define tabKeyCode						48
#define returnKeyCode					76
#define enterKeyCode						36
#define deleteKeyCode					117
#define backspaceKeyCode				51
#define homeKeyCode						115
#define endKeyCode						119
#define leftArrowKeyCode				123
#define rightArrowKeyCode				124
#define downArrowKeyCode				125
#define upArrowKeyCode					126

@interface SpreadsheetFieldEditor (Private)

- (void) doEditCellInTable:(NSTableView *)aTableView column:(NSInteger)colIndex row:(NSInteger)rowIndex;
- (BOOL) canEditCellInTable:(NSTableView *)aTableView column:(NSInteger)proposedCol row:(NSInteger)proposedRow;

@end

@implementation SpreadsheetFieldEditor

@synthesize theTable;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL) isFieldEditor {
	return YES;
}

/*
- (void)keyDown:(NSEvent *)theEvent
{
	[self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}
*/

- (BOOL) canEditCellInTable:(NSTableView *)aTableView column:(NSInteger)proposedCol row:(NSInteger)proposedRow {
	if (proposedCol < 0 || proposedCol >= [aTableView numberOfColumns])
		return NO;
	if (proposedRow < 0 || proposedRow >= [aTableView numberOfRows])
		return NO;
	
	return [[aTableView delegate] tableView:aTableView shouldEditTableColumn:[[aTableView tableColumns] objectAtIndex:proposedCol] row:proposedRow];
}

- (void) doEditCellInTable:(NSTableView *)aTableView column:(NSInteger)colIndex row:(NSInteger)rowIndex {
	// the duplication of this check is intentional ... just being safe... might consider removing it once we're done debugging issues...
	if ([self canEditCellInTable:aTableView column:colIndex row:rowIndex]) {
		SpreadsheetTableView *sheetTable = (SpreadsheetTableView *)aTableView;
		sheetTable.lastCol = colIndex;
		sheetTable.lastRow = rowIndex;
		[sheetTable selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
		[sheetTable editColumn:colIndex row:rowIndex withEvent:nil select:YES];
//		sheetTable.lastRow = [sheetTable editedRow];
//		sheetTable.lastCol = [sheetTable editedColumn]; try the settings above first ... then try this one.
	}
	
}

- (void) keyDown:(NSEvent *) event
{
	unsigned short keyPress = [event keyCode];
	//NSUInteger flags = [event modifierFlags];
	//NSLog(@"%@ = %d", [event charactersIgnoringModifiers], keyPress);
	
	SpreadsheetTableView *sheetTable = (SpreadsheetTableView*) theTable;
	
	[sheetTable validateLastRowAndCol];
	NSInteger proposedRow = sheetTable.lastRow, proposedCol = sheetTable.lastCol;
		
	// NSLog (@"%hu", keyPress);
	switch (keyPress)
	{
		case leftArrowKeyCode: // Left
			proposedCol--;
			if (![self canEditCellInTable:sheetTable column:proposedCol row:proposedRow])
				proposedCol--;	// SKIP the ones that we can't edit
			break;
			
		//case tabKeyCode:	// not sure we need this one here, it should be automatic.
		case rightArrowKeyCode: // Right
			proposedCol++;
			if (![self canEditCellInTable:sheetTable column:proposedCol row:proposedRow])
				proposedCol++;	// SKIP the ones that we can't edit
			break;
			
		case returnKeyCode:
		case enterKeyCode:
		case downArrowKeyCode: // Down
			proposedRow++;
			if (![self canEditCellInTable:sheetTable column:proposedCol row:proposedRow])
				proposedRow++;	// SKIP the ones that we can't edit
			break;
			
			
		case upArrowKeyCode: // Up
			proposedRow--;
			if (![self canEditCellInTable:sheetTable column:proposedCol row:proposedRow])
				proposedRow--;	// SKIP the ones that we can't edit
			break;
			
		case homeKeyCode:
			proposedCol = 0;
			if (![self canEditCellInTable:sheetTable column:proposedCol row:proposedRow])
				proposedCol++;	// SKIP the ones that we can't edit
			break;
			
		case endKeyCode:
			proposedCol = [sheetTable numberOfColumns]-1;
			if (![self canEditCellInTable:sheetTable column:proposedCol row:proposedRow])
				proposedCol--;	// SKIP the ones that we can't edit
			break;
			
		default:
			[super keyDown:event];
			return;
	}
		
	// if we made it this far, then we can try to edit the cell...
	[self doEditCellInTable:sheetTable column:proposedCol row:proposedRow];

}

#if 0
- (void)insertNewline:(id)sender
{
	// Pressing Return moves to the next row
	SpreadsheetTableView *sheetTable = (SpreadsheetTableView*) theTable;
	
	if (sheetTable.lastRow < [sheetTable numberOfRows] - 1) {
		if ([self canEditCellInTable:sheetTable column:sheetTable.lastCol row:sheetTable.lastRow + 1]) {			
			//[sheetTable deselectAll:self];
			sheetTable.lastRow++;
			[sheetTable selectRowIndexes:[NSIndexSet indexSetWithIndex:sheetTable.lastRow] byExtendingSelection:NO];
			[sheetTable editColumn:sheetTable.lastCol row:sheetTable.lastRow withEvent:nil select:YES];			
			//[sheetTable performClickOnCellAtColumn:newCol row:newRow];
			//sheetTable.lastRow = newRow;
			//sheetTable.lastRow = [sheetTable editedRow];
			//sheetTable.lastRow = [sheetTable clickedRow];
			//sheetTable.lastRow = [sheetTable selectedRow];
		}
	}

}


// return on edited cell ends editing
- (void) textDidEndEditing: (NSNotification *) notification {
    NSDictionary *userInfo;
    userInfo = [notification userInfo];
	
    NSNumber *textMovement;
    textMovement = [userInfo objectForKey: @"NSTextMovement"];
	
    NSInteger movementCode;
    movementCode = [textMovement integerValue];
	
    // see if this a 'pressed-return' instance
	
    if (movementCode == NSReturnTextMovement) {
        // hijack the notification and pass a different textMovement
        // value
		
        textMovement = [NSNumber numberWithInt: NSIllegalTextMovement];
		
        NSDictionary *newUserInfo;
        newUserInfo = [NSDictionary dictionaryWithObject: textMovement
												  forKey: @"NSTextMovement"];
		
        notification = [NSNotification notificationWithName:
						[notification name]
													 object: [notification object]
												   userInfo: newUserInfo];
    }
	[[self window] makeFirstResponder:self];
    [super textDidEndEditing: notification];
	
} // textDidEndEditing
#endif


@end
