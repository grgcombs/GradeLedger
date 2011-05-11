//
//  GRLEvent.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLEvent.h"
#import "DateUtils.h"
#import "DocumentPreferences.h"
#import "GRLDatabase.h"

@implementation GRLEvent

@synthesize previousLastTimeChecked, lastTimeChecked, firstTimeToCheck, dayWeekMonth;

- (id)initWithFirstTime:(NSDate *)first
{
    if((self = [super init]))
    {
        firstTimeToCheck = [first retain];
        lastTimeChecked = nil;
        previousLastTimeChecked = nil;
        dayWeekMonth = 1;
    }
    return self;
}

- (void)dealloc
{
    self.firstTimeToCheck = self.lastTimeChecked = self.previousLastTimeChecked = nil;
    [super dealloc];
}

- (void)setFirstTimeToCheck:(NSDate *)date
{
	if (firstTimeToCheck)
		[firstTimeToCheck release], firstTimeToCheck = nil;
    firstTimeToCheck = [date retain];    
    self.lastTimeChecked = nil;
    
    [self eventShouldOccur:nil];
}

+ (NSString *)defaultMessage
{
    return @"GRLEvent's default message is not very exciting, no?";
}

- (NSString *)interpret:(GRLDatabase *)base message:(NSString *)message forStudent:(StudentObj *)stud
{
    //<insert class name>
    //<insert class description>
    //<insert class description long>
    //<insert school homepage>
    //<insert school name>
    //<insert school phone number>
     
    //<insert email address>
    //<insert department>
    //<insert work phone number>
    //<insert name>
    //<insert office hours>
    //<insert homepage>
    
    return [base.preferences resolveStringAgainstPrefs:message];
}

- (BOOL)eventShouldOccur:(GRLDatabase *)base
{
    NSDate *nextFire = [self nextEventDate];
    NSDate *today = [NSDate date];
    NSInteger comparison = [nextFire compare:today];
    
    if(!nextFire || comparison == NSOrderedDescending)
        return NO;
     
    self.previousLastTimeChecked = lastTimeChecked;
     
    if(comparison == NSOrderedSame)
    {
        self.lastTimeChecked = nextFire;
        return YES;
    }
    	
    while([lastTimeChecked compare:today] == NSOrderedAscending) {
    
		if (dayWeekMonth == 3) // it's advancing one month
			self.lastTimeChecked = [DateUtils setMonthsFromDate:lastTimeChecked numMonths:1];
		else if (dayWeekMonth == 2)
			self.lastTimeChecked = [DateUtils setWeeksFromDate:lastTimeChecked numWeeks:1];
		else if (dayWeekMonth == 1)
			self.lastTimeChecked = [DateUtils setDaysFromDate:lastTimeChecked numDays:1];
		else // shouldn't be here, but just in case, get out of this loop ...
			continue;		
	}

	if([lastTimeChecked compare:today] == NSOrderedDescending) {
		if (dayWeekMonth == 3) // it's advancing one month
			self.lastTimeChecked = [DateUtils setMonthsFromDate:lastTimeChecked numMonths:-1];
		else if (dayWeekMonth == 2)
			self.lastTimeChecked = [DateUtils setWeeksFromDate:lastTimeChecked numWeeks:-1];
		else if (dayWeekMonth == 1)
			self.lastTimeChecked = [DateUtils setDaysFromDate:lastTimeChecked numDays:-1];		
    }
    [lastTimeChecked retain];
    return YES;
}

- (BOOL)eventShouldOccur:(GRLDatabase *)base forStudent:(StudentObj *)stud
{
    return NO;
}

- (NSDate *)nextEventDate
{
    if(!firstTimeToCheck)
    {
        NSLog(@"Error - user should be forced to set a first time for their events.");
        return nil;
    }
    
    if(!lastTimeChecked)
        self.lastTimeChecked = firstTimeToCheck;
        
    NSDate *today = [NSDate date];
    
    NSDate *nextFire = nil;
	
	if (dayWeekMonth == 3) // it's advancing one month
		nextFire = [DateUtils setMonthsFromDate:lastTimeChecked numMonths:1];
	else if (dayWeekMonth == 2)
		nextFire = [DateUtils setWeeksFromDate:lastTimeChecked numWeeks:1];
	else if (dayWeekMonth == 1)
		nextFire = [DateUtils setDaysFromDate:lastTimeChecked numDays:1];
	//else // shouldn't be here, but just in case, give us something...
	//	nextFire = lastTimeChecked;
	// *** On second thought, this might be a bad idea, just let it be nil.
		
                                                                                           
    if([DateUtils isEarlier:today thanDate:nextFire])	// we haven't yet reached the point where we have to fire this event
        return nextFire;
            
    return today;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if(self)
    {
        previousLastTimeChecked = [[coder decodeObjectForKey:@"previousLastTimeChecked"] retain];
        lastTimeChecked = [[coder decodeObjectForKey:@"lastTimeChecked"] retain];
        firstTimeToCheck = [[coder decodeObjectForKey:@"firstTimeToCheck"] retain];
        dayWeekMonth = [[coder decodeObjectForKey:@"dayWeekMonth"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:previousLastTimeChecked forKey:@"previousLastTimeChecked"];
    [coder encodeObject:lastTimeChecked forKey:@"lastTimeChecked"];
    [coder encodeObject:firstTimeToCheck forKey:@"firstTimeToCheck"];
    [coder encodeObject:[NSNumber numberWithInteger:dayWeekMonth] forKey:@"dayWeekMonth"];
}

@end
