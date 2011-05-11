//
//  GRLPrintHeaderController.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

@class DocumentPreferences;

@interface GRLPrintHeaderController : NSObject 
{
    IBOutlet NSWindow *printHeaderHelper;
    
    IBOutlet NSWindow *docWindow;
    IBOutlet NSWindow *window;
    IBOutlet NSTextView *textView;
    
    IBOutlet DocumentPreferences *prefs;
}

- (IBAction)editHeader:(id)sender;
- (IBAction)getHelp:(id)sender;

- (IBAction)confirmEdit:(id)sender;
- (IBAction)cancelEdit:(id)sender;

@property (retain) DocumentPreferences *prefs;

@property (retain) NSWindow *printHeaderHelper;
@property (retain) NSWindow *docWindow;
@property (retain) NSWindow *window;
@property (retain) NSTextView *textView;
@end
