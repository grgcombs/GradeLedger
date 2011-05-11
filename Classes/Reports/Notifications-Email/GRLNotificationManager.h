//
//  GRLNotificationManager.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLNotification.h"

@class DocumentPreferences;
@interface GRLNotificationManager : NSObject 
{
    NSMutableArray *notificationArray;
    NSMutableArray *timers;
    NSMutableDictionary *loggedMessages;
   IBOutlet GRLDatabase *data;
	IBOutlet DocumentPreferences *prefs;
    
    IBOutlet NSWindow *logWindow;
    IBOutlet NSOutlineView *logView;
    
    IBOutlet NSWindow *docWindow;
    
    IBOutlet NSWindow *notSheet;
    IBOutlet NSTableView *notTable;
    
    IBOutlet NSWindow *notInfoSheet;
    IBOutlet NSMatrix *notType;
    IBOutlet NSMatrix *notDates;
    IBOutlet NSTextView *notMessage;
    
    IBOutlet NSPopUpButton *attCode;
    IBOutlet NSTextField *attCount;
    
    IBOutlet NSTextField *missCount;
    
    IBOutlet NSPopUpButton *finalScoreAboveBelow;
    IBOutlet NSTextField *finalScoreValue;
	
}

- (void)setNotificationData:(NSDictionary *)dict;
- (NSDictionary *)notificationData;

- (void)establishAllTimers;
- (NSTimer *)establishTimerForNotification:(GRLNotification *)notif;

- (void)showNotifications;
- (IBAction)dismissNotifications:(id)sender;

- (void)checkTimer:(NSTimer *)timer;

- (IBAction)createNotification:(id)sender;
- (IBAction)removeNotification:(id)sender;

- (IBAction)editNotification:(id)sender;

- (IBAction)confirmCreationOrEditing:(id)sender;
- (IBAction)cancelCreationOrEditing:(id)sender;

- (IBAction)invokeSelectedNotification:(id)sender;

- (IBAction)matrixSelectionChanged:(id)sender;

- (IBAction)clearLog:(id)sender;
- (void)showLog;

- (IBAction)closeLogWindow:(id)sender;

@property (retain) GRLDatabase *data;
@property (retain) DocumentPreferences *prefs;

@property (retain) NSMutableArray *notificationArray;
@property (retain) NSMutableArray *timers;
@property (retain) NSMutableDictionary *loggedMessages;
@property (retain) NSWindow *logWindow;
@property (retain) NSOutlineView *logView;
@property (retain) NSWindow *docWindow;
@property (retain) NSWindow *notSheet;
@property (retain) NSTableView *notTable;
@property (retain) NSWindow *notInfoSheet;
@property (retain) NSMatrix *notType;
@property (retain) NSMatrix *notDates;
@property (retain) NSTextView *notMessage;
@property (retain) NSPopUpButton *attCode;
@property (retain) NSTextField *attCount;
@property (retain) NSTextField *missCount;
@property (retain) NSPopUpButton *finalScoreAboveBelow;
@property (retain) NSTextField *finalScoreValue;
@property (assign) NSDictionary *notificationData;

@end
