//
//  GRLStatController.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLDatabase.h"

@class AssignmentObj;
@class StudentObj;
@class ScoreObj;
@class DocumentPreferences;

@interface GRLStatController : NSObject 
{
    IBOutlet GRLDatabase *data;
	IBOutlet DocumentPreferences *prefs;
    
    IBOutlet NSWindow *docWindow;
    IBOutlet NSWindow *statsSheet;
        
    IBOutlet NSTextField *meanText, *medianText, *modeText, *varText, *sdText, *maxText, *minText;
    IBOutlet NSMatrix *statOptions;
    
    IBOutlet NSPopUpButton *students;
    IBOutlet NSPopUpButton *assignments;
    IBOutlet NSPopUpButton *categories;
    IBOutlet NSTextField *finalScore;
    
    IBOutlet NSMatrix *assesVsCats;
}

- (NSArray *)students;
- (NSArray *)assignments;
- (NSArray *)categories;

- (double)meanWithStudents:(NSArray *)studs assignment:(AssignmentObj *)ass;
- (double)meanWithStudents:(NSArray *)studs assignments:(NSArray *)asses;

- (double)modeWithStudents:(NSArray *)studs assignment:(AssignmentObj *)ass count:(NSInteger *)count;
- (double)modeWithStudents:(NSArray *)studs assignments:(NSArray *)ass;

- (double)medianWithStudents:(NSArray *)studs assignment:(AssignmentObj *)ass;
- (double)medianWithStudents:(NSArray *)studs assignments:(NSArray *)asses;
- (double)varianceWithStudents:(NSArray *)studs assignment:(AssignmentObj *)ass;
- (double)varianceWithStudents:(NSArray *)studs assignments:(NSArray *)asses;
- (double)standardDeviationWithStudents:(NSArray *)studs assignments:(NSArray *)asses;

- (double)minimum:(BOOL)isMin withStudents:(NSArray *)studs assignment:(AssignmentObj *)ass;
- (double)minimumWithStudents:(NSArray *)studs assignments:(NSArray *)asses;
- (double)maximumWithStudents:(NSArray *)studs assignments:(NSArray *)asses;

- (IBAction)calculateStatistics:(id)sender;
- (IBAction)matrixSelectionChanged:(id)sender;

- (IBAction)popUpButtonAction:(id)sender;

- (void)runStatsSheet;
- (IBAction)dismissStatsSheet:(id)sender;

@property (retain) DocumentPreferences *prefs;
@property (retain) GRLDatabase *data;
@property (retain) NSWindow *docWindow;
@property (retain) NSWindow *statsSheet;
@property (retain) NSMatrix *statOptions;
@property (retain) NSTextField *finalScore;
@property (retain) NSMatrix *assesVsCats;
@end
