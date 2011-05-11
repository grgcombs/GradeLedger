//
//  GRLStudentEmailer.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

@interface GRLStudentEmailer : NSObject 
{
    IBOutlet NSArrayController *filteredStudents;
	
    IBOutlet NSWindow *docWindow;
    IBOutlet NSWindow *window;
    
}

- (void)showEmailer:(id)sender;

- (IBAction)dismissEmailer:(id)sender;
- (IBAction)emailSelectedStudents:(id)sender;

@property (retain) NSArrayController *filteredStudents;
@property (retain) NSWindow *docWindow;
@property (retain) NSWindow *window;
@end
