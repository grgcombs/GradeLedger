// 
//  CategoryObj.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "CategoryObj.h"

#import "AssignmentObj.h"
#import "GRLFunction.h"

@implementation CategoryObj 

@dynamic curveEquation;
@dynamic percentOfFinalScore;
@dynamic treatment;
@dynamic totalPoints;
@dynamic name;
@dynamic assignments;
@dynamic canAddAssignment;


+ (CategoryObj *)insertNewCategoryWithContext:(NSManagedObjectContext *)context {	
	NSManagedObjectModel *managedObjectModel = [[context persistentStoreCoordinator] managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:@"CategoryObj"];
	CategoryObj *newObject = (CategoryObj *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	return [newObject autorelease];
}


- (NSNumber *)canAddAssignment 
{
    NSNumber * boolNum = [NSNumber numberWithBool:YES];
    
    [self willAccessValueForKey:@"canAddAssignment"];
    
	if ([self isAttendance] && [[self valueForKeyPath:@"assignments.@count"] integerValue] > 0)		
		boolNum = [NSNumber numberWithBool:NO];
	
    [self didAccessValueForKey:@"canAddAssignment"];
    
    return boolNum;
}


- (BOOL)validateCanAddAssignment:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}



- (GRLFunction *)curveFunction
{
    if(![self.curveEquation length])
        return nil;
	
	return [[[GRLFunction alloc] initWithString:self.curveEquation] autorelease];	
}


- (BOOL) isTreatment:(GRLCatTreatment)aTreat {
	BOOL itIs = NO;
	
	switch (aTreat) {
		case GRLTreatNone:
			itIs = [self.treatment isEqualToString:@"Normal"];
			break;
		case GRLTreatDropLow:
			itIs = [self.treatment hasPrefix:@"Drop Low"];
			break;
		case GRLTreatAttend:
			itIs = [self.treatment hasPrefix:@"Attendance"];
			break;
		case GRLTreatExCred:
			itIs = [self.treatment hasPrefix:@"Extra"];
			break;
		default:
			itIs = NO;
			break;
	}
	return itIs;
}

- (NSNumber *) totalPoints {
	[self willAccessValueForKey:@"totalPoints"];
	NSNumber *total = [self valueForKeyPath:@"assignments.@sum.maxPoints"];	
	[self didAccessValueForKey:@"totalPoints"];
	return total;
}

+ (NSArray *)keysToBeCopied {
    static NSArray *keysToBeCopied = nil;
    if (keysToBeCopied == nil) {
        keysToBeCopied = [[NSArray alloc] initWithObjects:
						  @"curveEquation", @"percentOfFinalScore", @"treatment", @"name", nil];
    }
    return keysToBeCopied;
}

- (NSDictionary *)dictionaryRepresentation {
    return [self dictionaryWithValuesForKeys:[[self class] keysToBeCopied]];
}

- (NSString *)stringDescription {
    NSString *stringDescription = self.name;
    NSString *treatmentString = self.treatment;
    NSString *weightString = [self.percentOfFinalScore stringValue];
    stringDescription = [stringDescription stringByAppendingFormat:
						 @"; Treatment: %@; Grade Weight: %@", treatmentString, weightString];
    return stringDescription;
}

- (BOOL)isAttendance {
	return [self isTreatment:GRLTreatAttend];
}

- (BOOL)isExtraCredit {
	return [self isTreatment:GRLTreatExCred];
}

@end
