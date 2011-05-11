//
//  GRLDatabase.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLDatabase.h"
#import "GRLDocument.h"

#import "DocumentPreferences.h"
#import "GRLDefines.h"
#import "CategoryObj.h"
#import "AssignmentObj.h"
#import "StudentObj.h"
#import "JSONKit.h"

@implementation GRLDatabase

@synthesize categoryController;
@synthesize assignmentController;
@synthesize studentController;
@synthesize studAttribController;
@synthesize scoreController;
@synthesize sortByStudentNameDesc, sortByNameDesc, sortByDueDateDesc, sortByAttendDateDesc;
@synthesize preferences;
@synthesize _associatedDocument;

- (id)init {
    if((self = [super init])) {
		//preferences = nil;	
		NSSortDescriptor *nameInitialSortOrder = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
		NSSortDescriptor *firstDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
		self.sortByStudentNameDesc = [NSArray arrayWithObjects:nameInitialSortOrder, firstDescriptor, nil];
		self.sortByNameDesc = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
		self.sortByDueDateDesc = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dueDate" ascending:YES]];
		self.sortByAttendDateDesc = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
	}
	return self;	
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	
	[studentController setSortDescriptors:self.sortByStudentNameDesc];
	[categoryController setSortDescriptors:self.sortByNameDesc];
	[assignmentController setSortDescriptors:self.sortByDueDateDesc];
	[studAttribController setSortDescriptors:self.sortByNameDesc];
		//[studentController setPreservesSelection:YES];
		//[studentController setSelectsInsertedObjects:YES];
	
	[studentController fetch:self];
	[categoryController fetch:self];
	[assignmentController fetch:self];
	[studAttribController fetch:self];
	[scoreController fetch:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(objectsDidChange:) 
												 name:NSManagedObjectContextObjectsDidChangeNotification 
											   object:_associatedDocument.manObjContext];		
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.sortByStudentNameDesc = nil;
	self.sortByNameDesc = nil;
	self.sortByDueDateDesc = nil;
	self.sortByAttendDateDesc = nil;
	
	[super dealloc];
}

- (NSManagedObjectContext *)managedObjectContext {
	return _associatedDocument.manObjContext;
}

- (BOOL) hasExistingAttendanceCat {
	return [self hasExistingAttendanceCatExcluding:nil];
}

- (BOOL) hasExistingAttendanceCatExcluding:(CategoryObj*)thisCat {	
	// NSInteger isThisAttendance:  = thisCat.treatment == Attendance
	// NSInteger countAttendanceCats = categories.(treatment == "Attendance").@count
	// return countAttendanceCats - isThisAttendance > 0; // if we still have other attendances out there, besides this one
	
	NSInteger count = 0;
	NSArray *cats = [self.categoryController arrangedObjects];
	for (CategoryObj* cat in cats) {
		if ([cat isAttendance]){
			count++;
		}
	}
	if (thisCat && [thisCat isAttendance])
		count--;
	
	return count > 0;
}

/*	
		GREG -- really, we should make sure there isn't already a category with attendance treatment.
		It's illogical to have more than one attendance category, since it's already the *whole* record for the semester
 */

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {	
	if ([[[menuItem menu] title] isEqualToString:@"TreatmentsMenu"]) {
		NSInteger menuIndex = [menuItem tag];
		
		// if this menu item is for Attendance tag, and we're the selected menu item, stay enabled, otherwise, don't
		if (menuIndex == GRLTreatAttend) {
			if (![menuItem state])						// if we're not the one currently selected, disable us
				return ([self hasExistingAttendanceCat] == NO);
		}
	}
	else if ([[[menuItem menu] title] isEqualToString:@"CategoriesMenu"]) {
		CategoryObj *cat = [menuItem representedObject];
		return [[cat canAddAssignment] boolValue];
	}
	
    return YES;
		
}

- (IBAction)changeCategoryPopup:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self];
	return;
	/*
    if(![sender isKindOfClass:[NSMenuItem class]]) // just double checking
		return;
	
	CategoryObj *cat = [[categoryController selectedObjects] objectAtIndex:0];		// should only have one selected now anyway
	[cat setTreatment:[sender title]];	// this should eventually be something we can localize ... prefer to go off tags and indices, not strings
	[[self managedObjectContext] processPendingChanges];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GRLDocumentEdited" object:self];
	[categoryTable reloadData];
	 */
}

- (void)prepareForSaveOperation:(id)sender {
	NSArray *asses = [self.assignmentController arrangedObjects];
	for (AssignmentObj *ass in asses) {
		if (!ass.category || [[NSNull null] isEqual:ass.category]) {
			[self.assignmentController removeObject:ass];
				//[_associatedDocument.manObjContext deleteObject:ass];
		}
	}
	/*
	if ([m_allStudentsSortedByName count]) {
		NSMutableArray *studExports = [[NSMutableArray alloc] init];
		for (StudentObj *stud in m_allStudentsSortedByName) {
			[studExports addObject:[stud exportDictionary]];
		}
		NSString *json = [studExports JSONString];
		[json writeToFile:@"/Users/greg/Desktop/output.json" atomically:YES];
		[studExports release];
	}
	 */
}

- (void)objectsDidChange:(NSNotification *)note
{
			
    NSSet *insertedObjects = [_associatedDocument.manObjContext insertedObjects];
    NSSet *updatedObjects  = [_associatedDocument.manObjContext updatedObjects];
    NSSet *deletedObjects  = [_associatedDocument.manObjContext deletedObjects];
	BOOL arrangedAssignments = NO;
	BOOL arrangedStudents = NO;
	BOOL arrangedCategories = NO;
		
	NSMutableSet *allChanged = [[NSMutableSet alloc] init];
	if (insertedObjects && [insertedObjects count])
		[allChanged unionSet:insertedObjects];
	if (updatedObjects && [updatedObjects count])
		[allChanged unionSet:updatedObjects];
	if (deletedObjects && [deletedObjects count])
		[allChanged unionSet:deletedObjects];

	
	for (NSManagedObject* object in allChanged) {	// we've added a new object, find out what and notify others
		NSString *name = nil;
		NSString *duty = nil;
		
		if ([object isKindOfClass:[AssignmentObj class]]) {
			name = @"Assignment";
			if (arrangedAssignments == NO) {
				[assignmentController rearrangeObjects];
				arrangedAssignments = YES;
			}
		}
		else if ([object isKindOfClass:[CategoryObj class]]) {
			name = @"Category";
			if (arrangedCategories == NO) {
				[categoryController rearrangeObjects];
				arrangedCategories = YES;
			}
		}
		else if ([object isKindOfClass:[StudentObj class]]) {
			name = @"Student";
			if (arrangedStudents == NO) {
				[studentController rearrangeObjects];
				arrangedStudents = YES;
			}
		}
				
		if ([insertedObjects containsObject:object]) {
			duty = @"Created";
		}
		else if ([updatedObjects containsObject:object]) {
			duty = @"Updated";
		}
		else if ([deletedObjects containsObject:object]) {
			duty = @"Removed";
		}
		
		if (name && duty) {
			NSString *notifName = [[NSString alloc] initWithFormat:@"GRL%@%@", name, duty];
			NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[object objectID], @"code", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:notifName 
																	object:self 
																  userInfo:userInfo];
			[userInfo release];
			[notifName release];
		}
	}

	[allChanged release];
}

- (NSArray*)allStudentsSortedByName {
	NSArray *temp = [self.studentController arrangedObjects];
	return temp;
}
- (NSArray*)allCategoriesSortedByName {
	NSArray *temp = [self.categoryController arrangedObjects];
	return temp;
}

- (NSArray*)allAssignmentsSortedByDueDate {
	NSArray *temp = [self.assignmentController arrangedObjects];
	return temp;
}

@end
