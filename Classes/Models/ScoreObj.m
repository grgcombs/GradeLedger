// 
//  ScoreObj.m
//  GradeLedger
//
//  Created by Gregory Combs on 4/16/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "ScoreObj.h"
#import "CategoryObj.h"
#import "AssignmentObj.h"
#import "StudentObj.h"
#import "AttendanceForDate.h"
#import "DocumentPreferences.h"
#import "GRLFunction.h"
#import "NSDate+Helper.h"

@interface ScoreObj (Private)
- (NSString *)stringWithFloatPrecision:(CGFloat)aNumber;
@end
	
@implementation ScoreObj 

@dynamic score;
@dynamic collectionCode;
@dynamic notes;
@dynamic collectionDate;
@dynamic assignment;
@dynamic student;

+ (ScoreObj *)insertNewScoreWithStudent:(StudentObj*)aStud andContext:(NSManagedObjectContext *)context {	
	NSManagedObjectModel *managedObjectModel = [[context persistentStoreCoordinator] managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:@"ScoreObj"];
	ScoreObj *newObject = (ScoreObj *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	newObject.student = aStud;
	
	// we've already got this set up for fetches, we only need to do this for new inserts, and we do it now that we've set "student"
	[newObject addObserver:aStud
			forKeyPath:@"score" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:context];
	
	return [newObject autorelease];
}


- (void) awakeFromFetch {
	[super awakeFromFetch];

	[self addObserver:self.student
		   forKeyPath:@"score" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:[self managedObjectContext]];
	
// [self addObserver:self.student
// forKeyPath:@"collectionCode"
// //options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
// options:(NSKeyValueObservingOptionNew)
// context:[self managedObjectContext]];
	
}

- (NSDictionary *)exportDictionary {
	NSMutableDictionary *dict = nil;
	if (NO == [self.assignment isAttendance]) {
		NSArray *props = [[NSArray alloc] initWithObjects:
						  @"score", @"collectionCode", @"notes", @"collectionDate", nil];

		dict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithValuesForKeys:props]];
		NSDate *tempDate = self.collectionDate;
		if (tempDate)
			[dict setObject:[tempDate timestampString] forKey:@"collectionDate"];
		
		[props release];
	}
	
    return dict;
}


- (void) prepareForDeletion {
	[self removeObserver:self.student forKeyPath:@"score"];
	////[self removeObserver:self.student forKeyPath:@"collectionCode"];
	[super prepareForDeletion];
}

- (NSColor *)cellColorWithPrefs:(DocumentPreferences *)prefs {
    NSColor *color = nil;
	
	if (prefs) {
		switch([self.collectionCode integerValue])
		{
			case GRLExcused:		color = [prefs colorForKey:@"excusedColor"];
				break;
			case GRLAbsent:		color =  [prefs colorForKey:@"absentColor"];
				break;
			case GRLLate:		color =  [prefs colorForKey:@"lateColor"];
				break;
			case GRLTardy: 		color =  [prefs colorForKey:@"tardyColor"];
				break;
			default:			color = nil;
				break;
		}
	}
	
	return color;
}

- (NSString *)collectionString
{
    switch([self.collectionCode integerValue])
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


- (NSString *)abbreviatedCollectionString
{
    switch([self.collectionCode integerValue])
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

- (BOOL)validScore
{
	//NSLog(@"self.score = %@", [self.score description]);
    return ([self.score integerValue] < NSNotFound);
}

- (BOOL)willBeGraded {
	NSDate *today = [[NSDate date] beginningOfDay];
	NSDate *dueDate = self.assignment.dueDate;
	if (dueDate) 
		dueDate = [dueDate beginningOfDay];
	
	// For scoring, we focus on assignments without a due date, or ones that are already due. 
	BOOL isNotTooSoon = (!dueDate || [dueDate isEarlierThanDate:today]);
	BOOL isNotExcused = ([self.collectionCode integerValue] != GRLExcused);
	
	//ignore scores that aren't due or are unset, also ignore excused assignments
	if([self validScore] && isNotTooSoon && isNotExcused)
		return YES;
	
	return NO;
}

- (CGFloat)rawScore
{
    if([self validScore])
        return [self.score floatValue];
    else
        return 0;
}

// penalties and curves added to score if necessary
- (CGFloat)curvedScore
{
	CGFloat aGrade = self.rawScore;
	NSInteger penalty = 0;
	NSString * paramString = nil;
	
	if (aGrade <= 0) return aGrade;
	
	// determine the preferences key to search for
	switch ([self.collectionCode integerValue]) {
		case GRLLate:
			paramString = @"latePenalty";
			break;
		case GRLTardy:
			paramString = @"tardyPenalty";
			break;
		case GRLAbsent:
			paramString = @"absentPenalty";
			break;
		default:
			break;
	}
	
	if (paramString) {
		// search for a stored preference in our Core Data
		NSManagedObject *parameter = [DocumentPreferences findParameter:paramString withContext:[self managedObjectContext]];
		if (parameter)
			penalty = [[parameter valueForKey:@"value" ] integerValue];		// this will be an NSNumber
		
		if (penalty > 0)
			aGrade *= (100 - penalty)/100.0;	// apply the penalty to our grade
	}
	
	// now apply the curve, if necessary
	if([self.assignment.curveEquation length])
		aGrade = [[self.assignment curveFunction] evaluateAtX:aGrade];            
	
	return aGrade;
	
}

#pragma mark Attendance Score
// we cheat a little and use a score object just to keep track of the student and assignment ... ignoring the score value
- (CGFloat)attendanceScoreWithPrefs:(DocumentPreferences *)preferences {
	CGFloat attendRec = 0;
	
	////////////////// WE NEED TO DO A SPECIAL PLACE FOR ATTENDANCE RECORDS IF WE FOLLOW THROUGH WITH THIS.....
	// because chances are we don't actually have a ScoreObj for student attendance when this is called
	
	if ([self.assignment isAttendance]) {	// this is an "attendance" category
		
		attendRec = [self.assignment.maxPoints floatValue];
		NSInteger numClasses = [preferences numberOfClassDaysThusFar];
		if (numClasses > 0)// we have to have some classes
		{	
			NSInteger numAbsences = [[self.student attendanceAbsences] integerValue]; // if they cut class or were unexcused
			NSInteger numTardies = [[self.student attendanceTardies] integerValue]; // if they were late to class
			
			if ([[preferences valueForKey:@"tardiesForAbsence"] integerValue] > 0) {
				numAbsences += (numTardies/[[preferences valueForKey:@"tardiesForAbsence"] integerValue]) ;
			}
			
			/* attendance score is recorded as a percentage of the maximum points (.98 * 100) or (.98 * 5)
			 So if they miss 10 days out of 80, and this attendance *assignment* (not category) is worth a maximum of 5 points
			 Then they're looking at a score of 4.375 out of 5.0 ... if we see the assignment is out of 100 maximum, then
			 the resulting score would *appear* in the table as 87.5 (percent), even if the category still adds only 4.375 points to the final grade */
			attendRec =  ((((CGFloat)numClasses - (CGFloat)numAbsences) / (CGFloat)numClasses) * [self.assignment.maxPoints floatValue]);
		}
		
		// we should silently change the attendance score so don't let the undo manager "dirty" the document
		[[[self managedObjectContext] undoManager] disableUndoRegistration];
		
		// Set the score to the attendance record.  We can probably find a better place for this somewhere else
		//score.score = [NSNumber numberWithFloat:attendRec];	
		[self setPrimitiveValue:[NSNumber numberWithFloat:attendRec] forKey:@"score"];
		
		// now tell core data to remember our change and turn the undo manager back on
		[[self managedObjectContext] processPendingChanges];
		[[[self managedObjectContext] undoManager] enableUndoRegistration];
		
	}
	return attendRec;
}

#pragma mark Assignment Score

/* how much precision do you want in that grade's decimal point? */
- (NSString *)stringWithFloatPrecision:(CGFloat)aNumber {
	NSString *format = nil;
	
	if(aNumber < 10 && (aNumber - (NSInteger)aNumber) > 0.009)
		format = @"%.2f";
	else if(aNumber < 100 && (aNumber - (NSInteger)aNumber) > 0.09)
		format = @"%.1f";
	else
		format = @"%.0f";
	return [NSString stringWithFormat:format,aNumber];
}

// This gives us the single grade dict for a particular cell / nexus of student & assignment
- (NSDictionary *)calculateAssignmentScoreWithPrefs:(DocumentPreferences *)preferences 
{	
	// set up an empty score dictionary
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"raw", @"", @"curved", nil];
	
	if (self.assignment && [self.assignment isAttendance]) {	// this is an "attendance" category
		CGFloat rawFloat = [self attendanceScoreWithPrefs:preferences];
		if (rawFloat >= 0 )
			[dict setObject:[self stringWithFloatPrecision:rawFloat] forKey:@"raw"];
	}
	else {
		if (self.rawScore >= 0 )
			[dict setObject:[self stringWithFloatPrecision:self.rawScore] forKey:@"raw"];
	}
	
	CGFloat curveFloat = self.curvedScore;
	if (curveFloat >= 0)
		[dict setObject:[self stringWithFloatPrecision:curveFloat] forKey:@"curved"];
	
    return dict;
}



@end
