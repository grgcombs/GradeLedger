//
//  AttendanceForDate.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

@class StudentObj;
@class DocumentPreferences;

@interface AttendanceForDate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * attendanceCode;
@property (nonatomic, retain) StudentObj * student;

+ (AttendanceForDate *)insertNewAttendanceWithStudent:(StudentObj*)aStud withContext:(NSManagedObjectContext *)context;

- (NSString *)string;
- (NSString *)abbreviatedString;
- (void)setAttendanceWithString:(NSString *)string;
- (NSColor *)cellColorWithPrefs:(DocumentPreferences *)prefs;

+ (NSString *)stringForCode:(GRLCode)code;
//+ (GRLCode)codeForString:(NSString *)string;

@end



