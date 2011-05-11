//
//  CategoryObj.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

@class AssignmentObj;
@class GRLFunction;

@interface CategoryObj :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * curveEquation;
@property (nonatomic, readonly) NSNumber * canAddAssignment;
@property (nonatomic, retain) NSNumber * percentOfFinalScore;
@property (nonatomic, retain) NSString * treatment;
@property (nonatomic, readonly) NSNumber * totalPoints;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* assignments;

// For Copy/Paste Support
+ (NSArray *)keysToBeCopied;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)stringDescription;

- (BOOL)isTreatment:(GRLCatTreatment)aTreat;
- (GRLFunction *)curveFunction;

+ (CategoryObj *)insertNewCategoryWithContext:(NSManagedObjectContext *)context;

- (BOOL)isAttendance;
- (BOOL)isExtraCredit;
	
@end


@interface CategoryObj (CoreDataGeneratedAccessors)
- (void)addAssignmentsObject:(AssignmentObj *)value;
- (void)removeAssignmentsObject:(AssignmentObj *)value;
- (void)addAssignments:(NSSet *)value;
- (void)removeAssignments:(NSSet *)value;

@end

