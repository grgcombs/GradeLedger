//
//  NSManagedObjectContext+EZFetch.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//  Originated from Matt Gallagher
//  http://cocoawithlove.com/2008/03/core-data-one-line-fetch.html
//


/*
 [[self managedObjectContext] fetchObjectsForEntityName:@"Employee" 
		withPredicate:
			@"(lastName LIKE[c] 'Worsley') AND (salary > %@)", minimumSalary];
*/

@interface NSManagedObjectContext (EZFetch)
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
					   withPredicate:(id)stringOrPredicate, ...;

- (NSArray *)fetchObjectsArrayForEntityName:(NSString *)newEntityName
							  withPredicate:(id)stringOrPredicate, ...;

- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName;
@end

