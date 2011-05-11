//
//  GRLAttendanceDS.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLAttendanceDS.h"
#import "DocumentPreferences.h"

#import "StudentObj.h"
#import "AssignmentObj.h"
#import "CategoryObj.h"
#import "ScoreObj.h"
#import "AttendanceForDate.h"
#import "DateUtils.h"
#import "SpreadsheetFieldCell.h"
#import "GRLDatabase.h"
#import "DateHeaderController.h"

@implementation GRLAttendanceDS

@synthesize data, prefs;

- (id)init
{
    self = [super init];
    if(self) {
	
	}

	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ScheduleChanged" object:self.data];
	[self.data.studentController removeObserver:self forKeyPath:@"arrangedObjects.keyByWhichObjectsAreArranged"];
	[self.prefs removeObserver:self forKeyPath:@"classDaysList"];

    [super dealloc];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCalendar:) name:@"ScheduleChanged" object:self.data];
	// watch to see if they change the sorting on the student list
	[self.data.studentController addObserver:self forKeyPath:@"arrangedObjects.keyByWhichObjectsAreArranged" options:0 context:[self.data managedObjectContext]];
	[self.prefs addObserver:self forKeyPath:@"classDaysList" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:[self.data managedObjectContext]];
	
	//[headerTableDS setMainTableView:sheetTable];
	//[sheetTable setHeaderView:headerView];
	[self refreshCalendar:self];
	[self reloadTableData];
	[self.sheetTable setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// they've changed the sorting on the student list, reload our table
	if ([object isKindOfClass:[NSArrayController class]]) {
		[self reloadTableData];
	}
	// Our class schedule has changed, we need to update our tables to reflect it
	else if ([object isKindOfClass:[DocumentPreferences class]]) {
		[self refreshCalendar:object];
		[self.headerTableDS reloadTableData];

		[self reloadTableData];
	}
	else
		// be sure to call the super implementation if the superclass implements it
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)reloadTableData
{
	[self.nameTable deselectAll:nil];

    [self resizeAssViewToFit:nil];
    [self.sheetTable reloadData];
}

- (void)resizeAssViewToFit:(NSNotification*)notif
{
	NSTableView *headerView = [self.headerTableDS headerTableView];
	NSRect rect = [self.sheetTable frame];
	NSRect assRect = [headerView frame];
    
	CGFloat width = fmax(NSWidth(rect),NSWidth([[headerView superview] frame]));
    
	[headerView setFrame:NSMakeRect(NSMinX(rect),NSMinY(assRect),width,NSHeight(assRect))];
	[headerView reloadData];
}



- (IBAction)refreshCalendar:(id)sender
{		
	NSTableColumn *col;
    	
	// REMOVE ALL TABLE COLUMNS, WITHOUT ITERATING THROUGH THE TABLE, PER SE.
	while ([self.sheetTable numberOfColumns] > 0)
		[self.sheetTable removeTableColumn:[[self.sheetTable tableColumns] objectAtIndex:0]];
						
	NSDate *today = [DateUtils today];
		
    NSInteger count = 0;
    NSInteger scrollToCol = -1;
		
	for (NSDate *day in self.prefs.classDaysList) {
		if([today isEqualToDate:day])
			scrollToCol = count;
		
		col = [[[NSTableColumn alloc] initWithIdentifier:day] autorelease];
		[col setWidth:30];
		[col setMinWidth:30];
		[col setMaxWidth:30];
		
		SpreadsheetFieldCell *cell = [[[SpreadsheetFieldCell alloc] initTextCell:@""] autorelease];
		[cell setWraps:NO];
		[cell setScrollable:NO];
		
		[cell setEditable:YES];
		[cell setControlSize:NSSmallControlSize];
		
		[cell setFont:[NSFont fontWithName:@"Lucida Grande" size:11]];
		//[cell setBordered:YES];
		[col setDataCell:cell];
		
		[self.sheetTable addTableColumn:col];
		
		count++;
	}
	
	if (scrollToCol == -1) { // make sure we've not already set it up
		if ([DateUtils isEarlier:today thanDate:[self.prefs valueForKey:@"courseBegin"]]) // today is before the beginning of the course calendar
			scrollToCol = 0;
		else // today must be after the end of the course calendar
			scrollToCol = [self.prefs.classDaysList count] - 1;
	}
	
	//[self.headerTableDS reloadTableData];

	[self.sheetTable scrollColumnToVisible:scrollToCol];
	//[self.headerTableDS.headerTableView scrollColumnToVisible:scrollToCol];
	[self.nameTable deselectAll:self];	// for some reason, it would always have the first row selected ... we don't like that.

	[self.headerTableDS.headerTableView setNeedsDisplay:YES];
	[self.sheetTable setNeedsDisplay:YES];
    
	[self resizeAssViewToFit:nil];
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[self.data.studentController arrangedObjects] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	StudentObj * stud = [[self.data.studentController arrangedObjects] objectAtIndex:rowIndex];
	AttendanceForDate *att = [stud attendanceForDate:[aTableColumn identifier]];
	NSString * value = @"";
	if (att)
		value = [att abbreviatedString];

	return value;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	StudentObj *stud = [[self.data.studentController arrangedObjects] objectAtIndex:rowIndex];
	
    NSString *str = [anObject lowercaseString];
    NSDate *date = [aTableColumn identifier];
    
    [stud setAttendanceWithString:str forDate:date];
    
	// if an assignment is due on that day, let's set the student's assignment code (late/excused/etc) right now too.
    for(AssignmentObj *ass in [[self.data assignmentController] arrangedObjects]) {
		if (![ass isAttendance]) // don't do it for the attendance records
			if([ass.dueDate isEqualTo:date])
			{
				ScoreObj *score = [stud scoreForAssignment:ass];				
				GRLCode collection = [ScoreObj codeForString:str];
				score.collectionCode = [NSNumber numberWithInteger:collection];
			}
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AttendanceChanged" object:self.data
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:stud, @"student", nil]];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self.data];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if(aTableView != (NSTableView *)sheetTable || rowIndex < 0)
        return;
	
    id identifier = [aTableColumn identifier];
    StudentObj *stud = [[[self.data studentController] arrangedObjects] objectAtIndex:rowIndex];
    
	AttendanceForDate *att = [stud attendanceForDate:identifier];
	NSColor *color = [att cellColorWithPrefs:self.prefs];	
    
    if(color)
    {
        [(NSTextFieldCell *)aCell setDrawsBackground:YES];
        [(NSTextFieldCell *)aCell setBackgroundColor:color];
    }
	else {
        [(NSTextFieldCell *)aCell setDrawsBackground:NO];
	}

}



- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return YES;
}


- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if([aNotification object] == self.sheetTable)
    {
        NSTextView *textView = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
        NSString *string = [textView string];
        
        if([string length] == 1 && [[NSApp currentEvent] keyCode] != 51)	// what's keycode 51????
        {
            NSString *concat = nil;
                
            if([string hasPrefix:@"a"])
                concat = @"b";
            else if([string hasPrefix:@"l"])
                concat = @"a";
            else if([string hasPrefix:@"e"])
                concat = @"x";
            else if([string hasPrefix:@"t"])
                concat = @"a";
                
            if(concat)
            {
                [textView insertText:concat];
                [textView setSelectedRange:NSMakeRange(1,1)];
            }
        }
    }
}
/*
- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
	return 121; // we don't really want them resizing this split view .. it's decorative ... 
}
*/
- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset
{
    return proposedMax*0.8;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
    if(proposedMin == 0)
        proposedMin = 135;
	return proposedMin;
}

@synthesize nameTable;
@synthesize headerTableDS;
@end