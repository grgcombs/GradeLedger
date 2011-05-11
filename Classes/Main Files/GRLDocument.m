//
//  GRLDocument.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLDocument.h"
#import "GRLDocumentController.h"
#import "DocumentPreferences.h"

#import "CategoryObj.h"
#import "StudentObj.h"
#import "ScoreObj.h"
#import "StudentAttributes.h"
#import "AssignmentObj.h"

#import "GRLScoreDS.h"
#import "GRLDatabase.h"
#import "ScoreHeaderViewController.h"
#import "GRLAttendanceDS.h"

#import "GRLPrinter.h"
#import "GRLAttendancePrinter.h"
#import "GRLExporter.h"
#import "GRLAttendanceExporter.h"

#import "GRLPasswordProtect.h"
#import "GRLNotificationManager.h"
#import "GRLStatController.h"
#import "GRLPrintHeaderController.h"
#import "GRLStudentEmailer.h"
#import "GRLZeroer.h"
#import "JSONKit.h"

@interface GRLDocument (Private)

- (void)savePreferencesData;

@end


@implementation GRLDocument

NSString *StudentsPBoardType =		@"StudentsPBoardType";
NSString *StudAttribsPBoardType =	@"StudAttribsPBoardType";
NSString *CategoriesPBoardType =	@"CategoriesPBoardType";
NSString *AssignmentsPBoardType =	@"AssignmentsPBoardType";
NSString *ScoresPBoardType =		@"ScoresPBoardType";


@synthesize preferences = _preferences;

- (id)init
{
    if (!(self = [super init])) return nil;
		
	if (![self hasUndoManager])
		[self setUndoManager:[[self managedObjectContext] undoManager]];
		
	docWindow = nil;
	
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
		
    return self;
}

- (void)dealloc
{
    if (docWindow) [docWindow release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

- (NSString *)windowNibName
{
    return NSStringFromClass([self class]);
}

// HANDLE COPY AND PASTE IN VARIOUS TAB VIEWS (RIGHT NOW JUST STUDENT VIEW)

- (void)copy:sender {
	NSArray *selectedObjects = nil;
	NSString *pboardType = nil;
	
	NSInteger selectedTab = [[[mainTabView selectedTabViewItem] identifier] integerValue];
	switch (selectedTab) {
		case kTabViewStudents:
			selectedObjects = [data.studentController selectedObjects];
			pboardType = StudentsPBoardType;
			break;
		default:
			break;
	} 
	
		
	NSUInteger count = [selectedObjects count];
	if (count == 0) {
		return;
	}
	
	NSMutableArray *copyObjectsArray = [NSMutableArray arrayWithCapacity:count];
	NSMutableArray *copyStringsArray = [NSMutableArray arrayWithCapacity:count];
	
	for (id object in selectedObjects) {
		[copyObjectsArray addObject:[object dictionaryRepresentation]];
		[copyStringsArray addObject:[object stringDescription]];
	}
	
	NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
	[generalPasteboard declareTypes:
	 [NSArray arrayWithObjects:pboardType, NSStringPboardType, nil]
							  owner:self];
	NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:copyObjectsArray];
	[generalPasteboard setData:copyData forType:pboardType];
	[generalPasteboard setString:[copyStringsArray componentsJoinedByString:@"\n"]
						 forType:NSStringPboardType];
}

- (void)paste:sender {
 	NSInteger selectedTab = [[[mainTabView selectedTabViewItem] identifier] integerValue];
	if (selectedTab == kTabViewStudents) {
		NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
		NSData *studentData = [generalPasteboard dataForType:StudentsPBoardType];
		if (studentData == nil) {
			return;
		}
		NSArray *studentsArray = [NSKeyedUnarchiver unarchiveObjectWithData:studentData];
		NSManagedObjectContext *moc = [self managedObjectContext];
		for (NSDictionary *studentDictionary in studentsArray) {
			StudentObj *newStudent;
			newStudent = (StudentObj *)[NSEntityDescription insertNewObjectForEntityForName:@"StudentObj"
																	inManagedObjectContext:moc];
			[newStudent setValuesForKeysWithDictionary:studentDictionary];
		}
	}
}

- (void)cut:sender {
    [self copy:sender];
 	NSInteger selectedTab = [[[mainTabView selectedTabViewItem] identifier] integerValue];
	if (selectedTab == kTabViewStudents) {

		NSArray *selectedStudents = [data.studentController selectedObjects];
		if ([selectedStudents count] == 0) {
			return;
		}
		NSManagedObjectContext *moc = [self managedObjectContext];
		
		for (StudentObj *student in selectedStudents) {
			[moc deleteObject:student];
		}
	}
}




- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];

	[aController setShouldCascadeWindows:NO];

	docWindow = [[aController window] retain];
	
	if (![self managedObjectContext]) 
		NSLog(@"%@:%s Core Data Context is nil", [self class], (char *)_cmd);
	
	
	/*
	 ****** For Testing Purposes: This deletes all our saved preferences from the document ********
	 
	for (NSManagedObject *param in [[self preferences] allRealParameters]) {
		//NSString *name = [param valueForKey:@"name" ];
		[[self managedObjectContext] deleteObject:param];
	}
	*/
	
	
	//******************** START:READING NEW PREFERENCES	 
	
	NSString *password = [[self preferences] valueForKey:@"password"];
	[passwordProtector setPassword:password];
	if(password != nil && [password length] && ![passwordProtector checkIfPasswordIsValid])
	{
		[aController close];
		[aController setWindow:nil];
		return;
	}
	
	[docWindow setFrame:NSRectFromString([[self preferences] valueForKey:@"document_frame"]) display:NO];
	notManager.notificationData = [NSKeyedUnarchiver unarchiveObjectWithData:[[self preferences] valueForKey:@"notificationData"]];
	[attPrinter setPrintingSettings:[NSKeyedUnarchiver unarchiveObjectWithData:[[self preferences] valueForKey:@"attendancePrinterSettings"]]];
	[attExporter setExportingSettings:[NSKeyedUnarchiver unarchiveObjectWithData:[[self preferences] valueForKey:@"attendanceExporterSettings"]]];
	[printer setPrintingSettings:[NSKeyedUnarchiver unarchiveObjectWithData:[[self preferences] valueForKey:@"printerSettings"]]];
	[exporter setExportingSettings:[NSKeyedUnarchiver unarchiveObjectWithData:[[self preferences] valueForKey:@"exportingSettings"]]];
	
	//********************* END:READING NEW PREFERENCES

	[self performSelector:@selector(finalizeShit:) withObject:nil afterDelay:2];
		
}

- (void)finalizeShit:(id)sender {
	for (AssignmentObj * ass in [data allAssignmentsSortedByDueDate]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLAssignmentCreated" object:data 
														  userInfo:[NSDictionary dictionaryWithObject:[ass objectID] forKey:@"code"]]; 
		// "code" is used all over to "efficiently" identify these assignments by their managedObjectID
	}
	
	[attDS reloadTableData];
	[scoreDS reloadTableData];
	[assHead reloadTableData];
	
}
- (void)awakeFromNib {
	[super awakeFromNib];
	
	// If someone says they've created a student, we need to make sure our core data-backed arrays get updated.
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(documentEdited:) 
												 name:@"GRLDocumentEdited" object:data];
	
}



- (void)saveToURL:(NSURL *)absoluteURL 
		   ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation 
		 delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo
{

	[self savePreferencesData];
	
	[data prepareForSaveOperation:self];
	
	[super saveToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation 
			delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
	[(GRLDocumentController *)[NSDocumentController sharedDocumentController] newClassCreated:absoluteURL];
}


- (void)documentEdited:(NSNotification *)notif
{	
    [self updateChangeCount:NSChangeDone];
	[scoreDS reloadTableData];
}

- (IBAction)scheduleChanged:(id) sender {
	[self.preferences validateCourseBegin];
	[self.preferences validateCourseEnd];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"ScheduleChanged" object:data
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:sender, @"sender", nil]];
}


- (void)printDocument:(id)sender
{
    if([[data.studentController arrangedObjects] count])
    {
        NSInteger tag = [sender tag];
        if(tag == 0)
            [printer runGradeReportPrintDialogue];
        else if(tag == 2)
            [attPrinter runAttendanceReportPrintDialogue];
    }
    else {
        NSRunAlertPanel(@"Print Error", @"You need to have at least one student to print.",nil,nil,nil);
	}
}

- (IBAction)importStudentsFromFile:(NSString *)path {
	if (!path)
		return;
	NSError *error = nil;
	NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	if (!jsonString || ![jsonString length])
		return;
	
	NSArray *studsList = [jsonString objectFromJSONString];
	if (studsList && [studsList count]) {
		for (NSDictionary *studDict in studsList) {
			StudentObj *student = [StudentObj insertNewStudentWithContext:[self managedObjectContext]];
			[student setValuesForKeysWithDictionary:studDict];
		}
		//[[self managedObjectContext] save:nil];
	}
}

- (IBAction)importDoc:(id)sender
{
    NSInteger tag = [sender tag];
	
    int result;
    NSArray *fileTypes = [NSArray arrayWithObject:@"json"];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	
    [oPanel setAllowsMultipleSelection:NO];
    result = [oPanel runModalForDirectory:NSHomeDirectory()
									 file:nil types:fileTypes];
    if (result == NSOKButton) {
        NSArray *filesToOpen = [oPanel filenames];
		if ([filesToOpen count]) {
			NSString *aFile = [filesToOpen objectAtIndex:0];
			if (aFile && [aFile length]) {
				switch (tag) {
					case 7000:
						[self importStudentsFromFile:aFile];
						break;
					default:
						break;
				}
			}
		}
    }
}

- (void)exportToHTML:(id)sender
{
    NSInteger tag = [sender tag];

    if([[data.studentController arrangedObjects] count] && (tag != 0 || (tag == 0 && [[data.assignmentController arrangedObjects] count])))
    {
        if(tag == 0)
            [exporter exportToHTML:nil];
        else if(tag == 2)
            [attExporter exportToHTML];
    }
    else
        NSRunAlertPanel(@"Export Error",
                        @"You need to have at least one student and one assignment to export.",
                        nil,
                        nil,
                        nil);

/* GREG, maybe do something like this...
 [NSApp presentError:[NSError errorWithDomain:@"CocoaRecipesDomain" code:0 userInfo:
						 [NSDictionary dictionaryWithObjectsAndKeys:@"Couldn't find the resource for editing SmartGroups.",
						  NSLocalizedDescriptionKey, @"Try reinstalling CoreRecipes", NSLocalizedRecoverySuggestionErrorKey, nil]]];
	
*/	
}

// They selected the menu item to create or change their password, let's get run the tool to handle that, then store the results
- (void)setOrChangePassword:(id)sender
{
	NSString *newPassword = [passwordProtector setOrChangePassword];
	if(newPassword)
		[[self preferences] setValue:newPassword forKey:@"password"];
}

- (void)showNotificationManager:(id)sender
{
    [notManager showNotifications];
}

- (void)showNotificationLog:(id)sender
{
    [notManager showLog];
}

- (void)showStatistics:(id)sender
{
    [statController runStatsSheet];
}

- (void)toggleNotesDrawer:(id)sender
{
    [[[docWindow drawers] objectAtIndex:0] toggle:nil];
}

- (void)showPrintHeader:(id)sender
{
    [headerController editHeader:sender];
}


- (void)showWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.github.com/grgcombs/GradeLedger"]];
}

- (void)showStudentEmailer:(id)sender
{
    [studentEmailer showEmailer:nil];
}

- (void)zeroAllBlankScores:(id)sender
{
    [zeroer zeroAllBlankScores];
    [scoreDS reloadTableData];
    [self documentEdited:nil];
}

- (void)zeroAllLateBlankScores:(id)sender
{
    [zeroer zeroAllLateBlankScores];
    [scoreDS reloadTableData];
    [self documentEdited:nil];
}

- (BOOL)keepBackupFile
{
	return YES;
}


 - (void)savePreferencesData
 {	
	 [[self preferences] setValue:NSStringFromRect([docWindow frame]) forKey:@"document_frame"];
	 [[self preferences] setValue:[NSKeyedArchiver archivedDataWithRootObject:notManager.notificationData] forKey:@"notificationData"];
	 [[self preferences] setValue:[NSKeyedArchiver archivedDataWithRootObject:[attPrinter printingSettings]] forKey:@"attendancePrinterSettings"]; 
	 [[self preferences] setValue:[NSKeyedArchiver archivedDataWithRootObject:[attExporter exportingSettings]] forKey:@"attendanceExporterSettings"];
	 [[self preferences] setValue:[NSKeyedArchiver archivedDataWithRootObject:[printer printingSettings]] forKey:@"printerSettings"];
	 [[self preferences] setValue:[NSKeyedArchiver archivedDataWithRootObject:[exporter exportingSettings]] forKey:@"exportingSettings"];	 
 }
 

#pragma mark -
#pragma mark Synthethized Properties


@synthesize scoreDS;
@synthesize assHead;
@synthesize attDS;
@synthesize printer;
@synthesize attPrinter;
@synthesize exporter;
@synthesize attExporter;
@synthesize passwordProtector;
@synthesize notManager;
@synthesize statController;
@synthesize headerController;
@synthesize studentEmailer;
@synthesize zeroer;
@synthesize data;
@synthesize docWindow;
@end
