// 
//  NotesObj.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "NotesObj.h"

@interface NotesObj (PrimitiveAccessors)  
- (NSDate *)primitiveDate;  
- (void)setPrimitiveDate:(NSDate *)newDate;  
@end  

@implementation NotesObj 

@dynamic date;
@dynamic title;
@dynamic body;
@dynamic displayDate;

- (void) awakeFromInsert {
	[super awakeFromInsert];
	[self setValue:[NSDate date] forKey:@"date"];
}

- (NSString *)displayDate {
	[self willAccessValueForKey:@"date"];
	NSString *aString = [NSDate stringForDisplayFromDate:[self primitiveDate]];
	[self didAccessValueForKey:@"date"];
	return aString;
}
  

@end
