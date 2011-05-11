// 
//  StudentObj.m
//  GradeLedger
//
//  Created by Gregory Combs on 4/17/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "StudentObj.h"
#import "CategoryObj.h"
#import "AssignmentObj.h"
#import "AttendanceForDate.h"
#import "ScoreObj.h"

#import "GRLFunction.h"
#import "GRLDefines.h"
#import "DateUtils.h"
#import "NSManagedObjectContext+EZFetch.h"
#import "DocumentPreferences.h"
#import "NSData+Base64.h"

@interface StudentObj (Private)
- (CGFloat)calculatePreciseFinalScore;
- (NSString *)stringWithFloatPrecision:(CGFloat)aNumber;
@end


@implementation StudentObj 

@dynamic firstName;
@dynamic lastName;
@dynamic name;
@dynamic lastNameFirst;
@dynamic emailAddress;
@dynamic studentID;
@dynamic notes;
@dynamic scores;
@dynamic attendanceForDates;
@dynamic studentAttributes;
@dynamic image;
@dynamic attendanceAbsences;
@dynamic attendanceExcused;
@dynamic attendanceTardies;
@dynamic gradeTotal;


+ (StudentObj *)insertNewStudentWithContext:(NSManagedObjectContext *)context {	
	NSManagedObjectModel *managedObjectModel = [[context persistentStoreCoordinator] managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:@"StudentObj"];
	StudentObj *newObject = (StudentObj *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	return [newObject autorelease];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([object isKindOfClass:[ScoreObj class]] || [object isKindOfClass:[AttendanceForDate class]] || [object isKindOfClass:[DocumentPreferences class]]) {
		[self refreshGradeTotal:object];
		
		//NSLog(@"Observing KEY: %@  Student: %@    NEWVALUE: %@     OLDVALUE: %@", keyPath, [object valueForKeyPath:@"student.name"],
		//  [change objectForKey:NSKeyValueChangeNewKey], [change objectForKey:NSKeyValueChangeOldKey]);
	}		
	else
		// be sure to call the super implementation if the superclass implements it
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

/*
 - (NSComparisonResult)compareStudentsByName:(StudentObj *)p
{	
	return [[self lastNameFirst] compare: [p lastNameFirst]];	
}
*/

+ (NSSet *)keyPathsForValuesAffectingName
{
    NSMutableSet* set = [NSMutableSet set];
    [set addObject:@"firstName"];
    [set addObject:@"lastName"];
    return set;
};

#pragma mark -
#pragma mark Property Accessors

- (NSDictionary *)exportDictionary {

	NSArray *props = [[NSArray alloc] initWithObjects:
					  @"emailAddress", @"studentID", @"lastName", @"firstName", 
					  @"gradeTotal", nil];	//@"studentAttributes", 
	NSMutableDictionary *exportDict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithValuesForKeys:props]];

	NSSet *tempScores = self.scores;
	if (tempScores && [tempScores count]) {
		NSSet *assignments = [self.scores valueForKeyPath:@"@distinctUnionOfObjects.assignment"];
		NSSet *categories = [assignments valueForKeyPath:@"@distinctUnionOfObjects.category"];
		
		NSMutableArray *catsArray = [[NSMutableArray alloc] init];
		for (CategoryObj *cat in categories) {
			NSMutableDictionary *tempCatDict = [[NSMutableDictionary alloc] initWithDictionary:[cat dictionaryRepresentation]];

			NSMutableArray *assArray = [[NSMutableArray alloc] init];
			for (AssignmentObj *ass in cat.assignments) {
				NSDictionary *assExpDict = [ass exportDictionary];
				if (assExpDict) {
					NSMutableDictionary *tempAssDict = [[NSMutableDictionary alloc] initWithDictionary:assExpDict];

					NSMutableSet *intersection = [NSMutableSet setWithSet:self.scores];
					[intersection intersectSet:ass.scores];
					if ([intersection count]) {
						ScoreObj *score = [intersection anyObject];
						NSDictionary *scoreDict = [score exportDictionary];
						if (scoreDict) {
							[tempAssDict setObject:scoreDict forKey:@"score"];
							[assArray addObject:tempAssDict];
						}						
					}

					[tempAssDict release];
				}
			}
			
			if ([assArray count]) {
				[tempCatDict setObject:assArray forKey:@"assignments"];
				[catsArray addObject:tempCatDict];
			}
			
			[assArray release];
			[tempCatDict release];
		}
		
		if ([catsArray count])
			[exportDict setObject:catsArray forKey:@"categories"];
		
		[catsArray release];
		
	}
	return exportDict;	
}

- (NSString *)name {
	NSString *fullName = nil;
	NSString *first =[self valueForKey:@"firstName"];
	NSString *last = [self valueForKey:@"lastName"];
	
	if (first && last)
		fullName = [NSString stringWithFormat:@"%@ %@", first, last];
	else if (first) 
		fullName = first;
	else if(last) 
		fullName = last;
	return fullName;
}

+ (NSSet *)keyPathsForValuesAffectingLastNameFirst
{
    NSMutableSet* set = [NSMutableSet set];
    [set addObject:@"firstName"];
    [set addObject:@"lastName"];
    return set;
};



- (NSString *)lastNameFirst {
	NSString *fullName = nil;
	NSString *first =[self valueForKey:@"firstName"];
	NSString *last = [self valueForKey:@"lastName"];
	
	if (first && last)
		fullName = [NSString stringWithFormat:@"%@, %@", last, first];
	else if (first) 
		fullName = first;
	else if(last) 
		fullName = last;
	return fullName;
}


#pragma mark -
#pragma mark Attendance Methods
/**************** ATTENDANCE METHODS */

- (AttendanceForDate *)attendanceForDate:(NSDate *)aDate {
    AttendanceForDate *attendance = nil;
	
    if ( aDate ) {
        // catch anything awkward
        @try {
			// Round off the time in the date, give us a nice round number.
			aDate = [aDate beginningOfDay];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.date == %@", aDate];
			NSSet *filteredSet = [[self attendanceForDates] filteredSetUsingPredicate:predicate];
			attendance = [filteredSet anyObject]; // we should only have one entry anyway.
        }
        // log
        @catch ( NSException *e ) {
            NSLog( @"An error occurred trying to get the attendance date from the student '%@': %@", self.name, e );
        }
		
		if (!attendance) // still nothing?
			attendance = [self blankAttendanceForDate:aDate];
    }
    
    return attendance;	
}

- (AttendanceForDate *)blankAttendanceForDate:(NSDate *)aDate {
	// we should silently change the attendance score so don't let the undo manager "dirty" the document
	[[[self managedObjectContext] undoManager] disableUndoRegistration];
			
	AttendanceForDate *attendance = [AttendanceForDate insertNewAttendanceWithStudent:self withContext:[self managedObjectContext]];
	attendance.date = aDate;
	//attendance.attendanceCode = [NSNumber numberWithInteger:GRLPresent]; // default to present
	[attendance setPrimitiveValue:[NSNumber numberWithInteger:GRLPresent] forKey:@"attendanceCode"];
	//attendance.student = self;				// do we need this???
		
	// now tell core data to remember our change and turn the undo manager back on
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] enableUndoRegistration];
	
	return attendance;
}


- (NSArray*)attendanceSortedByDate
{
	NSArray *sortByDateDesc = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
	return [[self.attendanceForDates allObjects] sortedArrayUsingDescriptors:sortByDateDesc];
}

- (void)setAttendanceWithString:(NSString *)aString forDate:(NSDate *)aDate {
	if (aDate) {

		aDate = [aDate beginningOfDay];
		
		AttendanceForDate *attendance = [self attendanceForDate:aDate];
				
		if (attendance) {			// we've got a proper object, just change the code
			[attendance setAttendanceWithString:aString];
		}
	}
	
}


// VERY CLEVER THIS ONE ...
- (NSUInteger)numberOfDaysWithAttendanceCode:(GRLCode)aCode {
	NSUInteger total = 0;	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.attendanceCode == %@", [NSNumber numberWithInteger:aCode]];
	NSSet *filteredSet = [[self attendanceForDates] filteredSetUsingPredicate:predicate];
	total = [filteredSet count];
	return total;
}


- (NSNumber *)attendanceAbsences 
{
    NSNumber * tmpValue;

    [self willAccessValueForKey:@"attendanceAbsences"];
	tmpValue = [NSNumber numberWithInteger:[self numberOfDaysWithAttendanceCode:GRLAbsent]];
    [self didAccessValueForKey:@"attendanceAbsences"];
    
    return tmpValue;
}

- (NSNumber *)attendanceExcused 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"attendanceExcused"];
	tmpValue = [NSNumber numberWithInteger:[self numberOfDaysWithAttendanceCode:GRLExcused]];
    [self didAccessValueForKey:@"attendanceExcused"];
    
    return tmpValue;
}


- (NSNumber *)attendanceTardies 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"attendanceTardies"];
	tmpValue = [NSNumber numberWithInteger:[self numberOfDaysWithAttendanceCode:GRLTardy]];
    [self didAccessValueForKey:@"attendanceTardies"];
    
    return tmpValue;
}




/******************************** SCORE METHODS */
#pragma mark Score Methods
- (ScoreObj *)scoreForAssignment:(AssignmentObj *)anAssignment {
	
    // Score to return
    ScoreObj *score = nil;
	
    if ( anAssignment ) {
		
        // catch anything awkward
        @try {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.assignment == %@", anAssignment];
			NSSet *filteredSet = [[self scores] filteredSetUsingPredicate:predicate];
			score = [filteredSet anyObject];	// JUST PICK ONE ... SHOULD ONLY BE ONE ANYWAY			
        }
        // log
        @catch ( NSException *e ) {
            NSLog( @"An error occurred trying to get the attendance date from the student '%@': %@", self.name, e );
        }
		
		// GREG ... should we do the attendance record grade calc here?????
		
		if(!score)	// still blank???
			score = [self blankScoreForAssignment:anAssignment];
    }
    // return the score
    return score;
}

- (ScoreObj *)blankScoreForAssignment:(AssignmentObj *)anAssignment {
	ScoreObj *score = [ScoreObj insertNewScoreWithStudent:self andContext:[self managedObjectContext]];
	//score.score = [NSNumber numberWithInteger:NSNotFound];
	[score setPrimitiveValue:[NSNumber numberWithInteger:NSNotFound] forKey:@"score"];
	score.notes = @"";
	score.assignment = anAssignment;	// do we need this???
	score.collectionCode = [NSNumber numberWithInteger:GRLPresent]; // default to turned in on time.
	//score.student = self;				// do we need this???

	return score;
}

////////// Copy/Paste .... CoreRecipes has a better Copy scheme that might work for studentAttributes
+ (NSArray *)keysToBeCopied {
    static NSArray *keysToBeCopied = nil;
    if (keysToBeCopied == nil) {
        keysToBeCopied = [[NSArray alloc] initWithObjects:
						  @"emailAddress", @"studentID", @"name", @"notes", @"image", nil];	//@"studentAttributes", 
    }
    return keysToBeCopied;
}

- (NSDictionary *)dictionaryRepresentation {
    return [self dictionaryWithValuesForKeys:[[self class] keysToBeCopied]];
}

- (NSString *)stringDescription {
    NSString *stringDescription = self.name;
    NSString *studentIDString = self.studentID;
    NSString *emailString = self.emailAddress;
    stringDescription = [stringDescription stringByAppendingFormat:
						 @"; Student ID: %@; Email: %@", studentIDString, emailString];
    return stringDescription;
}


#pragma mark -
#pragma mark - Grade Calculation

- (NSString *)gradeTotal {
	[self willAccessValueForKey:@"gradeTotal"];
	NSString *scoreString = [self primitiveValueForKey:@"gradeTotal"];
	[self didAccessValueForKey:@"gradeTotal"];
	
	if ([scoreString isEqualToString:@"NG"] || [scoreString isEqualToString:@"0"])
	{
		scoreString = [self stringWithFloatPrecision:[self calculatePreciseFinalScore]];
		[self willChangeValueForKey:@"gradeTotal"];
		[self setPrimitiveValue:scoreString forKey:@"gradeTotal"];
		[self didChangeValueForKey:@"gradeTotal"];

	}
	return scoreString;
	
}

/* how much precision do you want in that grade's decimal point? */
- (NSString *)stringWithFloatPrecision:(CGFloat)aNumber {
	NSString *format = @"%.1f";
	
	if (aNumber < 0) // if we've got an invalid number, send back a placeholder
		return @"NG";
/*	
	else if(aNumber < 10 && (aNumber - (NSInteger)aNumber) > 0.009)
		format = @"%.2f";
	else if(aNumber < 100 && (aNumber - (NSInteger)aNumber) > 0.09)
		format = @"%.1f";
	else
		format = @"%.0f";
*/

	return [NSString stringWithFormat:format,aNumber];
}

// WE CANNOT SIMPLY RUN THIS EVERY TIME SOMETHING CHANGES IN CORE DATA, WE'LL GET AN INFINITE LOOP, OBVIOUSLY
- (IBAction)refreshGradeTotal:(id)sender {
	//if ([sender isKindOfClass:[ScoreObj class]])
		NSLog(@"Refreshing Grade Total for %@: %@ (%@)", self.name, self.gradeTotal, [[sender class] description]);
	//if ([sender isKindOfClass:[AttendanceForDate class]])
	//	NSLog(@"Refreshing Grade Total for %@: %@ -- %@", self.name, [sender valueForKeyPath:@"date"], [sender valueForKeyPath:@"attendanceCode"]);
	self.gradeTotal = [self stringWithFloatPrecision:[self calculatePreciseFinalScore]];
}


/*****************
 *****************	THIS IS THE HARD LABOR SECTION OF THE APP
 *****************
 *****************
 */

- (CGFloat)totalExtraCreditPoints {
	CGFloat extraCreditPoints = 0;

	/* NOW, we add in the Extra Credit points, if any. I've typically handled it in one of two ways:
	 (a)	The extraCredit score is treated as a *percentage of* the final grade. (grade * ExCrd/100)
	 ... so 5% +* a perfect grade of 100 is 105.  But if the student has a 74, 5% * 74 only adds 3.6 points...
	 ... it rewards good students more, but those who can get all 5 points don't even need them...
	 ... it's a judgement call and really a decision left to the instructor and the course requirements.
	 
	 (b)	The extraCredit score is treated as *raw points* added to the final grade (grade + 5pts)
	 
	 */
	// any extra credit assignments happen here ... 
	
#warning this doesn't work anymore....
	//NSSet *extraCreditSet = [NSSet set];
	NSSet *extraCreditSet = [[self managedObjectContext] fetchObjectsForEntityName:@"CategoryObj" 
																		withPredicate:@"SELF.treatment BEGINSWITH[c] 'Extra'"];
	// if we have extra credit assignments, let's add them up...		
	for (CategoryObj * cat in extraCreditSet) { // loop through all our applicable categories
		NSInteger numberOfAssignments = 0;
		CGFloat catPercent = 0;
		
		for (AssignmentObj *ass in cat.assignments) {
			ScoreObj *score = [self scoreForAssignment:ass];
			if ([score willBeGraded]) {
				numberOfAssignments++;
				
				// penalties and curves added if necessary
				catPercent += ([score curvedScore] / [ass.maxPoints integerValue]);
			}
		}
		
		catPercent = catPercent / numberOfAssignments;			// now take the average of them (if we had several)
		CGFloat percentOfMax = catPercent * [cat.percentOfFinalScore integerValue];	// i.e. "1.0 * 5" = max of 5% of final grade
		//			This is method (a) from above.
		//extraCreditPoints += finalScore * (percentOfMaxEC / 100.0);
		
		//			This is method (b) from above.
		extraCreditPoints += percentOfMax;													// i.e. 94.5 + 5 = 99.5
	}	
	return extraCreditPoints;
}


- (CGFloat)calculatePreciseFinalScore
{
	//NSLog(@"Calculating Grade Total for %@", self.name);

    CGFloat finalScore = 0.0;
    CGFloat maxFinalScore = 0.0;
    CGFloat accumulatedPercent = 0.0;    
    CGFloat sc;
	
	//NSSet *regularSet = [[self managedObjectContext] fetchObjectsForEntityName:@"CategoryObj"];

#warning this doesn't work anymore....

	NSSet *regularSet = [[self managedObjectContext] fetchObjectsForEntityName:@"CategoryObj" 
																	withPredicate:@"NOT (SELF.treatment BEGINSWITH[c] 'Extra')"];
    for(CategoryObj *cat in regularSet)
    {
		CGFloat catScore = 0.0;
		CGFloat maxCatScore = 0.0;
		
		CGFloat lowestScore = 0.0;
		CGFloat lowestMaxScore = 0.0;
		
		BOOL hasGradedAssignments = NO;
		
		for(AssignmentObj *ass in cat.assignments)
        {						
			ScoreObj *score = [self scoreForAssignment:ass];
            
			if ([score willBeGraded]) {
				hasGradedAssignments = YES;
				
				// penalties and curves added if necessary
				sc = [score curvedScore];
				catScore += sc;
				maxCatScore += [ass.maxPoints floatValue];
				
				CGFloat scRatio = sc/[ass.maxPoints floatValue];
				CGFloat lowRatio = lowestScore/lowestMaxScore;
				
				if(!(lowestScore || lowestMaxScore) ||  scRatio < lowRatio)
				{
					lowestScore = sc;
					lowestMaxScore = [ass.maxPoints floatValue];
				}
				else if(scRatio == lowRatio)
				{
					if([ass.maxPoints floatValue] > lowestMaxScore)
					{
						lowestScore = sc;
						lowestMaxScore = [ass.maxPoints floatValue];
					}
				}
			}
		}	// done with assignment loop, now back to the category loop ...
		
		if([cat isTreatment:GRLTreatDropLow])
		{
			catScore -= lowestScore;
			maxCatScore -= lowestMaxScore; 
		}
		
		if([cat.curveEquation length])
			catScore = [[cat curveFunction] evaluateAtX:catScore];
		
		if(!hasGradedAssignments) //no scores were tabulated for this category
			continue;
		
		CGFloat catCalcScore = (catScore / maxCatScore) * [cat.percentOfFinalScore integerValue];
		finalScore += catCalcScore;
		accumulatedPercent += [cat.percentOfFinalScore integerValue];
    }
    	
	maxFinalScore = accumulatedPercent;
	
	//what about the final curve?  See if someone stored a final curve in our preferences within Core Data
	NSManagedObject *parameter = [DocumentPreferences findParameter:@"finalCurve" withContext:[self managedObjectContext]];
	if (parameter) {
		NSString *curveString = [parameter valueForKey:@"value" ];
		GRLFunction *finalCurve = [[GRLFunction alloc] initWithString:curveString];
		finalScore = [finalCurve evaluateAtX:finalScore];
		if (finalCurve) [finalCurve release], finalCurve = nil;
	}
	
	// now go get all our extra credit
	CGFloat extraCredit = [self totalExtraCreditPoints];
		
	CGFloat points = -1000;		// WHAT IS THIS? (I think it's to stop an old divide by zero issue)
	if(maxFinalScore > 0.0) {
		points = 100 * finalScore / maxFinalScore;
		points += extraCredit; // even if we don't have extra credit, it works out the same (zero)
	}
		
	return points;
}

@end
