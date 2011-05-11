//
//  GRLAttendanceCodeEvent.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLAttendanceCodeEvent.h"
#import "StudentObj.h"
#import "DateUtils.h"
#import "AttendanceForDate.h"


@implementation GRLAttendanceCodeEvent
@synthesize attendanceCount, attendanceCode;

- (id)initWithFirstTime:(NSDate *)date
{
    self = [super initWithFirstTime:date];
    if(self)
    {
        attendanceCode = GRLExcused;
        attendanceCount = 0;
    }
    return self;
}


- (BOOL)eventShouldOccur:(GRLDatabase *)base forStudent:(StudentObj *)stud
{
    NSDate *tempDate = lastTimeChecked;
    NSInteger numFound = 0;
                                       
    NSDate *endDate = previousLastTimeChecked;
        
    
    while(1)
    {
        tempDate = [DateUtils setDaysFromDate:tempDate numDays:-1];
    
        AttendanceForDate *att = [stud attendanceForDate:tempDate];
        
        if([att.attendanceCode integerValue] == attendanceCode)
            numFound++;
            
        if([tempDate compare:endDate] == NSOrderedAscending)
            break;
    }
    
    return (numFound > attendanceCount);
}

+ (NSString *)defaultMessage
{
	// GREG -- pull our template from a plist ... not the most graceful, but it's easy-peasy.
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"GRLEmailTemplate" ofType:@"plist"];
	NSDictionary *aDictionary = [[NSDictionary alloc] initWithContentsOfFile:thePath];
	
	NSString *template = [[[NSString alloc] initWithString:[aDictionary valueForKey:@"AttendanceEventMessage"]] autorelease];
						  						  
	// release the raw data
	[aDictionary release];

    return template;
}

- (NSString *)interpret:(GRLDatabase *)base message:(NSString *)message forStudent:(StudentObj *)stud
{
    message = [[message componentsSeparatedByString:@"%S"] componentsJoinedByString:[stud name]];
    message = [[message componentsSeparatedByString:@"%A"] componentsJoinedByString:[[AttendanceForDate stringForCode:attendanceCode] lowercaseString]];
    message = [[message componentsSeparatedByString:@"%D"] componentsJoinedByString:[NSString stringWithFormat:@"%d",attendanceCount]];
    message = [[message componentsSeparatedByString:@"%B"] componentsJoinedByString:[DateUtils dateAsHeaderString:previousLastTimeChecked]];
    message = [[message componentsSeparatedByString:@"%E"] componentsJoinedByString:[DateUtils dateAsHeaderString:lastTimeChecked]];
    
    message = [super interpret:base message:message forStudent:stud];
    
    return message;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self)
    {
        attendanceCount = [[coder decodeObjectForKey:@"count"] integerValue];
        attendanceCode = [[coder decodeObjectForKey:@"code"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:[NSNumber numberWithInteger:attendanceCount] forKey:@"count"];
    [coder encodeObject:[NSNumber numberWithInteger:attendanceCode] forKey:@"code"];
}

@end
