/*

h2. NSDate (Helper)

This is a category for the @NSDate@ class that provides some convenience methods for working with @NSDate@ objects and displaying formatted and relative strings.

More information can be found at my "initial blog post":http://www.zetetic.net/blog/2009/03/11/nsdate-helper/.

Anyone is welcome to use it for anything, and to change it as they see fit. If you'd like to contribute back any changes (woot!), please fork and send a pull request!

h3. Usage

Full documentation is now up "on the Github wiki for this project":http://wiki.github.com/billymeltdown/nsdate-helper It's a lot better than this kinda rambling overview here.

Two convenience methods make it easy for you to display some relative date information. @stringForDisplayFromDate@ gives you the kind of relative format you see in the Notes listing on the iPhone:

<pre><code>
  NSString *displayString = [NSDate stringForDisplayFromDate:date];
</code></pre>
  
This produces the following kinds of output:
  
* '3:42 AM' - if the date is after midnight today
* 'Tuesday' - if the date is within the last seven days
* 'Mar 1' - if the date is within the current calendar year
* 'Mar 1, 2008' - else ;-)
  
<pre><code>
  NSString *displayString = [NSDate stringForDisplayFromDate:date prefixed:YES];
</code></pre>
  
This produces the same as above, but prefixed with 'at' or 'on' depending on the appropriate English syntax.

Another set of methods provide days-ago information:

<pre><code>
  NSDate *date = [NSDate date];
  [date daysAgo]; // provides an NSComponent-based NSUInteger describing days ago.
  [date daysAgoAgainstMidnight]; // better version of daysAgo, works off midnight (hat-tip: "sburlot":http://github.com/sburlot)
  [date stringDaysAgo]; // 'Today', 'Yesterday', or 'N days ago'.
</code></pre>
  
Tired of creating and releasing date formatters? Missing things like @to_s(:db)@? Me, too. @NSDate (Helper)@ has some static methods to make going back and forth between strings and dates a little less painful, and particularly easier when working with database timestamps (a la SQLite):

<pre><code>
  NSDate *date = [NSDate dateFromString:@"2009-03-01 12:15:23"]; 
  NSString *dbDateString = [NSDate stringFromDate:date]; // returns '2009-03-01 12:15:23'
</code></pre>
  
Who needs NSDateFormatter?
  
  NSString *otherDateString = [NSDate stringFromDate:date withFormat:@"EEEE"]; // use any format you like

h3. Installation

To use it in your Cocoa project, import the header and implementation files, and then add the header to your project's <projectname>_prefix.pch file so that it's available across your project:
  
<pre><code>
#ifdef __OBJC__
    #import <Foundation/Foundation.h>
    #import <UIKit/UIKit.h>
    #import "NSDate+Helper.h"
#endif
</code></pre>


*/


//
//  NSDate+Helper.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//


@interface DateHelper : NSObject
{
	NSDateFormatter *t_modFormatter;
	NSDateFormatter *t_formatter;
	NSCalendar *t_calendar;
}
@property (nonatomic, readonly) NSDateFormatter *modFormatter;
@property (nonatomic, readonly) NSDateFormatter *formatter;
@property (nonatomic, readonly) NSCalendar *calendar;

+ (id)sharedDateHelper;
@end


@interface NSDate (Helper)
- (BOOL)equalsDefaultDate;

- (NSUInteger)daysAgo;
- (NSUInteger)daysAgoAgainstMidnight;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger)weekday;
- (NSUInteger)year;
- (NSString *)localWeekdayString;

+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;

- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfDay;
- (NSDate *)endOfWeek;

- (BOOL) isEarlierThanDate:(NSDate *)laterDate;


+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;

- (NSString *)timestampString;
+ (NSDate *)dateFromTimestampString:(NSString *)timestamp;

+ (NSDate *)dateFromDate:(NSDate *)sourceDate fromTimeZone:(NSString *)tzAbbrev;

@end