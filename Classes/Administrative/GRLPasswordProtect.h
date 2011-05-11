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
    
    NSString *m_password;
}


- (BOOL)checkIfPasswordIsValid;
- (NSString *)setOrChangePassword;

- (IBAction)confirmPassword:(id)sender;
- (IBAction)cancelPassword:(id)sender;

- (IBAction)checkPassword:(id)sender;
- (IBAction)passwordNotKnown:(id)sender;

@property (nonatomic, assign) NSWindow *docWindow;
@property (nonatomic, assign) NSWindow *passwordSheet;
@property (nonatomic, assign) NSTextField *oldPassword;
@property (nonatomic, assign) NSTextField *newPassword;
@property (nonatomic, assign) NSTextField *newPasswordAgain;
@property (nonatomic, assign) NSWindow *passwordGetterWindow;
@property (nonatomic, assign) NSTextField *passwordGetterField;
@property (nonatomic, copy) NSString *password;
@end
