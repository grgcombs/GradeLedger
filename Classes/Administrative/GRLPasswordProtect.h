//
//  GRLPasswordProtect.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

@interface GRLPasswordProtect : NSObject 
{
    IBOutlet NSWindow *docWindow;

    IBOutlet NSWindow *passwordSheet;
    IBOutlet NSTextField *oldPassword;
    IBOutlet NSTextField *newPassword;
    IBOutlet NSTextField *newPasswordAgain;
    
    IBOutlet NSWindow *passwordGetterWindow;
    IBOutlet NSTextField *passwordGetterField;
    
    NSString *password;
}

- (void)setPassword:(NSString *)pwd;

- (BOOL)checkIfPasswordIsValid;
- (NSString *)setOrChangePassword;

- (IBAction)confirmPassword:(id)sender;
- (IBAction)cancelPassword:(id)sender;

- (IBAction)checkPassword:(id)sender;
- (IBAction)passwordNotKnown:(id)sender;

@property (retain) NSWindow *docWindow;
@property (retain) NSWindow *passwordSheet;
@property (retain) NSTextField *oldPassword;
@property (retain) NSTextField *newPassword;
@property (retain) NSTextField *newPasswordAgain;
@property (retain) NSWindow *passwordGetterWindow;
@property (retain) NSTextField *passwordGetterField;
@end
