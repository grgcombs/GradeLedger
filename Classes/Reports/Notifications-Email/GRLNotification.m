//
//  GRLNotification.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLNotification.h"
#import "DateUtils.h"
#import "GRLDatabase.h"

@implementation GRLNotification

@synthesize name, event, rawMessage, logsMessage, sendsEmail;

- (id)init
{
    if((self = [super init]))
    {
        name = [@"New Notification" retain];
        event = nil;
        rawMessage = nil;
        logsMessage = YES;
        sendsEmail = YES;
    }
    return self;
}

- (void)dealloc
{
    self.event = nil;
	self.rawMessage = nil;
	self.name = nil;
    [super dealloc];
}

- (NSString *)message:(GRLDatabase *)base forStudent:(StudentObj *)stud
{
    return [event interpret:base message:rawMessage forStudent:stud];
}


- (void)forceInvoke:(GRLDatabase *)base
{
    NSDate *date = [event firstTimeToCheck];
    
    [event setFirstTimeToCheck:[DateUtils setMonthsFromDate:date numMonths:-1]];
    [event setLastTimeChecked:nil];
                                     
    [self checkNotificationFiring:base];
    [event setFirstTimeToCheck:date];
    
    [event eventShouldOccur:nil];
}

- (void)checkNotificationFiring:(GRLDatabase *)base
{
    StudentObj *stud;
    
    BOOL occur = [event eventShouldOccur:base];
    if(!occur)
        return;
    
    for(stud in [base.studentController arrangedObjects] )
        if([self notificationShouldFire:base forStudent:stud])
            [self fireNotification:base forStudent:stud];
}

- (BOOL)notificationShouldFire:(GRLDatabase *)base forStudent:(StudentObj *)stud
{
    return [event eventShouldOccur:base forStudent:stud];
}

- (void)fireNotification:(GRLDatabase *)base forStudent:(StudentObj *)stud
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GRLNotificationFiring" object:base userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[event interpret:base message:rawMessage forStudent:stud],[stud objectID],self,nil] forKeys:[NSArray arrayWithObjects:@"text",@"stud",@"not",nil]]];
}

- (NSDate *)nextEventDate
{
    return [event nextEventDate];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self)
    {
        self.event = [coder decodeObjectForKey:@"event"];
        self.rawMessage = [coder decodeObjectForKey:@"message"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.sendsEmail = [[coder decodeObjectForKey:@"sendsEmail"] boolValue];
        self.logsMessage = [[coder decodeObjectForKey:@"logsMessage"] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:event forKey:@"event"];
    [coder encodeObject:rawMessage forKey:@"message"];
    
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:[NSNumber numberWithBool:sendsEmail] forKey:@"sendsEmail"];
    [coder encodeObject:[NSNumber numberWithBool:logsMessage] forKey:@"logsMessage"];
}
@end
