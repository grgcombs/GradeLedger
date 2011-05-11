/*
 RowResizableViewMethods.h
 Written by Evan Jones <ejones@uwaterloo.ca>, 14-11-2002
 http://www.eng.uwaterloo.ca/~ejones/

 Released under the GNU LGPL.

 That means that you can use this class in open source or commercial products, with the limitation that you must distribute the source code for this class, and any modifications you make. See http://www.gnu.org/ for more information.

 IMPORTANT NOTE:

 This file is included into both RowResizableTableView.h and RowResizableOutlineView.h. This is because these two classes share the implementation of the methods defined in this file.

 Yes, I know that this is an ugly hack, but it is the least ugly hack I could find. It is simple to use and to understand. Search the MacOSX-dev mailing list archives for the thread with the subject "Objective-C Multiple Inheritance Work Arounds?" for a detailed discussion. A short list of stuff I tried or thought about and rejected:

 - Hacking the classes so that RowResizableTableView could be both a subclass of NSTableView and NSOutlineView, and then RowResizeableOutlineView became a subclass of "RowResizableTableView-copy".
 - Using the "concrete protocols" library.

 */


/* "PUBLIC" METHODS: These can be called by anyone. */
   
/** Sets the height for the specified row to the specified height. It will automatically adjust all other row origins and setNeedsDisplay if required. */
- (void) setHeightOfRow: (NSInteger) row toHeight: (CGFloat)height;


/* SUBCLASS OVERRIDES */
- (void) dealloc;

- (void) setDelegate: (id) obj;
- (void) tile;
- (void) viewDidEndLiveResize;
- (void) textDidEndEditing:(NSNotification *)aNotification;
- (void) textDidChange:(NSNotification *)notification;
- (NSRect) rectOfRow:(NSInteger)row;


/* "PRIVATE" METHODS: These methods are part of the "implementation" of RowResizable*View. */

/** Performs initialization (primarily of instance variables) that is common to both RowResizable*View. */
- (id) commonInitWithCoder: (NSCoder*) decoder;

    /** Recalculates the row heights for the entire table. */
- (void) recalculateGrid;
    /** Finds the height of the tallest cell in a specified row. */
- (CGFloat) maxHeightInRow:(NSInteger)row;
    /** Returns the cell object for the specified row and column. */
- (NSCell*) cellForRow:(NSInteger)row column:(NSInteger)col;

    /** Returns the height of the cell in the specified column and row. */
- (CGFloat) findHeightForColumn: (NSInteger) column row: (NSInteger) row withValue: (id) value;

/** Sets up dataCell to display the information in tabCol and row. */
- (void) willDisplayCell: (NSCell*) dataCell forTableColumn: (NSTableColumn*) tabCol row: (NSInteger) row;

- (id) getValueForTableColumn: (NSTableColumn*) tabCol row: (NSInteger) row;
- (void)columnDidResize:(NSNotification*)aNotification;
    /** Returns the rectange for the cells in a column, adjusted for intercell spacing and indent. */
//- (NSRect) rectOfCellsForColumn: (NSInteger) column row: (NSInteger) row;

