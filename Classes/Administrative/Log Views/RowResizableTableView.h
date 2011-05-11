/*
 RowResizableTableView
 Written by Evan Jones <ejones@uwaterloo.ca>, 14-11-2002
 http://www.eng.uwaterloo.ca/~ejones/

 Released under the GNU LGPL.

 That means that you can use this class in open source or commercial products, with the limitation that you must distribute the source code for this class, and any modifications you make. See http://www.gnu.org/ for more information.

 TODO LIST:
 - verifying that everything works when data sources change or update
 - verifying that it works in other edge cases like that
 - move the scrollview when the text insertion point moves off the screen
 - get this working with outline views
 - define an API to play nice with others
 - package, document, promote
 */

#import <AppKit/AppKit.h>

/** An NSTableView subclass which allows for resizable rows. At the moment the implementation is FAR from optimized, however it seems to run reasonably well with moderately sized tables. Right now, the table rows will resize itself to fit the contents of the text cells. In the future, it may be possible to programatically turn this feature on and off and use setHeightOfRow to programatically change the heights. */
@interface RowResizableTableView : NSTableView {

#include "RowResizableViewVars.h"
    
}

#include "RowResizableViewMethods.h"

// Gross hack to allow code sharing between RowResizable*Views
#define ROW_RESIZABLE_WILL_DISPLAY_CELL_SELECTOR @selector(tableView:willDisplayCell:forTableColumn:row:)

@property BOOL gridCalculated;
@property BOOL respondsToWillDisplayCell;
@end
