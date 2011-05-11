//
//  GRLDatabase.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

@class CategoryObj;
@class DocumentPreferences;
@class GRLDocument;

@interface GRLDatabase : NSObject 
{
	IBOutlet NSArrayController *categoryController;
	IBOutlet NSArrayController *assignmentController;
	IBOutlet NSArrayController *studentController;
	IBOutlet NSArrayController *studAttribController;
	IBOutlet NSArrayController *scoreController;
	
	IBOutlet NSTableView * categoryTable;
	
	IBOutlet NSArray *sortByStudentNameDesc;
	IBOutlet NSArray *sortByNameDesc;
	IBOutlet NSArray *sortByDueDateDesc;
	IBOutlet NSArray *sortByAttendDateDesc;

	IBOutlet NSManagedObjectContext *managedObjectContext;
	
		//NSMutableArray* m_allCategoriesSortedByName;
		//NSMutableArray* m_allStudentsSortedByName;
		//NSMutableArray* m_allAssignmentsSortedByDueDate;
	
	IBOutlet GRLDocument *_associatedDocument;

	IBOutlet DocumentPreferences *preferences;
}


// GREG'S CORE DATA STUFF STARTS HERE AGAIN
@property (nonatomic, assign)  NSArrayController *categoryController;
@property (nonatomic, assign)  NSArrayController *assignmentController;
@property (nonatomic, assign)  NSArrayController *studentController;
@property (nonatomic, assign)  NSArrayController *studAttribController;
@property (nonatomic, assign)  NSArrayController *scoreController;
@property (nonatomic, assign)  NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign)  DocumentPreferences *preferences;
@property (nonatomic, assign)  GRLDocument *_associatedDocument;

@property (nonatomic, copy)	NSArray *sortByStudentNameDesc;
@property (nonatomic, copy)	NSArray *sortByNameDesc;
@property (nonatomic, copy)	NSArray *sortByDueDateDesc;
@property (nonatomic, copy)	NSArray *sortByAttendDateDesc;
@property (nonatomic, readonly)  NSArray *allCategoriesSortedByName;
@property (nonatomic, readonly)  NSArray *allStudentsSortedByName;
@property (nonatomic, readonly)  NSArray *allAssignmentsSortedByDueDate;

- (IBAction)changeCategoryPopup:(id)sender;

- (BOOL) hasExistingAttendanceCatExcluding:(CategoryObj*)thisCat;
- (BOOL) hasExistingAttendanceCat;

- (void)objectsDidChange:(NSNotification *)note;
- (void)prepareForSaveOperation:(id)sender;

@end



