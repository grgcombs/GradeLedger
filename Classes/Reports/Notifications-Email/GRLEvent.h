//
//  GRLEvent.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

@class StudentObj, GRLDatabase;

@interface GRLEvent : NSObject 
{
    NSDate *previousLastTimeChecked;
    NSDate *lastTimeChecked;
    NSDate *firstTimeToCheck;
    
    NSInteger dayWeekMonth; 	// 1->day
								// 2->week
								// 3->month
}

- (id)initWithFirstTime:(NSDate *)first;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

+ (NSString *)defaultMessage;

- (NSString *)interpret:(GRLDatabase *)base message:(NSString *)message forStudent:(StudentObj *)stud;

- (BOOL)eventShouldOccur:(GRLDatabase *)base;
- (BOOL)eventShouldOccur:(GRLDatabase *)base forStudent:(StudentObj *)stud;
- (NSDate *)nextEventDate;

@property(nonatomic, retain) NSDate *previousLastTimeChecked;
@property(nonatomic, retain) NSDate *lastTimeChecked;
@property(nonatomic, retain) NSDate *firstTimeToCheck;
@property(nonatomic) NSInteger dayWeekMonth;

@end
