//
//  ScoreObj.h
//  GradeLedger
//
//  Created by Gregory Combs on 4/16/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

@class AssignmentObj;
@class StudentObj;
@class DocumentPreferences;

@interface ScoreObj :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * collectionCode;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * collectionDate;
@property (nonatomic, retain) AssignmentObj * assignment;
@property (nonatomic, retain) StudentObj * student;
@property (readonly) CGFloat curvedScore;
@property (readonly) CGFloat rawScore;

- (NSDictionary *)exportDictionary;
- (NSString *)collectionString;
- (NSString *)abbreviatedCollectionString;
+ (GRLCode)codeForString:(NSString *)string;

+ (ScoreObj *)insertNewScoreWithStudent:(StudentObj*)aStud andContext:(NSManagedObjectContext *)context;

- (BOOL)validScore;
- (BOOL)willBeGraded;

- (NSColor *)cellColorWithPrefs:(DocumentPreferences *)prefs;
- (CGFloat)attendanceScoreWithPrefs:(DocumentPreferences *)preferences;
- (NSDictionary *)calculateAssignmentScoreWithPrefs:(DocumentPreferences *)preferences ;


@end



