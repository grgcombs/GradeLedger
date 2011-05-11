//
//  GRLStudentEmailer.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLStudentEmailer.h"
#import <Message/NSMailDelivery.h>

#import "StudentObj.h"

@implementation GRLStudentEmailer

- (id)init
{
    if((self = [super init])) 
	{
	}
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void)showEmailer:(id)sender
{
    [NSApp beginSheet:window
            modalForWindow:docWindow
            modalDelegate:nil
            didEndSelector:nil
            contextInfo:nil];
}

- (IBAction)dismissEmailer:(id)sender
{
    [NSApp endSheet:window];
    [window orderOut:nil];
}


- (IBAction)emailSelectedStudents:(id)sender
{
    NSMutableString *emails = [NSMutableString stringWithString:@"mailto:"];
    
	BOOL isFirst = YES;
	for (StudentObj *stud in [self.filteredStudents selectedObjects]) {
		
        NSString *email = [stud emailAddress];
        
        if([email length])
        {
            if(!isFirst)
                [emails appendString:@","];
            else
                isFirst = NO;
			
            [emails appendString:email];
        }		
	}
	
	
    NSURL *url = [NSURL URLWithString:emails];
    [[NSWorkspace sharedWorkspace] openURL:url];
}


@synthesize filteredStudents;
@synthesize docWindow;
@synthesize window;
@end
