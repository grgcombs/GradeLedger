//
//  DateUtils.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "NSDate+Helper.h"
#import "DateUtils.h"

#define kCalendar [[DateHelper sharedDateHelper] calendar]

@implementation DateUtils

/*
 #define kUnitFlags NSYearCalendarUnit | NSMonthCalendarUnit |  NSWeekdayCalendarUnit | NSDayCalendarUnit

+ (NSUInteger) unitFlags {
	return kUnitFlags; 
}

+ (NSCalendar *) calendar {
	return kCalendar;
}

+ (NSString *)stringFromDate:(NSDate *)aDate withFormat:(NSString *)formStr {
	if (!aDate)
		return nil;
	
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setCalendar:kCalendar];
	[format setFormatterBehavior:NSDateFormatterBehavior10_4];
	[format setDateStyle:NSDateFormatterNoStyle];
	[format setTimeStyle:NSDateFormatterNoStyle];
	[format setDateFormat:formStr];				
	NSString *dateStr = [format stringFromDate:aDate];	
	[format release];
	return dateStr;
}

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)formStr {
	if(!dateString)
		return nil;
	NSDateFormatter *form = [[[NSDateFormatter alloc] init] autorelease];
	[form setFormatterBehavior:NSDateFormatterBehavior10_4];
	[form setTimeStyle:NSDateFormatterNoStyle];
	[form setDateStyle:NSDateFormatterNoStyle];
	[form setLenient:YES];
	[form setCalendar:kCalendar];
	[form setDateFormat:formStr];
	return [form dateFromString:dateString];
	
}
*/
+ (NSString *)timeStampNow {
	return [[NSDate date] stringWithFormat:kGRLTimestampFormat];
	//return [DateUtils stringFromDate:[NSDate date] withFormat:kGRLTimestampFormat];
}

+ (NSString *)dateAsHeaderString:(NSDate *)aDate {	
	return [aDate stringWithFormat:kGRLDateHeaderFormat];
//	return [DateUtils stringFromDate:aDate withFormat:kGRLDateHeaderFormat];
}

+ (NSDate *)dateFromHeaderString:(NSString *)aString {
	return [NSDate dateFromString:aString withFormat:kGRLDateHeaderFormat];
	//return [DateUtils dateFromString:aString withFormat:kGRLDateHeaderFormat];
}

+ (NSInteger) dayOfWeekForDate:(NSDate *)aDate {
	//NSDateComponents *dateComponents = [kCalendar components:kUnitFlags fromDate:aDate];
	//NSInteger dayOfWeek = [dateComponents weekday] - 1;		// weekday needs to be offset by 1 to match
	NSInteger dayOfWeek = [aDate weekday] - 1;
	return dayOfWeek;
}

+ (NSDate *)setDaysFromDate:(NSDate *)aDay numDays:(NSInteger)interval {
	NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setDay:interval];
	aDay = [kCalendar dateByAddingComponents:dateComponents toDate:aDay options:0];	// advance 1 day in loop
	[dateComponents release];
	
	return aDay;	
}

+ (NSDate *)setWeeksFromDate:(NSDate *)aDay numWeeks:(NSInteger)interval {
	NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setWeek:interval];
	aDay = [kCalendar dateByAddingComponents:dateComponents toDate:aDay options:0];	// advance 1 day in loop
	[dateComponents release];
	
	return [aDay beginningOfDay];	
}

+ (NSDate *)setMonthsFromDate:(NSDate *)aDay numMonths:(NSInteger)interval {
	NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setMonth:interval];
	aDay = [kCalendar dateByAddingComponents:dateComponents toDate:aDay options:0];	// advance 1 day in loop
	[dateComponents release];
	
	return [aDay beginningOfDay];	
}


+ (NSDate *)today {
	return [[NSDate date] beginningOfDay];
}

+ (NSDate *)yesterday {
	return [DateUtils previousDayFromDate:[DateUtils today]];
}

+ (NSDate *)tomorrow {
	return [DateUtils nextDayFromDate:[DateUtils today]];
}

+ (NSDate *)previousDayFromDate:(NSDate *)aDay {
	return [DateUtils setDaysFromDate:aDay numDays:-1];
}

+ (NSDate *)nextDayFromDate:(NSDate *)aDay {
	return [DateUtils setDaysFromDate:aDay numDays:1];
}


+ (BOOL) isEarlier:(NSDate *)soonerDate thanDate:(NSDate *)laterDate {
	return [soonerDate isEarlierThanDate:laterDate];
	//return ([soonerDate compare:laterDate] != NSOrderedDescending); // sooner is before later
}

@end
