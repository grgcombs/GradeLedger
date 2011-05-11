//
//  LetterGradeLookup.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "LetterGradeLookup.h"


@implementation LetterGradeLookup

- (id)init
{
    self = [super init];
    if(self)
    {
		[NSValueTransformer setValueTransformer:self forName:@"LetterGradeLookup"];

    }
    return self;
}

- (void)dealloc
{
	[super dealloc];
}
- (void) awakeFromNib {
	[super awakeFromNib];	
	[letterGradeController setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"low" ascending:NO]]];
	[letterGradeController rearrangeObjects];
}


+ (NSMutableArray *)defaultLetterGradeArray {
	NSMutableArray *anArray = [[NSMutableArray alloc] init];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"A+", 
																	 [NSNumber numberWithDouble:96.67], kCFNumberPositiveInfinity, 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"A", 
																	 [NSNumber numberWithDouble:93.33], [NSNumber numberWithFloat:96.66], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"A-", 
																	 [NSNumber numberWithDouble:90.00], [NSNumber numberWithFloat:93.32], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"B+", 
																	 [NSNumber numberWithDouble:86.67], [NSNumber numberWithFloat:89.99], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"B", 
																	 [NSNumber numberWithDouble:83.33], [NSNumber numberWithFloat:86.66], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"B-", 
																	 [NSNumber numberWithDouble:80.00], [NSNumber numberWithFloat:83.32], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"C+", 
																	 [NSNumber numberWithDouble:76.67], [NSNumber numberWithFloat:79.99], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"C", 
																	 [NSNumber numberWithDouble:73.33], [NSNumber numberWithFloat:76.66], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"C-", 
																	 [NSNumber numberWithDouble:70.00], [NSNumber numberWithFloat:73.32], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"D+", 
																	 [NSNumber numberWithDouble:66.67], [NSNumber numberWithFloat:69.99], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"D", 
																	 [NSNumber numberWithDouble:63.33], [NSNumber numberWithFloat:66.66], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"D-", 
																	 [NSNumber numberWithDouble:60.00], [NSNumber numberWithFloat:63.32], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray addObject: [NSMutableDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"F", 
																	 kCFNumberNegativeInfinity, [NSNumber numberWithFloat:59.99], 
																	 nil] forKeys: [NSArray arrayWithObjects:@"grade", @"low", @"hi", nil]]];
	
	[anArray autorelease];
	return anArray;
}


- (NSString *)gradeForScore:(CGFloat)score
{
    NSDictionary *dict;
    
    for(dict in [self.letterGradeController arrangedObjects])
        if(score <= [[dict objectForKey:@"hi"] floatValue] && score >= [[dict objectForKey:@"low"] floatValue])
            return [dict objectForKey:@"grade"];
            
    return @"?";
}

#pragma mark Value Transformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    CGFloat scoreInput;
	
    if (value == nil) return nil;
	
    // Attempt to get a reasonable value from the
    // value object.
    if ([value respondsToSelector: @selector(floatValue)]) {
		// handles NSString and NSNumber
        scoreInput = [value floatValue];
    } else {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Value (%@) does not respond to -floatValue.",
		 [value class]];
    }
	
    return [self gradeForScore:scoreInput];
}


@synthesize letterGradeController;
@end
