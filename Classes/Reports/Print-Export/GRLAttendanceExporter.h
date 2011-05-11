//
//  GRLAttendanceExporter.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLPrintHeaderController.h"

@class StudentObj, GRLDatabase, DocumentPreferences;


@interface GRLAttendanceExporter : NSObject 
{
	IBOutlet GRLDatabase *data;
	IBOutlet DocumentPreferences *prefs;
    
    IBOutlet NSWindow *printWindow;
    IBOutlet NSWindow *docWindow;
    
    IBOutlet NSMatrix *studentMatrix;
    IBOutlet NSPopUpButton *startStud;
    IBOutlet NSPopUpButton *stopStud;
    
    IBOutlet NSMatrix *indivVsGroupMatrix;
    
    IBOutlet NSProgressIndicator *progress;
    
    IBOutlet GRLPrintHeaderController *headerController;
    
    IBOutlet NSPopUpButton *studCodeEqual1, *studCodeEqual2, *studCodeEqual4, *studCodeEqual5;
    IBOutlet NSTextField *studCount1, *studCount2, *studCount4, *studCount5;
    IBOutlet NSPopUpButton *studBool1, *studBool2, *studBool4;
    
    IBOutlet NSDatePicker *groupBeginDate, *groupEndDate;
}

- (void)populateMenus;

- (NSDictionary *)exportingSettings;
- (void)setExportingSettings:(NSDictionary *)dict;

- (IBAction)confirmExport:(id)sender;
- (IBAction)cancelExport:(id)sender;

- (IBAction)changeFirstStudent:(id)sender;

- (void)exportToHTML;
- (NSString *)createAttendanceIndex:(NSArray *)savedNames;
- (void)writeOutHTML:(NSString *)html toPath:(NSString *)path originalPath:(NSString *)origPath attempts:(NSInteger)attempts writtenPaths:(NSMutableArray *)paths overwrite:(BOOL *)over;

- (NSArray *)runAttendanceExportReportDialogue;

- (NSDictionary *)htmlDataForIndividualStudent:(StudentObj *)stud;
- (NSArray *)htmlDataForIndividualStudents:(NSArray *)studs;
- (NSDictionary *)htmlDataForGroupOfStudents:(NSArray *)studs;

@property (retain) DocumentPreferences *prefs;
@property (retain) GRLDatabase *data;
@property (retain) NSWindow *printWindow;
@property (retain) NSWindow *docWindow;
@property (retain) NSMatrix *studentMatrix;
@property (retain) NSPopUpButton *startStud;
@property (retain) NSPopUpButton *stopStud;
@property (retain) NSMatrix *indivVsGroupMatrix;
@property (retain) NSProgressIndicator *progress;
@property (retain) GRLPrintHeaderController *headerController;
@end
