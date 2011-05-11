//
//  GRLPrintHeaderController.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLPrintHeaderController.h"
#import "DocumentPreferences.h"

@implementation GRLPrintHeaderController

- (void)dealloc
{
    [super dealloc];
}


- (IBAction)editHeader:(id)sender
{

    [textView setString:[self.prefs valueForKey:@"exportHeader"]];

    [NSApp beginSheet:window
            modalForWindow:docWindow
            modalDelegate:nil
            didEndSelector:nil
            contextInfo:nil];
    
    if([NSApp runModalForWindow:window] == NSOKButton)
		[self.prefs setValue:[textView string] forKey:@"exportHeader"];
    
    [NSApp endSheet:window];
    [window orderOut:nil];
}

- (IBAction)confirmEdit:(id)sender
{
    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)cancelEdit:(id)sender
{
    [NSApp stopModalWithCode:NSCancelButton];
}

- (IBAction)getHelp:(id)sender
{
    [NSApp runModalForWindow:printHeaderHelper];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    [NSApp stopModal];
}


@synthesize printHeaderHelper;
@synthesize docWindow;
@synthesize window;
@synthesize textView;
@synthesize prefs;
@end
