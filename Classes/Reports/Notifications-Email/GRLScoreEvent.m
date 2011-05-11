//
//  GRLScoreEvent.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLScoreEvent.h"
#import "StudentObj.h"
#import "ScoreObj.h"
#import "DateUtils.h"

@implementation GRLScoreEvent

@synthesize finalScore, belowScore;

- (id)initWithFirstTime:(NSDate *)date
{
    if((self = [super initWithFirstTime:date]))
    {
        finalScore = 0;
        belowScore = YES;
    }
    return self;
}


- (BOOL)eventShouldOccur:(GRLDatabase *)base forStudent:(StudentObj *)stud
{
    NSString *score = stud.gradeTotal;
    
    if((belowScore && [score integerValue] < finalScore) || (!belowScore && [score integerValue] > finalScore))
        return YES;
    else
        return NO;
}

+ (NSString *)defaultMessage
{
	// GREG -- pull our template from a plist ... not the most graceful, but it's easy-peasy.
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"GRLEmailTemplate" ofType:@"plist"];
	NSDictionary *aDictionary = [[NSDictionary alloc] initWithContentsOfFile:thePath];
	
	NSString *template = [[[NSString alloc] initWithString:[aDictionary valueForKey:@"GradeEventMessage"]] autorelease];
	
	// release the raw data
	[aDictionary release];
	
    return template;
}

- (NSString *)interpret:(GRLDatabase *)base message:(NSString *)message forStudent:(StudentObj *)stud
{
    NSString *aboveBelow = nil;
    if(belowScore)
        aboveBelow = @"below";
    else
        aboveBelow = @"above";

    message = [[message componentsSeparatedByString:@"%S"] componentsJoinedByString:[stud name]];
    message = [[message componentsSeparatedByString:@"%A"] componentsJoinedByString:aboveBelow];
    message = [[message componentsSeparatedByString:@"%D"] componentsJoinedByString:[NSString stringWithFormat:@"%d",finalScore]];
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
        finalScore = [[coder decodeObjectForKey:@"finalScore"] integerValue];
        belowScore = [[coder decodeObjectForKey:@"belowScore"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:[NSNumber numberWithInteger:finalScore] forKey:@"finalScore"];
    [coder encodeObject:[NSNumber numberWithInteger:belowScore] forKey:@"belowScore"];
}


@end
