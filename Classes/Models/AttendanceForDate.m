// 
//  AttendanceForDate.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "AttendanceForDate.h"
#import "DocumentPreferences.h"
#import "StudentObj.h"

@implementation AttendanceForDate 

@dynamic date;
@dynamic attendanceCode;
@dynamic student;

+ (AttendanceForDate *)insertNewAttendanceWithStudent:(StudentObj*)aStud withContext:(NSManagedObjectContext *)context {	
	NSManagedObjectModel *managedObjectModel = [[context persistentStoreCoordinator] managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:@"AttendanceForDate"];
	AttendanceForDate *newObject = (AttendanceForDate *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	newObject.student = aStud;
	
	[newObject addObserver:aStud
		   forKeyPath:@"attendanceCode" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:context];

	return [newObject autorelease];
}

- (NSString *)stringDescription {
    return [NSString stringWithFormat:@"Student: %@; Date: %@; Code: %@", self.student.name, self.date, self.attendanceCode];
}

- (void) awakeFromFetch {
	[super awakeFromFetch];
		
	[self addObserver:self.student
		   forKeyPath:@"attendanceCode" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:[self managedObjectContext]];
	
	// [self addObserver:self.student
	// forKeyPath:@"collectionCode"
	// //options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
	// options:(NSKeyValueObservingOptionNew)
	// context:[self managedObjectContext]];
	
}

- (void) prepareForDeletion {
	//NSLog(@"Delete: %@", [self stringDescription]);

	[self removeObserver:self.student forKeyPath:@"attendanceCode"];
	////[self removeObserver:self.student forKeyPath:@"collectionCode"];
	
	[super prepareForDeletion];
}


- (void) dealloc {
	//NSLog(@"dealloc!!!!");
	[super dealloc];
}

- (NSColor *)cellColorWithPrefs:(DocumentPreferences *)prefs {
    NSColor *color = nil;
		
	if (prefs) {
		switch([self.attendanceCode integerValue])
		{
			case GRLExcused:		color = [prefs colorForKey:@"excusedColor"];
				break;
			case GRLAbsent:		color =  [prefs colorForKey:@"absentColor"];
				break;
			case GRLLate:			color =  [prefs colorForKey:@"lateColor"];
				break;
			case GRLTardy: 		color =  [prefs colorForKey:@"tardyColor"];
				break;
			default:				color = nil;
				break;
		}
	}
	return color;
}

- (NSString *)abbreviatedString
{
    switch([self.attendanceCode integerValue])
    {
        case GRLExcused:		return @"ex";
			break;
        case GRLAbsent:		return @"ab";
			break;
        case GRLLate: 		return @"la";
			break;
        case GRLTardy: 		return @"ta";
			break;
        default:		return @"";
			break;
    }
}


- (NSString *)string
{
	return [AttendanceForDate stringForCode:[self.attendanceCode integerValue]];
}

// This handles abbreviated strings or full strings ... not very robust, but it should work fine.
+ (GRLCode)codeForString:(NSString *)string
{
	string = [string lowercaseString];
	
	//if([string isEqualToString:@"ex"])
    if([string hasPrefix:@"ex"])
        return GRLExcused;
    else if([string hasPrefix:@"ab"])
        return GRLAbsent;
    else if([string hasPrefix:@"la"])
        return GRLLate;
    else if([string hasPrefix:@"ta"])
        return GRLTardy;
    else
        return -1;
}

- (void)setAttendanceWithString:(NSString *)string {
	GRLCode aCode = [AttendanceForDate codeForString:string];
	
	if (aCode != [self.attendanceCode integerValue]) {
		self.attendanceCode = [NSNumber numberWithInteger:aCode];
	}
}


+ (NSString *)stringForCode:(GRLCode)code
{
    switch(code)
    {
        case GRLExcused:		return @"Excused";
			break;
        case GRLAbsent:		return @"Absent";
			break;
        case GRLLate: 		return @"Late";
			break;
        case GRLTardy: 		return @"Tardy";
			break;
        default:		return @"";
			break;
    }
}

@end
