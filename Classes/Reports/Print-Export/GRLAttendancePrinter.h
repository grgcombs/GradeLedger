//
//  GRLAttendancePrinter.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLPrintHeaderController.h"

@class StudentObj, GRLDatabase, GRLTextObject, GRLRotatedTextObject, GRLPathObject, GRLGrayBox, GRLTextView, DocumentPreferences;

@interface GRLAttendancePrinter : NSObject 
{
	IBOutlet DocumentPreferences *prefs;
	IBOutlet NSArrayController *filteredStudents;
	IBOutlet NSTableView *studentTable;
    
    GRLTextView *textView;
    NSWindow *win;
    
    IBOutlet NSWindow *printWindow;
    IBOutlet NSWindow *docWindow;
    
    IBOutlet NSMatrix *studentMatrix;
    
    IBOutlet NSMatrix *indivVsGroupMatrix;
    
    IBOutlet NSProgressIndicator *progress;
    
    IBOutlet GRLPrintHeaderController *headerController;
    
    IBOutlet NSPopUpButton *studCodeEqual1, *studCodeEqual2, *studCodeEqual4, *studCodeEqual5;
    IBOutlet NSTextField *studCount1, *studCount2, *studCount4, *studCount5;
    IBOutlet NSPopUpButton *studBool1, *studBool2, *studBool4;
    
    IBOutlet NSDatePicker *groupBeginDate, *groupEndDate;
}

- (void)populateMenus;

- (IBAction)confirmPrint:(id)sender;
- (IBAction)cancelPrint:(id)sender;

- (void)runAttendanceReportPrintDialogue;

- (NSArray *)individualAttendanceReportsForStudents:(NSArray *)studs printerInfo:(NSPrintInfo *)printInfo pageCount:(NSInteger *)pageCount;
- (NSArray *)individualAttendanceReportForStudent:(StudentObj *)stud printerInfo:(NSPrintInfo *)printInfo pageCount:(NSInteger *)pageCount;
- (NSArray *)groupAttendanceReportForStudents:(NSArray *)studs printerInfo:(NSPrintInfo *)printInfo printCount:(NSInteger *)printCount;

- (IBAction)toggleOption:(id)sender;

@property (retain) DocumentPreferences *prefs;
@property (retain) NSArrayController *filteredStudents;
@property (retain) NSTableView *studentTable;
@property (retain) NSDatePicker *groupBeginDate;
@property (retain) NSDatePicker *groupEndDate;


@property (retain) GRLTextView *textView;
@property (retain) NSWindow *win;
@property (retain) NSWindow *printWindow;
@property (retain) NSWindow *docWindow;
@property (retain) NSMatrix *studentMatrix;
@property (retain) NSMatrix *indivVsGroupMatrix;
@property (retain) NSProgressIndicator *progress;
@property (retain) GRLPrintHeaderController *headerController;
@property (assign) NSDictionary *printingSettings;
@end
