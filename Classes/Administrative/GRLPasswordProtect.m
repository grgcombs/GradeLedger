//
//  GRLPasswordProtect.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLPasswordProtect.h"


@implementation GRLPasswordProtect

- (id)init
{
    self = [super init];
    if(self) {
        m_password = nil;
	}
    return self;
}

- (void)dealloc
{
	self.password = nil;

    [super dealloc];
}

- (BOOL)checkIfPasswordIsValid
{
    BOOL res = ([NSApp runModalForWindow:passwordGetterWindow] == NSOKButton);
    
    [passwordGetterWindow orderOut:nil];
    return res;
}

- (NSString *)setOrChangePassword
{
    [oldPassword setStringValue:@""];
    [newPassword setStringValue:@""];
    [newPasswordAgain setStringValue:@""];

    [oldPassword setEnabled:(m_password != nil)];
    
    [NSApp beginSheet:passwordSheet
           modalForWindow:docWindow
           modalDelegate:nil
           didEndSelector:nil
           contextInfo:nil];
           
    NSInteger res = [NSApp runModalForWindow:passwordSheet];
    
    [NSApp endSheet:passwordSheet];
    [passwordSheet orderOut:nil];
    
    if(res == NSOKButton)
    {
        self.password = [newPassword stringValue];
        return m_password;
    }
    else {
        return nil;
	}
}

- (IBAction)confirmPassword:(id)sender
{
    if(m_password != nil && ![[oldPassword stringValue] isEqualToString:m_password])
    {
        //error
        NSRunAlertPanel(@"Password Error",
                        @"You did not correctly enter the old password.",
                        nil,
                        nil,
                        nil);
        return;
    }

    if([[newPassword stringValue] length] < 8 && [[newPassword stringValue] length] > 0)
    {
        //error
        NSRunAlertPanel(@"Password Error",
                        @"Your new password must be at least 8 characters long. (Or blank to remove protection)",
                        nil,
                        nil,
                        nil);
        return;
    }

    if(![[newPassword stringValue] isEqualToString:[newPasswordAgain stringValue]])
    {
        //error
        NSRunAlertPanel(@"Password Error",
                        @"Your did not type your password correctly both times.",
                        nil,
                        nil,
                        nil);
        return;
    }

    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)cancelPassword:(id)sender
{
    [NSApp stopModalWithCode:NSCancelButton];
}

- (IBAction)checkPassword:(id)sender
{
    if(![[passwordGetterField stringValue] isEqualToString:m_password])
    {
        NSRunAlertPanel(@"Password Error",
                        @"The password you entered is not valid.",
                        nil,
                        nil,
                        nil);
        return;
    }
    
    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)passwordNotKnown:(id)sender
{
    [NSApp stopModalWithCode:NSCancelButton];
}


@synthesize password = m_password;
@synthesize docWindow;
@synthesize passwordSheet;
@synthesize oldPassword;
@synthesize newPassword;
@synthesize newPasswordAgain;
@synthesize passwordGetterWindow;
@synthesize passwordGetterField;
@end
