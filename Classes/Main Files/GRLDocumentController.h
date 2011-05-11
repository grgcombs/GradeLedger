//
//  GRLDocumentController.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

@interface GRLDocumentController : NSDocumentController 
{
    IBOutlet NSWindow *classList;
    IBOutlet NSTableView *classListTable;
    
    IBOutlet NSButton *showClassListOnLaunch;
    IBOutlet NSButton *automaticallyAddNewClasses;
    
    NSMutableArray *m_classes;
    
    BOOL didFinishLaunching;
}

- (void)newClassCreated:(NSURL *)url;

- (void)removeClass:(id)sender;
- (void)addClass:(id)sender;

- (void)openClass:(id)sender;

@property (retain) NSWindow *classList;
@property (retain) NSTableView *classListTable;
@property (retain) NSButton *showClassListOnLaunch;
@property (retain) NSButton *automaticallyAddNewClasses;
@property (retain) NSMutableArray *m_classes;
@property BOOL didFinishLaunching;
@end