/*
 RowResizableViewVars.h
 Written by Evan Jones <ejones@uwaterloo.ca>, 14-11-2002
 http://www.eng.uwaterloo.ca/~ejones/

 Released under the GNU LGPL.

 That means that you can use this class in open source or commercial products, with the limitation that you must distribute the source code for this class, and any modifications you make. See http://www.gnu.org/ for more information.

 IMPORTANT NOTE:

 This file is included into both RowResizableTableView.h and RowResizableOutlineView.h. This is because these two classes share the methods defined in "RowResizableViewImplementation.h".

 Yes, I know that this is an ugly hack, but it is the least ugly hack I could find. It is simple to use and to understand. Search the MacOSX-dev mailing list archives for the thread with the subject "Objective-C Multiple Inheritance Work Arounds?" for a detailed discussion. A short list of stuff I tried or thought about and rejected:

 - Hacking the classes so that RowResizableTableView could be both a subclass of NSTableView and NSOutlineView, and then RowResizeableOutlineView became a subclass of "RowResizableTableView-copy".
 - Using the "concrete protocols" library.

 */

// TODO: This may need to be a "faster" data structure for searching etc
/** The heights for each row in the table. */
NSMutableArray* rowHeights;
/** The y origin co-ordinates for each row in the table. */
NSMutableArray* rowOrigins;

/** The total width of all the columns in the table. */
//CGFloat totalColumnWidth;

/** Determines if the row heights are up to date. */
BOOL gridCalculated;
/** True if there is a delegate and it responds to "willDisplayCell". False otherwise. */
BOOL respondsToWillDisplayCell;


