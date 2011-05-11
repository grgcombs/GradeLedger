//
//  AssignmentObj.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

@class CategoryObj;
@class ScoreObj;
@class GRLFunction;

@interface AssignmentObj :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * curveEquation;
@property (nonatomic, retain) NSNumber * maxPoints;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CategoryObj * category;
@property (nonatomic, retain) NSSet* scores;

// For Copy/Paste Support
- (NSDictionary *)exportDictionary;

+ (NSArray *)keysToBeCopied;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)stringDescription;

+ (AssignmentObj *)insertNewAssignmentWithContext:(NSManagedObjectContext *)context;

- (GRLFunction *)curveFunction;

- (BOOL)validateForInsert:(NSError **)error;
- (BOOL)isAttendance;
- (BOOL)isExtraCredit;

@end


@interface AssignmentObj (CoreDataGeneratedAccessors)
- (void)addScoresObject:(ScoreObj *)value;
- (void)removeScoresObject:(ScoreObj *)value;
- (void)addScores:(NSSet *)value;
- (void)removeScores:(NSSet *)value;

@end

