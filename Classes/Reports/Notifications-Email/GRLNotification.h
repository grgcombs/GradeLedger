//
//  GRLNotification.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLEvent.h"

@class StudentObj;

@interface GRLNotification : NSObject 
{
    GRLEvent *event;
    NSString *rawMessage;
    NSString *name;
    BOOL sendsEmail;
    BOOL logsMessage;
}


- (NSString *)message:(GRLDatabase *)base forStudent:(StudentObj *)stud;

- (void)forceInvoke:(GRLDatabase *)base;

- (void)checkNotificationFiring:(GRLDatabase *)base;
- (BOOL)notificationShouldFire:(GRLDatabase *)base forStudent:(StudentObj *)stud;
- (void)fireNotification:(GRLDatabase *)base forStudent:(StudentObj *)stud;

- (NSDate *)nextEventDate;

@property (retain, readwrite) GRLEvent *event;
@property (retain, readwrite) NSString *name;
@property (retain, readwrite) NSString *rawMessage;
@property BOOL sendsEmail;
@property BOOL logsMessage;
@end
