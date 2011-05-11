//
//  ScoreHeaderViewController.m
//  GradeLedger
//
//  Created by Gregory Combs on 5/10/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "ScoreHeaderViewController.h"
#import "DateUtils.h"

#import "GRLDatabase.h"
#import "AssignmentObj.h"
#import "CategoryObj.h"

#import "VerticalTextCell.h"

@implementation ScoreHeaderViewController

- (id)init
{
	if((self = [super init])) {
	}
	return self;
}


- (void)dealloc
{	
	[super dealloc];
}

- (BOOL) isFlipped {
	return NO;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	NSArray *cols = [self.database.assignmentController arrangedObjects];

	if ([cols count] != [self.headerTableView numberOfColumns])
		[self reloadTableData];
	
	return 1;
}

- (IBAction) reloadTableData {
	
	// REMOVE ALL TABLE COLUMNS, WITHOUT ITERATING THROUGH THE TABLE, PER SE.
	while ([self.headerTableView numberOfColumns] > 0)
		[self.headerTableView removeTableColumn:[[self.headerTableView tableColumns] objectAtIndex:0]];
	
	NSArray *cols = [self.database.assignmentController arrangedObjects];
	for (AssignmentObj *ass in cols)// database allAssignmentsSortedByDueDate])
	{
		NSTableColumn *col = [[[NSTableColumn alloc] initWithIdentifier:[ass objectID]] autorelease];
		[col setWidth:30];
		[col setMinWidth:30];
		[col setMaxWidth:30];
		
		[self.headerTableView addTableColumn:col];
	}
	
	[self.headerTableView setRefusesFirstResponder:YES];
	[self.headerTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
	
	// do we need to do this?
	//[self.headerTableView reloadData];  //GREG REVERSE CHANGE???
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	NSMutableString *str = [[[NSMutableString alloc] init] autorelease];
	
	id assCode = [aTableColumn identifier];
	AssignmentObj * ass = (AssignmentObj *)[[database managedObjectContext] objectWithID:assCode];
	if (ass) {		
		[str appendFormat:@"%@: %@ pts", ass.name, ass.maxPoints];
		if (ass.dueDate) {
			[str appendFormat:@"\nDue: %@", [DateUtils stringFromDate:ass.dueDate withFormat:kGRLDateShortFormat]];
		}
	}
	return str;
	
}

- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
	NSString *tooltipStr = nil;
	id assCode = [tableColumn identifier];
	AssignmentObj * ass = (AssignmentObj *)[[database managedObjectContext] objectWithID:assCode];
	if (ass) {		
		tooltipStr = [NSString stringWithFormat:@"Category: %@ (%@%%)", ass.category.name, ass.category.percentOfFinalScore];
	}
	return tooltipStr;
}

- (NSColor *)colorForAssignment:(AssignmentObj *)ass {
	if([ass isAttendance]) // if this is an attendance record, colorize the cell
		// faded yellow
		return [[NSColor yellowColor] blendedColorWithFraction:0.5 ofColor:[NSColor whiteColor]];
	else if ([ass isExtraCredit])
		return [NSColor orangeColor];
	else
		return [NSColor colorForControlTint:NSDefaultControlTint];	
}


- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if (tableView != self.headerTableView || aTableColumn == nil)  // we always get asked for this first.  If we give it anything but nil, it assumes its for the whole row
		return nil; 
	
	VerticalTextCell *cell = [[[VerticalTextCell alloc] init] autorelease];
	
	[cell setWraps:NO];
	[cell setScrollable:NO];		
	[cell setEditable:NO];
	[cell setControlSize:NSSmallControlSize];
	[cell setBordered:NO];
	
	AssignmentObj * ass = (AssignmentObj *)[[database managedObjectContext] objectWithID:[aTableColumn identifier]];
	[cell setRepresentedObject:ass];
	
	//NSFont *smallFont = [NSFont fontWithName:@"Lucida Grande" size:10];
	//cell.customFont = smallFont;
	
	[cell setDrawsBackground:YES];
	[cell setBackgroundColor:[self colorForAssignment:ass]];
	
	return cell;
}


@synthesize headerTableView;
@synthesize toolTipArray;
@synthesize database;
@end
