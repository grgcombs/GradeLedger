//
//  DateHeaderController.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "DateHeaderController.h"
#import "GRLDefines.h"
#import "DateUtils.h"
#import "VerticalTextCell.h"
#import "DocumentPreferences.h"
#import "AttendanceForDate.h"
#import "NSManagedObjectContext+EZFetch.h"

@implementation DateHeaderController

@synthesize headerTableView;
@synthesize prefs;

- (id)init
{
	if((self = [super init])) {
		// Setup the header cell
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self reloadTableData];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return 1;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	NSDate *aDate = [aTableColumn identifier];
	NSString *dateStr = [DateUtils dateAsHeaderString:aDate];	// set the string for date
	return dateStr;
}

- (NSColor *)colorForDate:(NSDate *)date withExcludedSet:(NSSet *)excludedSet{

	NSDate *today = [DateUtils today];
	if (excludedSet && [excludedSet containsObject:date]) {
		return [[NSColor grayColor] blendedColorWithFraction:0.5 ofColor:[NSColor whiteColor]];
	}
	else if ([date isEqualToDate:today]) {
		// faded yellow
		return [[NSColor yellowColor] blendedColorWithFraction:0.5 ofColor:[NSColor whiteColor]];
	}
	else {
		//return [[NSColor blueColor] blendedColorWithFraction:0.75 ofColor:[NSColor whiteColor]];
		return [NSColor colorForControlTint:NSDefaultControlTint];	
	}	
}

- (void) reloadTableData {
	
	while ([headerTableView numberOfColumns]) {
		NSTableColumn *col = [[headerTableView tableColumns] objectAtIndex:0];
		[headerTableView removeTableColumn:col];
	}
	
	NSSet * excludedClassDays = [NSKeyedUnarchiver unarchiveObjectWithData:[self.prefs valueForKey:@"excludedClassDays"]];
			
	NSInteger colIndex = 0;
	for (NSDate *date in self.prefs.classDaysList) {
		NSTableColumn *col = [[[NSTableColumn alloc] initWithIdentifier:date] autorelease];
		[col setWidth:30];
		[col setMinWidth:30];
		[col setMaxWidth:30];
		
		VerticalTextCell *headerCell = [[[VerticalTextCell alloc] initTextCell:[DateUtils dateAsHeaderString:date]] autorelease];
		[headerCell setDrawsBackground:YES];
		[headerCell setBackgroundColor:[self colorForDate:date withExcludedSet:excludedClassDays]];
		[col setDataCell:headerCell];
		
		[headerTableView addTableColumn:col];
		
		colIndex++;
	}
	
	[headerTableView setRefusesFirstResponder:YES];
	[headerTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
}

- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
	NSString *tooltipStr = nil;
	NSDate *date = [tableColumn identifier];
	NSSet * excludedSet = [NSKeyedUnarchiver unarchiveObjectWithData:[self.prefs valueForKey:@"excludedClassDays"]];

	if (date && excludedSet && [excludedSet containsObject:date]) {
		tooltipStr = @"This date has been excluded from the attendance record.  This is useful for snow days or holidays when school is closed. To reenable it, click this header column.";
	}
	else {
		tooltipStr = @"This date is included in the attendance record.  To exclude it, click this header column. This is useful for dicounting snow days or holidays when school is closed.";		
	}

	return tooltipStr;
}

// Exclude this date from the attendance record, and record all students as excused from class.
// probably should do one or the other of this or discounting the number of class days ... haven't figured out which is preferred.
- (IBAction)clickCell:(id)sender 
{
	NSTableColumn * col = [[self.headerTableView tableColumns] objectAtIndex:[headerTableView clickedColumn]];
	NSDate *date = [col identifier];
	
	VerticalTextCell *clickedCell = (VerticalTextCell *)[self.headerTableView preparedCellAtColumn:[self.headerTableView clickedColumn] row:0];

	NSMutableSet *excludedClassDays = [[NSMutableSet alloc] initWithSet:[NSKeyedUnarchiver unarchiveObjectWithData:[self.prefs valueForKey:@"excludedClassDays"]]];

	GRLCode changeTo = GRLPresent;
	
	if ([excludedClassDays containsObject:date]) {
		[excludedClassDays removeObject:date];
	}
	else {
		[excludedClassDays addObject:date];
		changeTo = GRLExcused;
	}
	
#if EXCLUDE_ATTENDANCE == EXCLUDE_MARK_EXCUSED
	NSArray *attenRec = [[self.prefs.associatedDocument managedObjectContext] fetchObjectsArrayForEntityName:@"AttendanceForDate" withPredicate:@"(date == %@)", date];
	for (AttendanceForDate *attDate in attenRec) {
		attDate.attendanceCode = [NSNumber numberWithInteger:changeTo];
	}
#endif
	
	[self.prefs setValue:[NSKeyedArchiver archivedDataWithRootObject:excludedClassDays] forKey:@"excludedClassDays"];	 
	[clickedCell setBackgroundColor:[self colorForDate:date withExcludedSet:excludedClassDays]];

	
	[self.headerTableView updateCell:clickedCell];
	[self.headerTableView setNeedsDisplay];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
	return NO;
}


@end
