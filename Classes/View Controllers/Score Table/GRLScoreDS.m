//
//  GRLScoreDS.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "DocumentPreferences.h"

#import "SpreadsheetFieldCell.h"
#import "SpreadsheetTableView.h"
#import "SpreadsheetFieldEditor.h"

#import "GRLScoreDS.h"

#import "ScoreHeaderViewController.h"

#import "StudentObj.h"
#import "ScoreObj.h"
#import "AssignmentObj.h"
#import "CategoryObj.h"
#import "DateUtils.h"
#import "GRLFunction.h"

#import "LetterGradeLookup.h"
#import "GRLAttendanceDS.h"
#import "GRLDatabase.h"

@interface  GRLScoreDS (Private)
- (CGFloat)attendanceScore:(ScoreObj *)score;
- (void)attendanceChanged:(NSNotification *)not;
@end

@implementation GRLScoreDS

@synthesize attendanceColumn, prefs, data, scheduleObservations;

- (id)init
{
    self = [super init];
    if(self)
    {
		// we assume the attendance assignment is the first column if it's not set properly elsewhere.
		self.attendanceColumn = 0;	
    }
    return self;
}

- (void)dealloc
{
	// REMOVE ALL TABLE COLUMNS, WITHOUT ITERATING THROUGH THE TABLE, PER SE.
	while ([self.sheetTable numberOfColumns] > 0)
		[self.sheetTable removeTableColumn:[[self.sheetTable tableColumns] objectAtIndex:0]];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	for (NSString *key in self.scheduleObservations)
		[self.prefs removeObserver:self forKeyPath:key];
	
	self.scheduleObservations = nil;

	[self.data.studentController removeObserver:self forKeyPath:@"arrangedObjects.keyByWhichObjectsAreArranged"];
	
	//if (self.data) self.data = nil;
	[super dealloc];
}

- (void) awakeFromNib
{
	// REMOVE ALL TABLE COLUMNS, WITHOUT ITERATING THROUGH THE TABLE, PER SE.
	while ([self.sheetTable numberOfColumns] > 0)
		[self.sheetTable removeTableColumn:[[self.sheetTable tableColumns] objectAtIndex:0]];
		
	//self.data = base;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTableColumn:) 
												 name:@"GRLAssignmentCreated" object:self.data];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTableColumn:) 
												 name:@"GRLAssignmentRemoved" object:self.data];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeAssViewToFit) 
												 name:NSWindowDidResizeNotification object:[self.sheetTable window]];	
	
	// listen to see whenever someone changes the attendance record for a student
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attendanceChanged:) name:@"AttendanceChanged" object:self.data];
	
	NSArray *specialKeys = [NSArray arrayWithObjects:@"tardyPenalty", @"absentPenalty", @"latePenalty", @"tardiesForAbsence", @"excludedClassDays",nil];
	self.scheduleObservations = [specialKeys arrayByAddingObjectsFromArray:[self.prefs scheduleKeys]];
	for (NSString *key in self.scheduleObservations)
		[self.prefs addObserver:self
						   forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:[self.data managedObjectContext]];
	
	// watch to see if they change the sorting on the student list
	[self.data.studentController addObserver:self forKeyPath:@"arrangedObjects.keyByWhichObjectsAreArranged" options:0 context:[self.data managedObjectContext]];
	
	//[self.attendanceDS refreshCalendar:self];
	[self refreshFinalScores:self]; // do this initially.
	[self reloadTableData];
}

// Key-Value Observations ... we're listening to see if we need to reload our grade data.
//		Note: This is not for global notification center observations, those hit specific methods below (like attendanceChanged:)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// Someone's changed some of our preferences that we care about ... recompute final grades
	if ([object isKindOfClass:[DocumentPreferences class]]) {
		[self refreshFinalScores:self.prefs];		
	}		
	// they've changed the sorting on the student list, reload our data
	else if ([object isKindOfClass:[NSArrayController class]]) {
		[self reloadTableData];
	}
	else
		// be sure to call the super implementation if the superclass implements it
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}



#pragma mark Attendance Score

- (void)reloadTableData
{	
	[self resizeAssViewToFit];
	[self.sheetTable reloadData];
	[self.nameTable reloadData];	
	//[self.sheetTable setNeedsDisplay:YES];
	//[self.nameTable setNeedsDisplay:YES];	
}

- (void)resizeAssViewToFit
{
	NSTableView *headerView = [headerTableDS headerTableView];
	NSRect rect = [sheetTable frame];
	NSRect assRect = [headerView frame];		
	CGFloat width = fmax(NSWidth(rect),NSWidth([[headerView superview] frame]));
    
	[headerView setFrame:NSMakeRect(NSMinX(rect),NSMinY(assRect),width,NSHeight(assRect))];
	//[headerView setRowHeight:NSHeight([[headerView superview ]frame])];
	//[headerView setNeedsDisplay:YES];
	[headerView reloadData];
}


- (void)attendanceChanged:(NSNotification *)not
{	
	// we assume the attendance assignment is the first column if it's not set properly elsewhere.

	StudentObj * student = [[not userInfo] objectForKey:@"student"];
	NSArray *studs = [data.studentController arrangedObjects];
	if (studs && [studs count]) {
		NSInteger rowIndex = [studs indexOfObject:student];
		NSCell *attendCell = [self.sheetTable preparedCellAtColumn:attendanceColumn row:rowIndex];
		[self.sheetTable updateCell:attendCell];
		
		[self.sheetTable reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] 
								   columnIndexes:[NSIndexSet indexSetWithIndex:attendanceColumn]];
	}
}



#pragma mark Final Grade
- (void)refreshFinalScores:(id)sender
{    
    if (!self.data || !self.data.studentController) {
		NSLog(@"ERROR: ScoreDS-calculateFinalScores -- No database object and/or student array.");
		return;
	}
	for(StudentObj *stud in [self.data.studentController arrangedObjects])
		[stud refreshGradeTotal:self];
}


// Use this when you don't already have a Cell (for it's representedObject) or can't get to it easily.
- (ScoreObj *)scoreObjForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	ScoreObj *score = nil;
	
	id colID = [aTableColumn identifier];
	@try {
		AssignmentObj * ass = (AssignmentObj *)[data.managedObjectContext objectWithID:colID];
		NSArray *studs = [data.studentController arrangedObjects];
		if (studs && [studs count] > rowIndex) {
			StudentObj *stud = [studs objectAtIndex:rowIndex];
			score = [stud scoreForAssignment:ass];
		}
		else {
			NSLog(@"Error in ScoreDS:scoreObjForTableColumn - Row: %ld - Col: %ld - ColumnID: %@  ", rowIndex, [self.sheetTable columnWithIdentifier:colID], colID);
		}
	}
	@catch (NSException * e) {
		NSLog(@"Error in ScoreDS:scoreObjForTableColumn - Row: %ld - Col: %ld - ColumnID: %@  ", rowIndex, [self.sheetTable columnWithIdentifier:colID], colID);
	}
	return score;
}

#pragma mark TableView methods
- (void)addTableColumn:(NSNotification *)not
{	
	// This "code" gets our objectID for the assignments and stores it in the identifier for the column
	id code = [[not userInfo] objectForKey:@"code"];
	
	// first let's make sure we don't already have one...!!!! (stupid core data notifications pissing me off with duplicates!)
    NSTableColumn *column = [self.sheetTable tableColumnWithIdentifier:code];
	if (!column) {
		column = [[[NSTableColumn alloc] initWithIdentifier:code] autorelease];
		[column setMaxWidth:30];
		[column setWidth:30];
		[column setWidth:30];
		
		[self.sheetTable addTableColumn:column];
	}
	[self reloadTableData];
}

- (void)removeTableColumn:(NSNotification *)not
{
    id code = [[not userInfo] objectForKey:@"code"];
    NSTableColumn *column = [self.sheetTable tableColumnWithIdentifier:code];
	if (column) {
		[self.sheetTable removeTableColumn:column];
	}
	[self reloadTableData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{	
    return [[data.studentController arrangedObjects] count];
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if(rowIndex < 0)
        return nil;
		
	if (aTableView == self.sheetTable)
	{
		NSString *valString = @"";

		NSInteger colIndex = [aTableView columnWithIdentifier:[aTableColumn identifier]];	
		ScoreObj *score = [self scoreObjForTableColumn:aTableColumn row:rowIndex];
		
		if (score) {
			NSDictionary *dict = [score calculateAssignmentScoreWithPrefs:self.prefs];
			
			// if we're editing this cell, we always show the raw score
			if([self.sheetTable editedRow]==rowIndex && [self.sheetTable editedColumn]==colIndex)
				valString = [dict objectForKey:@"raw"];
			else
			{
				valString = [dict objectForKey:@"curved"];
				if(!valString || ![[self.prefs valueForKey:@"displayScoresWithCurve"]boolValue])
					valString = [dict objectForKey:@"raw"];
			}
			
		}
		return valString;
	}		
	return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{	
    if(rowIndex < 0)
        return;
	
	//NSInteger colIndex = [aTableView columnWithIdentifier:[aTableColumn identifier]];	
	ScoreObj *score = [self scoreObjForTableColumn:aTableColumn row:rowIndex];

	if (score) {
		AssignmentObj *ass = score.assignment;
		
		if(![anObject isEqualToString:@""])
		{
			score.score = [NSNumber numberWithFloat:[anObject floatValue]];
			if([[self.prefs valueForKey:@"beepForScoresExceedingMax"]boolValue] && [ass.maxPoints integerValue] != 0 && [anObject floatValue] > [ass.maxPoints floatValue])
				NSBeep();
		}
		else
			score.score = [NSNumber numberWithInteger:NSNotFound];
		
		if(!score.collectionDate && ![anObject isEqualToString:@""])
			score.collectionDate = [DateUtils today];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:data];
		
	}
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
	if (tableView != self.sheetTable || tableColumn == nil)  // we always get asked for this first.  If we give it anything but nil, it assumes its for the whole row
		return nil; 
		
	SpreadsheetFieldCell *cell = [[[SpreadsheetFieldCell alloc] initTextCell:@""] autorelease];
	[cell setWraps:NO];
	[cell setScrollable:NO];		
	[cell setEditable:YES];
	[cell setControlSize:NSSmallControlSize];
	[cell setBordered:NO];
	
	ScoreObj *score = [self scoreObjForTableColumn:tableColumn row:rowIndex];
	[cell setRepresentedObject:score];
	
	if ([score.assignment isAttendance]) {// it's an attendance category ... no editing, disable
		[cell setFont:[NSFont fontWithName:@"Cambria-Italic" size:11]];
		[cell setEnabled:NO];
		self.attendanceColumn = [tableView columnWithIdentifier:[tableColumn identifier]];	
		//[cell setContinuous:YES];	//GREG REVERSE CHANGES>>>>>???
	}
	else {
		[cell setFont:[NSFont fontWithName:@"Lucida Grande" size:11]];
		[cell setEnabled:YES];
	}
		
	return cell;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if(aTableView != (NSTableView *)self.sheetTable || rowIndex < 0)
		return;
	
	ScoreObj *score = [aCell representedObject];
	if (!score) // sometimes we don't get a represented object, so lets grab the score manually
		score = [self scoreObjForTableColumn:aTableColumn row:rowIndex];
	
    NSColor *color = [score cellColorWithPrefs:self.prefs];
        
    if(color)
    {
        [aCell setDrawsBackground:YES];
        [aCell setBackgroundColor:color];
    }
	else {
        [aCell setDrawsBackground:NO];
	}
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if(aTableView != (NSTableView *)self.sheetTable)
		return NO;
		
	NSInteger colIndex = [aTableView columnWithIdentifier:[aTableColumn identifier]];	
	
	if(rowIndex != -1 && colIndex != -1)
	{		

		NSCell *aCell = [aTableView preparedCellAtColumn:colIndex row:rowIndex];
		ScoreObj *score = [aCell representedObject];
		if (!score) // sometimes we don't get a represented object, so lets grab the score manually
			score = [self scoreObjForTableColumn:aTableColumn row:rowIndex];
				
		AssignmentObj *ass = score.assignment;
				
		[data.scoreController setSelectedObjects:[NSArray arrayWithObject:score]];
		 
		if ([ass isAttendance]) {
			return NO; // Attendance is automatically calculated ... no editing allowed...
		}
		
		// Did someone actually set a collection date?		
		if(score.collectionDate)
		{
			NSDate *date = [score.collectionDate beginningOfDay];
			NSDate *today = [DateUtils today];
			NSDate * yesterday = [DateUtils yesterday];	// go back 1 day
			
			if([date isEqualToDate:today])
				[dateForAss selectItemAtIndex:0];
			else if([date isEqualToDate:yesterday])
				[dateForAss selectItemAtIndex:1];
			else
			{
				NSString *dateString = [DateUtils dateAsHeaderString:date];
				if([dateForAss indexOfItemWithTitle:dateString] == -1)
					[dateForAss insertItemWithTitle:dateString atIndex:2];
				
				[dateForAss selectItemWithTitle:dateString];
				[[dateForAss itemAtIndex:2] setTarget:self];
				[[dateForAss itemAtIndex:2] setAction:@selector(dateChanged:)];
			}
			
		}
		else	// when entering grades, we default to collecting the assignments "Today"
			[dateForAss selectItemAtIndex:0]; 
		
		[dateForAss setNeedsDisplay:YES];
				
	}
	
	return YES;
}


#pragma mark Collection Codes and Dates
- (IBAction)codeChanged:(id)sender
{
	ScoreObj *score = nil; // = [[data.scoreController selectedObjects] objectAtIndex:0];
    
	for (score in [data.scoreController selectedObjects]) {		
		[score.student refreshGradeTotal:self];		
		
		if (score == [[data.scoreController selectedObjects] objectAtIndex:0]) { // if we're first 
			NSInteger colIndex = [self.sheetTable columnWithIdentifier:[score.assignment objectID]];	
			NSInteger rowIndex = [[self.data.studentController arrangedObjects] indexOfObject:score.student];	
			[self.sheetTable editColumn:colIndex row:rowIndex withEvent:nil select:YES];
			//[self.myFieldEditor doEditCellInTable:self.sheetTable column:colIndex row:rowIndex];
		}

    }
	[self.sheetTable setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:data];
}


- (IBAction)dateChanged:(id)sender
{	
    NSString *title = [sender title];
    NSDate *date = [NSDate dateWithNaturalLanguageString:title];
    
	ScoreObj *score = nil; // = [[data.scoreController selectedObjects] objectAtIndex:0];
    
	for (score in [data.scoreController selectedObjects]) {		
		score.collectionDate = date;

		if (score == [[data.scoreController selectedObjects] objectAtIndex:0]) { // if we're first 
			NSInteger colIndex = [self.sheetTable columnWithIdentifier:[score.assignment objectID]];	
			NSInteger rowIndex = [[self.data.studentController arrangedObjects] indexOfObject:score.student];	
			[self.sheetTable editColumn:colIndex row:rowIndex withEvent:nil select:YES];
			//[self.myFieldEditor doEditCellInTable:self.sheetTable column:colIndex row:rowIndex];
		}
	}
	[self.sheetTable setNeedsDisplay:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:data];
}

- (IBAction)newDate:(id)sender
{
    //run a sheet, get a date (different than today or yesterday, plz!)
    //add it to dateForAss pop up button in @"%a %m/%d/%y" form
    [NSApp beginSheet:dateSheet modalForWindow:[self.sheetTable window] modalDelegate: nil didEndSelector:nil contextInfo:nil];
    
    while([NSApp runModalForWindow:dateSheet] == NSOKButton)
    {
        NSDate *date = [dateField dateValue];
        
        NSString *dateString = [DateUtils dateAsHeaderString:date];
        NSDate *today = [DateUtils today];
        NSDate *yesterday = [DateUtils yesterday];
        
        if(!date || [date isEqualToDate:today] || [date isEqualToDate:yesterday])
            NSBeep();
        else
        {
            [dateForAss insertItemWithTitle:dateString atIndex:[[dateForAss itemArray] count] - 1];
            [dateForAss selectItemWithTitle:dateString];
            [self dateChanged:[dateForAss itemWithTitle:dateString]];
            break;
        }
    }
    
    [NSApp endSheet: dateSheet];
    [dateSheet orderOut: self];
}

- (IBAction)confirmDate:(id)sender
{
    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)cancelDate:(id)sender
{
    [NSApp stopModalWithCode:NSCancelButton];
}

#pragma mark Split View Dimensions
- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset
{
    return proposedMax*0.6;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
    if(proposedMin == 0)
        proposedMin = 174;
	return proposedMin;
}


@synthesize nameTable;
@synthesize headerTableDS;
@synthesize codeForAss;
@synthesize dateForAss;
@synthesize dateSheet;
@synthesize dateField;
@synthesize letterGrades;
@synthesize attendanceDS;
@end
