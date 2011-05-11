/*
 RowResizableTableView
 Written by Evan Jones <ejones@uwaterloo.ca>, 14-11-2002
 http://www.eng.uwaterloo.ca/~ejones/
 
 Released under the GNU LGPL.
 
 That means that you can use this class in open source or commercial products, with the limitation that you must distribute the source code for this class, and any modifications you make. See http://www.gnu.org/ for more information.
 
 TODO LIST:
 - verifying that everything works when data sources change or update
 - verifying that it works in other nasty edge cases like that
 - move the scrollview when the text insertion point moves off the screen: Use NSLayoutManager to get the NSPoint of the insertion point
 - get this working with outline views
 - define an API to play nice with others
 - package, document, promote
 */

#import "RowResizableTableView.h"

#define DISPLAY_RECT(r) r.origin.x, r.origin.y, r.size.width, r.size.height

@interface _NSKeyboardFocusClipView : NSClipView
- (NSRect) _getFocusRingFrame;
- (void) _adjustFocusRingSize: (NSSize) adjustment;
- (void) _adjustFocusRingLocation: (NSPoint) adjustment;
@end

@implementation RowResizableTableView

#include "RowResizableViewImplementation.h"

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [self commonInitWithCoder: decoder];
	
	if ( self )
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(columnDidResize:)
													 name:@"NSTableViewColumnDidResizeNotification"
												   object:self];
	}
	return [self retain];
}

// Override frameOfCell so we can substitute our custom row rectangles
- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row
{
	//NSLog( @"frameOfCell column: %d row: %d", column, row );
	
	NSSize intercellSpacing = [self intercellSpacing];
	
	// TODO: Would it be more efficient to do column widths ourselves?
	NSRect rect = [self rectOfColumn: column];
	rect.origin.x += ((NSInteger)intercellSpacing.width/2);
	rect.size.width = rect.size.width - intercellSpacing.width;
	
	// When calculating cell heights we call this method to get the column widths set correctly.
	// Therefore, this function gets called before we have the rowOrigins or rowHeights arrays created,
	// and before our super class will even respond correctly to "frameOfCellAtColumn:row:".
	// So, we do this little test to determine if we are in that situation or not.
	if ( row < [rowOrigins count] )
	{
		rect.origin.y = [[rowOrigins objectAtIndex: row] doubleValue] + ((NSInteger)intercellSpacing.height/2);
		rect.size.height = [[rowHeights objectAtIndex: row] doubleValue];
		
		/* FIXED HEIGHT TEST:
		 NSRect superRect = [super frameOfCellAtColumn: column row: row];
		 //NSLog( @"(%f, %f) : %f X %f", DISPLAY_RECT( superRect ) );
		 //NSLog( @"(%f, %f) : %f X %f", DISPLAY_RECT( rect ) );
		 
		 NSAssert( NSEqualRects( superRect, rect), @"super returned a different cell frame" );
		 */
	}
	
	return rect;    
}


- (void)willDisplayCell: (NSCell*) dataCell forTableColumn: (NSTableColumn*) tabCol row: (NSInteger) row
{
	// Inform the delegate that we "willDisplayCell", if supported
	if ( respondsToWillDisplayCell )
	{
		[_delegate tableView: self willDisplayCell: dataCell forTableColumn: tabCol row: row];
	}
}

- (id) getValueForTableColumn: (NSTableColumn*) tabCol row: (NSInteger) row
{
	return [[self dataSource] tableView:self objectValueForTableColumn:tabCol row: row];
}


@synthesize gridCalculated;
@synthesize respondsToWillDisplayCell;
@end
