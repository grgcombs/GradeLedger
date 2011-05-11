//
//  GRLMissingAssignmentEvent.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLMissingAssignmentEvent.h"

#import "StudentObj.h"
#import "ScoreObj.h"
#import "AssignmentObj.h"
#import "DateUtils.h"
#import "GRLDatabase.h"

@implementation GRLMissingAssignmentEvent

@synthesize missingCount;

- (id)initWithFirstTime:(NSDate *)date
{
    self = [super initWithFirstTime:date];
    if(self)
    	missingCount = 0;
    return self;
}

- (BOOL)eventShouldOccur:(GRLDatabase *)base forStudent:(StudentObj *)stud
{
    NSInteger numFound = 0;
    
    /*NSDate *endDate = [lastTimeChecked dateByAddingYears:0 
                                       months:-(!(dayWeekMonth % 3))
                                       days:-(!(dayWeekMonth % 2)*7 + !(dayWeekMonth % 1))
                                       hours:0
                                       minutes:0
                                       seconds:0];*/
                                       
    NSDate *endDate = previousLastTimeChecked;
                                       
    NSDate *startDate = [DateUtils setDaysFromDate:lastTimeChecked numDays:-1];
        
    
    for(AssignmentObj *ass in [base allAssignmentsSortedByDueDate])
    {
        NSDate *date = [ass dueDate];
        if(!date)
            continue;
            
        if([date compare:endDate] != NSOrderedAscending && [date compare:startDate] != NSOrderedDescending)
            if(![[stud scoreForAssignment:ass] validScore])
                numFound++;
    }
            
    return (numFound > missingCount);
}

+ (NSString *)defaultMessage
{
	// GREG -- pull our template from a plist ... not the most graceful, but it's easy-peasy.
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"GRLEmailTemplate" ofType:@"plist"];
	NSDictionary *aDictionary = [[NSDictionary alloc] initWithContentsOfFile:thePath];
	
	NSString *template = [[[NSString alloc] initWithString:[aDictionary valueForKey:@"AssignmentEventMessage"]] autorelease];

	// release the raw data
	[aDictionary release];
	
    return template;
}

- (NSString *)interpret:(GRLDatabase *)base message:(NSString *)message forStudent:(StudentObj *)stud
{
    message = [[message componentsSeparatedByString:@"%S"] componentsJoinedByString:[stud name]];
    message = [[message componentsSeparatedByString:@"%D"] componentsJoinedByString:[NSString stringWithFormat:@"%d",missingCount]];
    message = [[message componentsSeparatedByString:@"%B"] componentsJoinedByString:[DateUtils dateAsHeaderString:previousLastTimeChecked]];
    message = [[message componentsSeparatedByString:@"%E"] componentsJoinedByString:[DateUtils dateAsHeaderString:lastTimeChecked]];
    
    message = [super interpret:base message:message forStudent:stud];
    
    return message;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self)
        missingCount = [[coder decodeObjectForKey:@"count"] integerValue];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:[NSNumber numberWithInteger:missingCount] forKey:@"count"];
}

@end
