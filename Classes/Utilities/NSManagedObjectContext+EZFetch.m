//
//  NSManagedObjectContext+EZFetch.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "NSManagedObjectContext+EZFetch.h"

@implementation NSManagedObjectContext (EZFetch)

// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//

/*
 Obviously, looking up the Entity and building the NSPredicate each time isn't going to be the optimal fast case and other 
 special NSFetchRequest options aren't accessible, but for most other cases, 10 times shorter equals 10 times better.
 
 You'll also realise that since we've removed sorting, all of the objects returned are unique and in no particular order. 
 This is an NSSet, not an NSArray and the return type has been changed accordingly. Creating an NSSet has a slightly higher 
 overhead than creating an NSArray but again, we're considering quick and simple fetches and this approach allows easy 
 testing of set membership in the results (a very useful logic case).
 
*/

- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ...
{    
    return [NSSet setWithArray:[self fetchObjectsArrayForEntityName:newEntityName withPredicate:stringOrPredicate]];
}


- (NSArray *)fetchObjectsArrayForEntityName:(NSString *)newEntityName
						   withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), [stringOrPredicate className]);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
	if (request)
		[request release], request = nil;

    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", [error description]];
    }
    
    return results;
}

- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
	if (request)
		[request release], request = nil;
	
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", [error description]];
    }
    
    return [NSSet setWithArray:results];
}


@end
