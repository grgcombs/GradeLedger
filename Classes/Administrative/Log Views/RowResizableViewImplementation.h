/*
 RowResizableViewImplementation.h
 Written by Evan Jones <ejones@uwaterloo.ca>, 14-11-2002
 http://www.eng.uwaterloo.ca/~ejones/

 Released under the GNU LGPL.

 That means that you can use this class in open source or commercial products, with the limitation that you must distribute the source code for this class, and any modifications you make. See http://www.gnu.org/ for more information.

 IMPORTANT NOTE:

 This file is included into both RowResizableTableView.m and RowResizableOutlineView.m. This is because these two classes share the implementation of the methods defined in this file.

 Yes, I know that this is an ugly hack, but it is the least ugly hack I could find. It is simple to use and to understand. Search the MacOSX-dev mailing list archives for the thread with the subject "Objective-C Multiple Inheritance Work Arounds?" for a detailed discussion. A short list of stuff I tried or thought about and rejected:

 - Hacking the classes so that RowResizableTableView could be both a subclass of NSTableView and NSOutlineView, and then RowResizeableOutlineView became a subclass of "RowResizableTableView-copy".
 - Using the "concrete protocols" library.

 
 CHANGES:
 - ejones: 2003-05-28: Merged changes by Florent Pillet <florent.pillet@wanadoo.fr>:
     - fixed setDelegate so that it recalculates the grid once after [super setDelegate]
     - added setIntercellSpacing override to appropriately require a grid recalculation
     - fixed a bug in rectOfRow which could be called for non-existent rows during drag and drop
 */

-(id)initWithFrame:(NSRect)frame {
    [super initWithFrame:frame];
    if ( self ) {
		// TODO: I should probably include the "init" code from "commonInitWithCoder" here
    }
    return self;
}

- (id) commonInitWithCoder:(NSCoder *)decoder
{
    // Custom initialization: This must be done before calling super's method
    // because that will in turn call recalculateGrid. When we get there, the
    // arrays must exist
    rowHeights = [[NSMutableArray alloc] init];
    rowOrigins = [[NSMutableArray alloc] init];

    gridCalculated = NO;
    respondsToWillDisplayCell = NO;

    self = [super initWithCoder:decoder];
    if ( self )
        {
        // Now set the cells in all the columns to wrap text
        NSInteger i = 0;
        for ( i = 0; i < [[self tableColumns] count]; ++ i )
            {
            [[[[self tableColumns] objectAtIndex: i] dataCell] setWraps: YES];
            }
        }
    else
        {
		 // A problem occured during initialization, so we need to release the arrays
			if (rowHeights) { [rowHeights release]; rowHeights = nil; }
			if (rowOrigins) { [rowOrigins release]; rowOrigins = nil; }
        }
    return [self autorelease];
}

// Properly release all instance variables
- (void) dealloc
{
	if (rowHeights) { [rowHeights release]; rowHeights = nil; }
	if (rowOrigins) { [rowOrigins release]; rowOrigins = nil; }

    [super dealloc];
}

// Override setDelegate to recalculate the grid if we need to
- (void) setDelegate: (id) obj
{
    // Gross hack to allow code sharing between RowResizable*Views
    BOOL doesRespond = [obj respondsToSelector:ROW_RESIZABLE_WILL_DISPLAY_CELL_SELECTOR];
	BOOL recalc = NO;

	// If the delegate is different and it either responds to willDisplayCell, or else if the old delegate did,
	// we need to recalculate the grid. But we can do this ONLY after setting the delegate
	// which may implement the willDisplayCell selector
    if ( obj != [self delegate] && ( doesRespond || respondsToWillDisplayCell ) )
        {
		gridCalculated = YES;	// don't want to be recalculated now
		recalc = YES;			// .. but just after we set the delegate
        }

    respondsToWillDisplayCell = doesRespond;

    [super setDelegate: obj];
	
	if (recalc)
		{
		gridCalculated = NO;
		[self tile];
		}
}

// Override tile to recalculated the grid
- (void) tile
{
    if ( ! gridCalculated )
        {
        // Avoid infinite loops!
        [self recalculateGrid];
        }
    [super tile];
}

// Override viewDidEndLiveResize to invalidate the grid, since the column widths
// may have changed.
// OPTIMISATION: Have recalculateGrid check to see if/what column was actually resized?
- (void) viewDidEndLiveResize
{
    gridCalculated = NO;
    [super viewDidEndLiveResize];

    [self tile];
}

// Monitor columnDidResize to invalidate the grid, since the column widths
// have changed.
// OPTIMISATION: Intercept the super class's "live" column resize messages to avoid tiling twice?
- (void)columnDidResize:(NSNotification*)aNotification
{
    //NSLog( @"tableViewColumnDidResize" );
    gridCalculated = NO;

    [self tile];
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
    //NSLog( @"ended editing" );
    NSInteger editedRow = [self editedRow];
    [super textDidEndEditing: aNotification];
    [self setHeightOfRow: editedRow toHeight: [self maxHeightInRow: editedRow]];
}

// NSTableView is NSText's delegate when editing
- (void)textDidChange:(NSNotification *)notification
{
    //NSLog( @"textDidChange" );
    NSInteger editedRow = [self editedRow];
    NSInteger editedColumn = [self editedColumn];
    //NSCell* cell = [self cellForRow: editedRow column:[self editedColumn]];

    //CGFloat intercellHeight = [self intercellSpacing].height;

    // Set the cell's value to the new string
    // NOTE: I don't need to retain/release here, because i'm going to reset the value back again
    // before the stack clears and the objects are freed. I know, not pretty, but hey, it works
    //id obj = [cell objectValue];
    //[cell setObjectValue: [[notification object] string]];

    // Now ask for the cell's height
    //CGFloat columnWidth = [[[self tableColumns] objectAtIndex: [self editedColumn]] width];
    CGFloat cellHeight = [self findHeightForColumn: editedColumn row: editedRow withValue: [[notification object] string]];

    // if the height does not equal to the current height, we have to ask the whole row how tall they are
    // to determine if this cell is possibly the tallest in the table
    CGFloat currentRowHeight = [[rowHeights objectAtIndex: editedRow] doubleValue];
    if ( cellHeight != currentRowHeight )
        {
        //NSLog( @"cell height = %f, row height = %f", cellHeight, currentRowHeight );
        CGFloat rowHeight = [self maxHeightInRow: editedRow];
        if ( rowHeight > cellHeight ) cellHeight = rowHeight;

        // If now after we have asked all the cells how tall they are, we still have a different height,
        // we need to adjust all the row origins and then refresh the display
        if ( cellHeight != currentRowHeight )
            {
            // Set the new row height
            [self setHeightOfRow: editedRow toHeight: cellHeight];
            }
        }

    // Set the cell's value back
    //[cell setObjectValue: obj];
}

// Override rectOfRow so we can substitute our custom row rectangles
- (NSRect)rectOfRow:(NSInteger)row
{
	// Special case for row<0, may highlight the whole table. Used by Drag and drop.
	if (row < 0)
		return [super rectOfRow:row];
	
    // Hmm, it turns out that this can sometimes get called before tile gets called, meaning that we
    // need to recalculate the grid immediately. I wish there was some better place where I could put
    // this call, so it gets called ONCE and ONLY ONCE when it needs to be. There must be logic in
    // the NSTableView which does this already...
    //NSAssert( gridCalculated, @"Logic error: grid should be calculated by this point" );
    if ( ! gridCalculated )
        [self recalculateGrid];

    NSRect frame = [self bounds];
	NSInteger numRows = [self numberOfRows];
	CGFloat y = 0;
	CGFloat height = 0;

	// during DnD, we can get called to obtain the rect for a row pas
    // the table bounds. Gracefully handle this case.
	if (row >= numRows)
		{
		if (numRows == 0)
			return NSZeroRect;

		height = [[rowHeights objectAtIndex:(numRows-1)] doubleValue];
		y = [[rowOrigins objectAtIndex:(numRows-1)] doubleValue] + height;
		}
	else
		{
		height = [[rowHeights objectAtIndex: row] doubleValue] + [self intercellSpacing].height;
		y = [[rowOrigins objectAtIndex: row] doubleValue];
		}

    NSRect rowRect = NSMakeRect( 0, y, frame.size.width, height );

    /* FIXED HEIGHT TEST:
        NSRect superRect = [super rectOfRow:row];
    //NSLog( @"super's %d: (%f, %f) : %f X %f", row, DISPLAY_RECT( superRect ) );
    //NSLog( @" self's %d: (%f, %f) : %f X %f", row, DISPLAY_RECT( rowRect ) );
    NSAssert( NSEqualRects( superRect, rowRect ), @"super calculated a different rowRect" );
    */

    return rowRect;
}

// Override rowAtPoint so we can substitute our custom row rectangles
- (NSInteger)rowAtPoint:(NSPoint)point
{
    //NSLog( @"rowAtPoint" );

    CGFloat intercellHeight = [self intercellSpacing].height;

    // WARNING: This first loop is copied from rowsInRect. If making changes here, be sure to make changes there
    // or else link the two in some way
    NSUInteger i = 0;
    while ( i < [rowOrigins count] )
        {
        CGFloat rowBottom = [[rowOrigins objectAtIndex: i] doubleValue] + [[rowHeights objectAtIndex: i] doubleValue] + intercellHeight;

        // if the row bottom is GREATER THAN than the bottom of the rect, we want this row
        // if it is EQUAL, we don't want it
        if ( rowBottom > point.y )
            {
            break;
            }
        ++ i;
        }

    if ( i == [rowOrigins count] ) i = -1;

    //NSAssert( [super rowAtPoint: point] == i, @"Super's rowAtPoint does not match!" );
    return i;
}

// Override rowsInRect so we can substitute our custom row rectangles
- (NSRange)rowsInRect:(NSRect)rect
{
    //NSLog( @"rowsInRect" );

    // If there are no rows, we can't be in a rect
    if ( [rowHeights count] == 0 )
        return NSMakeRange( 0, 0 );

    CGFloat rowBottom = 0.0;

    CGFloat intercellHeight = [self intercellSpacing].height;

    // Find the first row with a bottom GREATER THAN OR EQUAL TO the comparison height of the rectangle we are given
    // WARNING: This first loop is copied into rowAtPoint. If making changes here, be sure to make changes there
    // or else link the two in some way
    NSInteger firstIndex = -1;
    NSInteger i = 0;
    while ( i < [rowOrigins count] )
        {
        rowBottom = [[rowOrigins objectAtIndex: i] doubleValue] + [[rowHeights objectAtIndex: i] doubleValue] + intercellHeight;

        //NSLog( @"%d: comparing %f to %f", i, rowBottom, rect.origin.y );
        // if the row bottom is GREATER THAN than the bottom of the rect, we want this row
        // if it is EQUAL, we don't want it
        if ( rowBottom > rect.origin.y )
            {
            firstIndex = i;
            break;
            }
        ++ i;
        }

    // Search for the last index
    // NOTE: No need to test the last index. Small optimization
    while ( i < [rowOrigins count] - 1)
        {
        //NSLog( @"%d: comparing %f to %f", i, rowBottom, rect.origin.y + rect.size.height );
        // if the row bottom is GREATER THAN OR EQUAL TO than the bottom of the rect, we want this row
        if ( rowBottom >= rect.origin.y + rect.size.height )
            {
            break;
            }

        // NOTE: We calculate the rowBottom at the END of the loop.
        // this permits us to retest the row that is the first index without having to calculate it again
        ++ i;
        rowBottom = [[rowOrigins objectAtIndex: i] doubleValue] + [[rowHeights objectAtIndex: i] doubleValue] + intercellHeight;
        }

    // If this occurs, that means the rectangle contains NO rows
    if ( i >= [rowOrigins count] )
        {
        firstIndex = 0;
        i = -1;
        }

    NSAssert( i < (signed) [rowOrigins count], @"Error with indexes" );

    NSRange rowRange = NSMakeRange( firstIndex, i - firstIndex + 1 );

    /* FIXED HEIGHT TEST:
        NSRange superRange = [super rowsInRect:rect];
    //NSLog( @"For rect: (%f, %f) : %f X %f", DISPLAY_RECT( rect ) );
    //NSLog( @"super: index: %d length: %d", superRange.location, superRange.length );
    //NSLog( @" self: index: %d length: %d", rowRange.location, rowRange.length );
    NSAssert( NSEqualRanges( superRange, rowRange ), @"super calculated different rows" );
    */

    return rowRange;
}

// Override reloadData so we can refresh the grid sizes
- (void) reloadData
{
    //NSLog( @"Data reloaded: forgetting grid information." );
    // By setting this to NO, we will recalculate the grid information when we need it
    gridCalculated = NO;
    //[self recalculateGrid];
    [super reloadData];
}

// Override setDataSource so we can forget the grid sizes if a new data source is being set
- (void)setDataSource:(id)source
{
    if ( [super dataSource] != source )
        gridCalculated = NO;

    [super setDataSource: source];
}

// Override setIntercellSpaceing to recalculate the grid
- (void)setIntercellSpacing:(NSSize)aSize
{
	if (!NSEqualSizes(aSize, [self intercellSpacing]))
		gridCalculated = NO;
	[super setIntercellSpacing:aSize];
}

// Override addColumn to set the cell to wrap text by default and to recalculate table heights
- (void) addTableColumn: (NSTableColumn*) col
{
    //NSLog( @"addColumn" );
    [[col dataCell] setWraps: YES];
    //[self recalculateGrid];
    gridCalculated = NO;
    [super addTableColumn: col];
}

- (void) setHeightOfRow: (NSInteger) row toHeight: (CGFloat)height
{
    NSAssert( row >= 0 && row < [rowHeights count], @"Invalid row index" );
    NSAssert( height > 0, @"Invalid height" );

    CGFloat difference = height - [[rowHeights objectAtIndex: row] doubleValue];

    // If the height actually changed, go and adjust all the row origins
    if ( difference != 0.0 )
        {
        [rowHeights replaceObjectAtIndex: row withObject: [NSNumber numberWithDouble: height]];

        NSInteger i = 0;
        for ( i = row + 1; i < [rowHeights count]; ++ i )
            {
            CGFloat newValue = [[rowOrigins objectAtIndex: i] doubleValue] + difference;
            [rowOrigins replaceObjectAtIndex: i withObject: [NSNumber numberWithDouble: newValue]];
            }

        NSText* editor = [self currentEditor];
        // If we are editing a cell ...
        if ( editor != nil )
            {
            NSInteger editedRow = [self editedRow];
            NSView* superview = [editor superview];

            // And the edited cell just changed sizes: resize the editor
            if ( row == editedRow )
                {
                // Now we need to also adjust the edit control's size. There are two ways of doing this
                // 1. The "correct" way: The notification object is the NSText object that is being edited.
                // it's superview is an _NSKeyboardFocusClipView which supports a method called "_adjustFocusRingSize".
                // We call that method and life is good.
                // 2. The hack, but the "API" way: Store the selection, stop editing, resume editing
                // We support both ways in case the API changes.
                if ( [superview respondsToSelector: @selector(_adjustFocusRingSize:) ] )
                    {
                    NSRect frame = [superview frame];
                    //NSLog( @"frame: (%f, %f) : %f X %f", DISPLAY_RECT( frame ) );
                    frame.size.height += difference;
                    [superview setFrame: frame];

                    [(_NSKeyboardFocusClipView*)superview _adjustFocusRingSize: NSMakeSize( 0.0, difference )];
                    //[superview _setKeyboardFocusRingNeedsDisplay];
                    }
                // HACK: This is the fallback
                else
                    {
                    NSLog( @"WARNING: The cocoa API has changed. Enabling hacks mode!" );
                    NSRange selection = [editor selectedRange];
                    [[self window] endEditingFor:nil];
                    [self editColumn: [self editedColumn] row: [self editedRow] withEvent: nil select: NO];
                    [editor setSelectedRange: selection];
                    }
                }
            // otherwise if we are editing a row that is after the resized: reposition the editor
            else if ( editor != nil && row < editedRow )
                {
                // Same hacks as above
                if ( [superview respondsToSelector: @selector(_adjustFocusRingSize:) ] )
                    {
                    NSRect frame = [superview frame];
                    //NSLog( @"frame: (%f, %f) : %f X %f", DISPLAY_RECT( frame ) );
                    //NSLog( @"  row: %f", [[rowOrigins objectAtIndex: editedRow] doubleValue] );
                    frame.origin.y = [[rowOrigins objectAtIndex: editedRow] doubleValue];
                    [superview setFrame: frame];

                    // Strange: we don't need to adjust the focus ring, but we do if we make the editor larger?
                    //[(_NSKeyboardFocusClipView*)superview _adjustFocusRingLocation: NSMakePoint( 0.0, difference )];
                    }
                else
                    {
                    NSLog( @"WARNING: The cocoa API has changed. Enabling hacks mode!" );
                    NSRange selection = [editor selectedRange];
                    [[self window] endEditingFor:nil];
                    [self editColumn: [self editedColumn] row: [self editedRow] withEvent: nil select: NO];
                    [editor setSelectedRange: selection];
                    }
                }
            }

        // Notify ourselves that we need to change our frame's height
        // This will "do the right thing" to figure out how big it needs to be
        [self tile];
        }
    // Otherwise, nothing changed!
    else
        {
        //NSLog( @"setHeightOfRow called, but nothing changed!" );
        }
}

- (CGFloat) findHeightForColumn: (NSInteger) column row: (NSInteger) row withValue: (id) value
{
    NSAssert( column >= 0 && column < [[self tableColumns] count], @"Invalid arguments" );

    NSTableColumn* tabCol = [[self tableColumns] objectAtIndex:column];
    NSCell* dataCell = [self cellForRow:row column:column];

    if ( value == nil )
        value = [self getValueForTableColumn: tabCol row: row];

    // Grab the inital value so we don't lose the reference. I cheat here: I should
    // probably do a retain and a release here, but because the reference gets put back in
    // the cell before the stack gets cleared, life is good. I think.
    id originalValue = [dataCell objectValue];
    [dataCell setObjectValue: value];

    [self willDisplayCell: dataCell forTableColumn: tabCol row: row];

    NSRect rect = [self frameOfCellAtColumn: column row: row];
    rect.size.height = 1000.0;
    CGFloat cellHeight = [dataCell cellSizeForBounds: rect].height;

    [dataCell setObjectValue: originalValue];

    return cellHeight;
}

- (void) recalculateGrid
{
    //NSLog( @"recalculateGrid" );
    int i = 0;

    // We will be up to date shortly
    gridCalculated = YES;

    BOOL somethingChanged = NO;

    // Loop through all of the cells, asking them for their height (for text that has wrapped)
    CGFloat totalHeight = 0.0;
    CGFloat intercellHeight = [self intercellSpacing].height;
    NSInteger numRows = [self numberOfRows];
    for ( i = 0; i < numRows; ++ i )
        {
        CGFloat rowHeight = [self maxHeightInRow: i];

        // If the row already exists ...
        if ( [rowHeights count] > i )
            {
            // And the height has changed ...
            if ( [[rowHeights objectAtIndex: i] doubleValue] != rowHeight )
                {
                // Update the height
                somethingChanged = YES;
                [rowHeights replaceObjectAtIndex: i withObject: [NSNumber numberWithDouble: rowHeight]];
                }
            }
        // Otherwise, add the new height to the array
        else
            {
            somethingChanged = YES;
            [rowHeights addObject: [NSNumber numberWithDouble: rowHeight]];
            }

        if ( [rowOrigins count] > i ) [rowOrigins replaceObjectAtIndex: i withObject: [NSNumber numberWithDouble: totalHeight]];
        else [rowOrigins addObject: [NSNumber numberWithDouble: totalHeight]];

        // Adjust the height to accomodate the cell and the intercell height
        totalHeight += rowHeight + intercellHeight;
        }

    // Remove any excess rows
    while ( [rowHeights count] > i )
        {
        [rowHeights removeLastObject];
        }
    while ( [rowOrigins count] > i )
        {
        [rowOrigins removeLastObject];
        }

    // PHEW! Okay, now we may need to change the frame size to fit the content
    // totalHeight = sum( rowHeights ) + interCellSpacing * numRows
    // NSRect frame = [self frame];
    //CGFloat totalHeight = totalRowHeight + [self intercellSpacing].height * [self numberOfRows];
    /*
     if ( frame.size.height != totalHeight )
     {
         NSLog( @"We aren't the correct height (%f instead of %f); resizing", frame.size.height, totalHeight );
         frame.size.height = totalHeight;
         [self setFrame: frame];

         // Notify the scrollview that we changed our own size
         // TODO: Is this correct?
         [[[self superview] superview] reflectScrolledClipView: (NSClipView*) [self superview]];
         return;
     }
     */

    // CHANGED: We now call recalculateGrid directly from tile, if it is needed.
    // everything else just sets gridCalculated = NO correctly, and all is well
    // If we need to, tell NSTableView that it needs to repaint
    /*if ( somethingChanged )
        {
        //NSLog( @"Recalculating grid determined that we need to repaint" );
        //[self setNeedsDisplayInRect: [self visibleRect]];
        [self tile];
        }
    */

    NSAssert( [rowHeights count] == [self numberOfRows] && [rowOrigins count] == [self numberOfRows], @"Inconsistent row numbers!" );
}

// Determine maximum height of any cell in 'row'
- (CGFloat)maxHeightInRow:(NSInteger)row
{
    CGFloat maxHeight = 0.0;

    NSInteger colIndex = 0;
    for ( colIndex = 0; colIndex < [self numberOfColumns]; colIndex++ )
        {
        CGFloat colHeight = [self findHeightForColumn: colIndex row: row withValue: nil];
        if ( colHeight > maxHeight ) maxHeight = colHeight;
        }
    return maxHeight;
}

- (NSCell*)cellForRow:(NSInteger)row column:(NSInteger)col
{
    NSArray *tableCols = [self tableColumns];
    NSTableColumn* tabCol = [tableCols objectAtIndex:col];
    return [tabCol dataCellForRow:row];
}

