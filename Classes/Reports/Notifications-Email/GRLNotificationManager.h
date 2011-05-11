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

@property (nonatomic, assign) GRLDatabase *data;
@property (nonatomic, assign) DocumentPreferences *prefs;

@property (nonatomic, assign) NSWindow *logWindow;
@property (nonatomic, assign) NSOutlineView *logView;
@property (nonatomic, assign) NSWindow *docWindow;
@property (nonatomic, assign) NSWindow *notSheet;
@property (nonatomic, assign) NSTableView *notTable;
@property (nonatomic, assign) NSWindow *notInfoSheet;
@property (nonatomic, assign) NSMatrix *notType;
@property (nonatomic, assign) NSMatrix *notDates;
@property (nonatomic, assign) NSTextView *notMessage;
@property (nonatomic, assign) NSPopUpButton *attCode;
@property (nonatomic, assign) NSTextField *attCount;
@property (nonatomic, assign) NSTextField *missCount;
@property (nonatomic, assign) NSPopUpButton *finalScoreAboveBelow;
@property (nonatomic, assign) NSTextField *finalScoreValue;

@property (nonatomic, copy) NSDictionary *notificationData;
@property (nonatomic, copy) NSMutableArray *notificationArray;
@property (nonatomic, copy) NSMutableArray *timers;
@property (nonatomic, copy) NSMutableDictionary *loggedMessages;

@end
