//
//  GRLScoreDS.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//


@class AssignmentObj, CategoryObj, StudentObj, ScoreObj;
@class ScoreHeaderViewController;
@class GRLAttendanceDS, LetterGradeLookup;
@class GRLDatabase, DocumentPreferences;

#import "SpreadsheetDataSource.h"

@interface GRLScoreDS : SpreadsheetDataSource 
{
    IBOutlet NSTableView *nameTable;
    
    IBOutlet ScoreHeaderViewController *headerTableDS;
    
    IBOutlet NSPopUpButton *codeForAss;
    IBOutlet NSPopUpButton *dateForAss;
    
    IBOutlet NSWindow *dateSheet;
    IBOutlet NSDatePicker *dateField;
        
    IBOutlet LetterGradeLookup *letterGrades;
    IBOutlet GRLAttendanceDS *attendanceDS;
	
	IBOutlet GRLDatabase *data;
	IBOutlet DocumentPreferences *prefs;
	
	NSInteger attendanceColumn;
	
	NSArray *scheduleObservations;

}

- (void)reloadTableData;
- (void)resizeAssViewToFit;

- (void)refreshFinalScores:(id)sender;


#pragma mark - Collection Date / Codes
- (IBAction)codeChanged:(id)sender;
- (IBAction)dateChanged:(id)sender;
- (IBAction)newDate:(id)sender;
- (IBAction)confirmDate:(id)sender;
- (IBAction)cancelDate:(id)sender;
@property (retain) NSPopUpButton *codeForAss;		// Collection Code Menu
@property (retain) NSPopUpButton *dateForAss;		// Collection Date Menu
@property (retain) NSWindow *dateSheet;				// Custom Collection Date Sheet
@property (retain) NSDatePicker *dateField;

@property (retain) GRLAttendanceDS *attendanceDS;
@property (retain) NSTableView *nameTable;
@property (retain) LetterGradeLookup *letterGrades;	// Letter grades from 

@property (retain) ScoreHeaderViewController *headerTableDS;		// Assignment Header View

@property (retain) GRLDatabase *data;
@property (retain) DocumentPreferences *prefs;
@property NSInteger attendanceColumn;
@property (retain) NSArray *scheduleObservations;

@end
