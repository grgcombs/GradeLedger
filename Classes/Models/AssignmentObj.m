// 
//  AssignmentObj.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "AssignmentObj.h"

#import "CategoryObj.h"
#import "ScoreObj.h"
#import "GRLFunction.h"
#import "NSDate+Helper.h"

@implementation AssignmentObj 

@dynamic curveEquation;
@dynamic maxPoints;
@dynamic dueDate;
@dynamic name;
@dynamic category;
@dynamic scores;

+ (AssignmentObj *)insertNewAssignmentWithContext:(NSManagedObjectContext *)context {	
	NSManagedObjectModel *managedObjectModel = [[context persistentStoreCoordinator] managedObjectModel];
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:@"AssignmentObj"];
	AssignmentObj *newObject = (AssignmentObj *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	return [newObject autorelease];
}

- (BOOL)validateForInsert:(NSError **)error {
	if ([self isAttendance])
		if ([[self.category valueForKeyPath:@"assignments.@count"] integerValue] > 1)
			return NO;
	return YES;
}



+ (NSArray *)keysToBeCopied {
    static NSArray *keysToBeCopied = nil;
    if (keysToBeCopied == nil) {
        keysToBeCopied = [[NSArray alloc] initWithObjects:
						  @"curveEquation", @"maxPoints", @"dueDate", @"name", @"category", nil];
    }
    return keysToBeCopied;
}

- (NSDictionary *)dictionaryRepresentation {
    return [self dictionaryWithValuesForKeys:[[self class] keysToBeCopied]];
}

- (NSDictionary *)exportDictionary {
	NSArray *props = [[NSArray alloc] initWithObjects:@"curveEquation", @"maxPoints", @"dueDate", @"name", nil];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithValuesForKeys:props]];
	NSDate *tempDate = self.dueDate;
	if (tempDate) {
		[dict setObject:[tempDate timestampString] forKey:@"dueDate"];
	}
	
	[props release];
	
    return dict;
}

- (NSString *)stringDescription {
    NSString *stringDescription = self.name;
    NSString *categoryString = @"none";
    CategoryObj *aCategory = self.category;
    if (aCategory != nil) {
        categoryString = aCategory.name;
    }
    stringDescription = [stringDescription stringByAppendingFormat:
						 @"; Category: %@", categoryString];
    return stringDescription;
}

- (GRLFunction *)curveFunction
{
    if(![self.curveEquation length])
        return nil;

	return [[[GRLFunction alloc] initWithString:self.curveEquation] autorelease];	
}

- (BOOL)isAttendance {
	return [self.category isAttendance];
}

- (BOOL)isExtraCredit {
	return [self.category isExtraCredit];
}

@end
