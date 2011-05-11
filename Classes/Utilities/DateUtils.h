//
//  DateUtils.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#define kGRLDateShortFormat @"M/d/yyyy"						// i.e. "3/9/2010"
#define kGRLDateHeaderFormat @"EEE MM/dd/YY"					// i.e. "Mon 03/01/10"
//#define kGRLDateHeaderFormat @"EEEE M/d/YYYY"				// i.e. "Monday 3/1/2010"
//#define kGRLDateHeaderFormat	@"EEE MMM d, YYYY"			// i.e. "Mon Mar 1, 2010"

#define kGRLTimestampFormat @"MMM d, YYYY h:mm:ss a"			// i.e. "Jun 9, 2010 04:15:21 PM


@interface DateUtils : NSObject {
}

+ (NSString *)timeStampNow;

+ (NSString *)stringFromDate:(NSDate *)aDate withFormat:(NSString *)formStr;
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)formStr;

+ (NSString *)dateAsHeaderString:(NSDate *)aDate;
+ (NSDate *)dateFromHeaderString:(NSString *)aString;

+ (NSCalendar *)calendar;
+ (NSUInteger) unitFlags;

+ (NSInteger) dayOfWeekForDate:(NSDate *)aDate;
+ (NSDate *)today;
+ (NSDate *)yesterday;
+ (NSDate *)tomorrow;
+ (NSDate *)previousDayFromDate:(NSDate *)aDay;
+ (NSDate *)nextDayFromDate:(NSDate *)aDay;
+ (BOOL) isEarlier:(NSDate *)soonerDate thanDate:(NSDate *)laterDate;

+ (NSDate *)setDaysFromDate:(NSDate *)aDay numDays:(NSInteger)interval;
+ (NSDate *)setWeeksFromDate:(NSDate *)aDay numWeeks:(NSInteger)interval;
+ (NSDate *)setMonthsFromDate:(NSDate *)aDay numMonths:(NSInteger)interval;
	

@end
