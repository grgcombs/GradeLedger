//
//  GRLDocument.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//



enum kTabViewTabs {
	kTabViewScores		= 1,
	kTabViewPhotos		= 3,
	kTabViewSettings		= 5,
	kTabViewInfo			= 6,

	kTabViewNewPrefs		= 7,

	kTabViewAttendance	= 8,
	kTabViewCatsAsses		= 9,
	kTabViewStudents		= 10,
} kTabViewTabs;

@class DocumentPreferences;
@class GRLScoreDS, ScoreHeaderViewController;
@class GRLDatabase;
@class GRLAttendanceDS;
@class GRLExporter, GRLPrinter, GRLPrintHeaderController;
@class GRLAttendancePrinter, GRLAttendanceExporter;
@class GRLStatController, GRLStudentEmailer, GRLZeroer;
@class GRLNotificationManager, GRLPasswordProtect;


@interface GRLDocument : NSPersistentDocument
{
	IBOutlet DocumentPreferences *_preferences;

    IBOutlet GRLScoreDS *scoreDS;
    IBOutlet ScoreHeaderViewController *assHead;
    
    IBOutlet GRLAttendanceDS *attDS; 
        
    IBOutlet GRLPrinter *printer;
    IBOutlet GRLAttendancePrinter *attPrinter;
    
    IBOutlet GRLExporter *exporter;
    IBOutlet GRLAttendanceExporter *attExporter;
    
    IBOutlet GRLPasswordProtect *passwordProtector;
    IBOutlet GRLNotificationManager *notManager;
    IBOutlet GRLStatController *statController;
        
    IBOutlet GRLPrintHeaderController *headerController;
    IBOutlet GRLStudentEmailer *studentEmailer;
    
    IBOutlet GRLZeroer *zeroer;
	
    IBOutlet GRLDatabase *data;
    
    NSWindow *docWindow;
	
	IBOutlet NSTabView *mainTabView;
}

- (IBAction)importDoc:(id)sender;
- (void)exportToHTML:(id)sender;

- (void)setOrChangePassword:(id)sender;

- (void)showNotificationManager:(id)sender;
- (void)showNotificationLog:(id)sender;

- (void)showStatistics:(id)sender;

- (void)toggleNotesDrawer:(id)sender;

- (void)showPrintHeader:(id)sender;

- (void)showWebsite:(id)sender;

- (void)showStudentEmailer:(id)sender;

- (void)zeroAllBlankScores:(id)sender;
- (void)zeroAllLateBlankScores:(id)sender;

- (IBAction)scheduleChanged:(id)sender;


- (void)documentEdited:(NSNotification *)notif;

@property (retain) DocumentPreferences *preferences;
@property (retain) GRLScoreDS *scoreDS;
@property (retain) ScoreHeaderViewController *assHead;
@property (retain) GRLAttendanceDS *attDS;
@property (retain) GRLPrinter *printer;
@property (retain) GRLAttendancePrinter *attPrinter;
@property (retain) GRLExporter *exporter;
@property (retain) GRLAttendanceExporter *attExporter;
@property (retain) GRLPasswordProtect *passwordProtector;
@property (retain) GRLNotificationManager *notManager;
@property (retain) GRLStatController *statController;
@property (retain) GRLPrintHeaderController *headerController;
@property (retain) GRLStudentEmailer *studentEmailer;
@property (retain) GRLZeroer *zeroer;
@property (retain) GRLDatabase *data;
@property (retain) NSWindow *docWindow;
@end
