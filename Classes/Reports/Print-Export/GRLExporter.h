//
//  GRLExporter.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLPrintHeaderController.h"

@class StudentObj, GRLDatabase, LetterGradeLookup, DocumentPreferences;

@interface GRLExporter : NSObject 
{
    IBOutlet GRLDatabase *data;
    IBOutlet DocumentPreferences *prefs;
    
    IBOutlet LetterGradeLookup *letterGrades;
    
    IBOutlet GRLPrintHeaderController *headerController;
    
    IBOutlet NSWindow *printWindow;
    IBOutlet NSWindow *docWindow;
    
    IBOutlet NSMatrix *studentMatrix;
    IBOutlet NSPopUpButton *startStud;
    IBOutlet NSPopUpButton *stopStud;
    IBOutlet NSTextField *belowScore;
    
    IBOutlet NSMatrix *assMatrix;
    IBOutlet NSPopUpButton *startAss;
    IBOutlet NSPopUpButton *stopAss;
    IBOutlet NSPopUpButton *categoriesButton;
    
    IBOutlet NSMatrix *indivVsGroupMatrix;
    IBOutlet NSPopUpButton *optionsButton;
    
    IBOutlet NSProgressIndicator *progress;
}

- (void)populateMenus;

- (NSDictionary *)exportingSettings;
- (void)setExportingSettings:(NSDictionary *)dict;

- (IBAction)confirmPrint:(id)sender;
- (IBAction)cancelPrint:(id)sender;

- (IBAction)changeFirstStudent:(id)sender;
- (IBAction)changeFirstAssignment:(id)sender;
- (IBAction)toggleOption:(id)sender;

- (void)exportToHTML:(id)sender;
- (NSString *)createGradesIndex:(NSArray *)savedNames;
- (void)writeOutHTML:(NSString *)html toPath:(NSString *)path originalPath:(NSString *)origPath attempts:(NSInteger)attempts writtenPaths:(NSMutableArray *)paths overwrite:(BOOL *)over;
- (NSArray *)runHTMLExportReportDialogue;

- (NSDictionary *)htmlDataForIndividualStudent:(StudentObj *)stud options:(NSInteger)opts;
- (NSArray *)htmlDataForIndividualStudents:(NSArray *)studs options:(NSInteger)opts;
- (NSDictionary *)htmlDataForGroupOfStudents:(NSArray *)studs;

@property (retain) GRLDatabase *data;
@property (retain) DocumentPreferences *prefs;
@property (retain) LetterGradeLookup *letterGrades;
@property (retain) GRLPrintHeaderController *headerController;
@property (retain) NSWindow *printWindow;
@property (retain) NSWindow *docWindow;
@property (retain) NSMatrix *studentMatrix;
@property (retain) NSPopUpButton *startStud;
@property (retain) NSPopUpButton *stopStud;
@property (retain) NSTextField *belowScore;
@property (retain) NSMatrix *assMatrix;
@property (retain) NSPopUpButton *startAss;
@property (retain) NSPopUpButton *stopAss;
@property (retain) NSPopUpButton *categoriesButton;
@property (retain) NSMatrix *indivVsGroupMatrix;
@property (retain) NSPopUpButton *optionsButton;
@property (retain) NSProgressIndicator *progress;
@end
