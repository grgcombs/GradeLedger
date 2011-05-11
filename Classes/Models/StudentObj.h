//
//  StudentObj.h
//  GradeLedger
//
//  Created by Gregory Combs on 4/17/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

@class AttendanceForDate;
@class ScoreObj;
@class AssignmentObj;
@class StudentAttributes;

@interface StudentObj :  NSManagedObject  
{
}


@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * studentID;
@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) NSString * lastNameFirst;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet* scores;
@property (nonatomic, retain) NSSet* attendanceForDates;
@property (nonatomic, retain) NSSet* studentAttributes;
@property (nonatomic, retain) NSImage * image;

@property (nonatomic, readonly) NSNumber * attendanceAbsences;
@property (nonatomic, readonly) NSNumber * attendanceExcused;
@property (nonatomic, readonly) NSNumber * attendanceTardies;

@property (nonatomic, retain) NSString * gradeTotal;

//- (NSComparisonResult)compareStudentsByName:(StudentObj *)p;

//////////////// ATTENDANCE
- (NSUInteger)numberOfDaysWithAttendanceCode:(GRLCode)aCode;
- (NSArray *)attendanceSortedByDate;

- (void)setAttendanceWithString:(NSString *)aString forDate:(NSDate *)aDate;
- (AttendanceForDate *)attendanceForDate:(NSDate *)aDate;
- (AttendanceForDate *)blankAttendanceForDate:(NSDate *)aDate;

//////////////// SCORES


// creates a new empty score
- (ScoreObj *)blankScoreForAssignment:(AssignmentObj *)anAssignment;
- (ScoreObj *)scoreForAssignment:(AssignmentObj *)anAssignment;


// For Copy/Paste Support
- (NSDictionary *)exportDictionary;
+ (NSArray *)keysToBeCopied;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)stringDescription;
	
- (IBAction)refreshGradeTotal:(id)sender;

+ (StudentObj *)insertNewStudentWithContext:(NSManagedObjectContext *)context;

@end


@interface StudentObj (CoreDataGeneratedAccessors)
- (void)addScoresObject:(ScoreObj *)value;
- (void)removeScoresObject:(ScoreObj *)value;
- (void)addScores:(NSSet *)value;
- (void)removeScores:(NSSet *)value;

- (void)addAttendanceForDatesObject:(AttendanceForDate *)value;
- (void)removeAttendanceForDatesObject:(AttendanceForDate *)value;
- (void)addAttendanceForDates:(NSSet *)value;
- (void)removeAttendanceForDates:(NSSet *)value;

- (void)addStudentAttributesObject:(StudentAttributes *)value;
- (void)removeStudentAttributesObject:(StudentAttributes *)value;
- (void)addStudentAttributes:(NSSet *)value;
- (void)removeStudentAttributes:(NSSet *)value;
@end

