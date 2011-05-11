//
//  NSDate+Helper.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "NSDate+Helper.h"

@implementation DateHelper
@synthesize formatter = t_formatter, calendar = t_calendar, modFormatter = t_modFormatter;

+ (id)sharedDateHelper
{
	static dispatch_once_t pred;
	static DateHelper *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}

- (id)init {
	if ((self=[super init])) {
		t_formatter = nil;
		t_modFormatter = nil;
		t_calendar = nil;

	}
	return self;
}

- (void)dealloc {
	[t_formatter release];
	[t_modFormatter release];
	[t_calendar release];
	[super dealloc];
}

- (NSDateFormatter *)modFormatter {
	if (!t_modFormatter)
		t_modFormatter = [[NSDateFormatter alloc] init];
	return t_modFormatter;
}

- (NSDateFormatter *)formatter {
	if (!t_formatter)
		t_formatter = [[NSDateFormatter alloc] init];
	return t_formatter;
}

- (NSCalendar *)calendar {
	if (!t_calendar)
		t_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	return t_calendar;
}

@end

@implementation NSDate (Helper)

- (BOOL) equalsDefaultDate {
	NSDateFormatter *formatter = [[DateHelper sharedDateHelper] formatter];
	BOOL equals = [self isEqualToDate:[formatter defaultDate]];
	return equals;
}

// This is lengthy, for the sake of getting a known weekday string (Sunday, Monday, Tuesday ...) no matter where this NSDate is located.
- (NSString *)localWeekdayString {
	NSCalendar *gregorian = [[DateHelper sharedDateHelper] calendar];
	NSDateFormatter *weekdayFormatter = [[DateHelper sharedDateHelper] modFormatter];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[weekdayFormatter setCalendar:gregorian];
	[weekdayFormatter setLocale:usLocale];
	[weekdayFormatter setDateFormat:@"EEEE"];
	NSString *weekday = [weekdayFormatter stringFromDate:self];
	if (usLocale) [usLocale release], usLocale = nil;
	
	return weekday;
}

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
	NSCalendar *calendar = [[DateHelper sharedDateHelper] calendar];
	NSDateComponents *components = [calendar components:(NSDayCalendarUnit) 
											   fromDate:self
												 toDate:[NSDate date]
												options:0];
	return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
	// get a midnight version of ourself:
	NSDateFormatter *mdf = [[DateHelper sharedDateHelper] modFormatter];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
	
	return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo {
	return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
	NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
	NSString *text = nil;
	switch (daysAgo) {
		case 0:
			text = @"Today";
			break;
		case 1:
			text = @"Yesterday";
			break;
		default:
			text = [NSString stringWithFormat:@"%d days ago", daysAgo];
	}
	return text;
}

- (NSUInteger)weekday {
	NSCalendar *calendar = [[DateHelper sharedDateHelper] calendar];
	NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:self];
	return [weekdayComponents weekday];
}

- (NSUInteger)year {
	NSCalendar *calendar = [[DateHelper sharedDateHelper] calendar];
	NSDateComponents *yearComponents = [calendar components:(NSYearCalendarUnit) fromDate:self];
	return [yearComponents year];
}

+ (NSDate *)dateFromString:(NSString *)string {
	return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
	NSDateFormatter *inputFormatter = [[DateHelper sharedDateHelper] modFormatter];
	[inputFormatter setDateFormat:format];
	NSDate *date = [inputFormatter dateFromString:string];
	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
	return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date {
	return [date string];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
	/* 
	 * if the date is in today, display 12-hour time with meridian,
	 * if it is within the last 7 days, display weekday name (Friday)
	 * if within the calendar year, display as Jan 23
	 * else display as Nov 11, 2008
	 */
	
	NSDate *today = [NSDate date];
	NSCalendar *calendar = [[DateHelper sharedDateHelper] calendar];
	NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
													 fromDate:today];
	
	NSDate *midnight = [calendar dateFromComponents:offsetComponents];
	
	NSDateFormatter *displayFormatter = [[DateHelper sharedDateHelper] modFormatter];
	NSString *displayString = nil;
	
	// comparing against midnight
	if ([date compare:midnight] == NSOrderedDescending) {
		if (prefixed) {
			[displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
		} else {
			[displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
		}
	} else {
		// check if date is within last 7 days
		NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
		[componentsToSubtract setDay:-7];
		NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
		[componentsToSubtract release];
		if ([date compare:lastweek] == NSOrderedDescending) {
			[displayFormatter setDateFormat:@"EEEE"]; // Tuesday
		} else {
			// check if same calendar year
			NSInteger thisYear = [offsetComponents year];
			
			NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
														   fromDate:date];
			NSInteger thatYear = [dateComponents year];			
			if (thatYear >= thisYear) {
				[displayFormatter setDateFormat:@"MMM d"];
			} else {
				[displayFormatter setDateFormat:@"MMM d, yyyy"];
			}
		}
		if (prefixed) {
			NSString *dateFormat = [displayFormatter dateFormat];
			NSString *prefix = @"'on' ";
			[displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
		}
	}
	
	// use display formatter to return formatted date string
	displayString = [displayFormatter stringFromDate:date];
	return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
	return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSString *)stringWithFormat:(NSString *)format {
	NSDateFormatter *outputFormatter = [[DateHelper sharedDateHelper] modFormatter];
	[outputFormatter setDateFormat:format];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
	return timestamp_str;
}

- (NSString *)string {
	return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
	NSDateFormatter *outputFormatter = [[DateHelper sharedDateHelper] modFormatter];
	[outputFormatter setDateStyle:dateStyle];
	[outputFormatter setTimeStyle:timeStyle];
	NSString *outputString = [outputFormatter stringFromDate:self];
	return outputString;
}

- (NSDate *)beginningOfWeek {
	// largely borrowed from "Date and Time Programming Guide for Cocoa"
	// we'll use the default calendar and hope for the best
	
	NSCalendar *calendar = [[DateHelper sharedDateHelper] calendar];
	NSDate *beginningOfWeek = nil;
	BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek
						   interval:NULL forDate:self];
	if (ok) {
		return beginningOfWeek;
	} 
	
	// couldn't calc via range, so try to grab Sunday, assuming gregorian style
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	
	/*
	 Create a date components to represent the number of days to subtract from the current date.
	 The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
	 */
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
	beginningOfWeek = nil;
	beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
	[componentsToSubtract release];
	
	//normalize to midnight, extract the year, month, and day components and create a new date from those components.
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
											   fromDate:beginningOfWeek];
	return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
	NSCalendar *calendar = [[DateHelper sharedDateHelper] calendar];
	// Get the weekday component of the current date
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
											   fromDate:self];
	return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
	NSCalendar *calendar = [[DateHelper sharedDateHelper] calendar];
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
	// to get the end of week for a particular date, add (7 - weekday) days
	[componentsToAdd setDay:(7 - [weekdayComponents weekday])];
	NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
	[componentsToAdd release];
	
	return endOfWeek;
}

+ (NSString *)dateFormatString {
	return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString {
	return @"HH:mm:ss";
}

+ (NSString *)timestampFormatString {
	return @"yyyy-MM-dd HH:mm:ss";
}

// preserving for compatibility
+ (NSString *)dbFormatString {	
	return [NSDate timestampFormatString];
}

#pragma mark -
#pragma mark Comparison

- (BOOL) isEarlierThanDate:(NSDate *)laterDate {
	return ([self compare:laterDate] != NSOrderedDescending); // sooner is before later
}

#pragma mark -
#pragma mark Timestamp

- (NSString *)timestampString {
	NSString *stampString = [self stringWithFormat:[NSDate timestampFormatString]];
	return stampString;
}

+ (NSDate *)dateFromTimestampString:(NSString *)timestamp {
	NSDate *aDate = [NSDate dateFromString:timestamp withFormat:[NSDate timestampFormatString]];
	return aDate;
}

#pragma mark -
#pragma mark Time Zone Conversion

+ (NSDate *)dateFromDate:(NSDate *)sourceDate fromTimeZone:(NSString *)tzAbbrev {
	// The date in your source timezone (eg. EST)	
																	// @"EST", @"CST", @"UTC", @"GMT"
	NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:tzAbbrev];
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
	
	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
	NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
	NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
	
	return [sourceDate dateByAddingTimeInterval:interval];	
}

@end