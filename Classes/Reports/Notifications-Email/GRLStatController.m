//
//  GRLStatController.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLStatController.h"
#import "StudentObj.h"
#import "ScoreObj.h"
#import "AssignmentObj.h"
#import "DateUtils.h"
#import "CategoryObj.h"

@implementation GRLStatController

- (id)init
{
    if((self = [super init])) {
	}
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (NSArray *)students
{
    NSMutableArray *studArray = [NSMutableArray array];

	for (NSMenuItem *item in [students itemArray]) {
		if (![item isSeparatorItem] && [item state])
			[studArray addObject:[[self.data.studentController arrangedObjects] objectAtIndex:[item tag]]];
	}
	        
    return studArray;
}

- (NSArray *)assignments
{
    if([assesVsCats selectedRow] == 0)
    {
        NSMutableArray *assArray = [NSMutableArray array];

		for (NSMenuItem *item in [assignments itemArray]) {
			if (![item isSeparatorItem] && [item state])
				[assArray addObject:[[self.data allAssignmentsSortedByDueDate] objectAtIndex:[item tag]]];
		}
		            
        return assArray;
    }
    else if([assesVsCats selectedRow] == 1)
    {
        NSMutableArray *assArray = [NSMutableArray array];
            
        for (CategoryObj * cat in [self categories])
            [assArray addObjectsFromArray:[cat.assignments allObjects]];
            
        return assArray;
    }
    else
        return nil;
}

- (NSArray *)categories
{
    NSMutableArray *catArray = [NSMutableArray array];

	for (NSMenuItem *item in [categories itemArray]) {
		if (![item isSeparatorItem] && [item state])
			[catArray addObject:[[self.data allCategoriesSortedByName] objectAtIndex:[item tag]]];
	}
	        
    return catArray;
}

- (IBAction)calculateStatistics:(id)sender
{
    NSEnumerator *cellEnum = [[statOptions cells] objectEnumerator];
    NSCell *cell;
    
    NSArray *studArray = [self students];
    NSArray *assArray = [self assignments];
    
    [meanText setStringValue:@""];
    [medianText setStringValue:@""];
    [sdText setStringValue:@""];
    [varText setStringValue:@""];
    
    while((cell = [cellEnum nextObject]))
    {
        if(![cell state])
            continue;
    
        double result = 0;
    
        switch([cell tag])
        {
            case 0: result = [self meanWithStudents:studArray assignments:assArray];
                    [meanText setStringValue:[NSString stringWithFormat:@"%.1f%%",result]];
                    break;
            case 1: result = [self modeWithStudents:studArray assignments:assArray];
                    [modeText setStringValue:[NSString stringWithFormat:@"%.1f%%",result]];
                    break;
            case 2: result = [self medianWithStudents:studArray assignments:assArray];
                    [medianText setStringValue:[NSString stringWithFormat:@"%.1f%%",result]];
                    break;
            case 3: result = [self standardDeviationWithStudents:studArray assignments:assArray];
                    [sdText setStringValue:[NSString stringWithFormat:@"%.1f%%",result]];
                    break;
            case 4: result = [self varianceWithStudents:studArray assignments:assArray];
                    [varText setStringValue:[NSString stringWithFormat:@"%.1f%%",result]];
                    break;
            case 5: result = [self maximumWithStudents:studArray assignments:assArray];
                    [maxText setStringValue:[NSString stringWithFormat:@"%.1f%%",result]];
                    break;
            case 6: result = [self minimumWithStudents:studArray assignments:assArray];
                    [minText setStringValue:[NSString stringWithFormat:@"%.1f%%",result]];
                    break;
            default: //result = 0;
                     break;
        }
    }
}

- (IBAction)matrixSelectionChanged:(id)sender
{
    if([assesVsCats selectedRow] == 0)
    {
        [assignments setEnabled:YES];
        [categories setEnabled:NO];
        [finalScore setEnabled:NO];
    }
    else if([assesVsCats selectedRow] == 1)
    {
        [assignments setEnabled:NO];
        [categories setEnabled:YES];
        [finalScore setEnabled:NO];
    }
    else
    {
        [assignments setEnabled:NO];
        [categories setEnabled:NO];
        [finalScore setEnabled:YES];
    }
}

- (double)meanWithStudents:(NSArray *)studs assignment:(AssignmentObj *)ass
{
    double totalPoints = 0;
    NSInteger studCount = [studs count];

    for(StudentObj *stud in studs)
    {
        if(ass)
        {
			ScoreObj *score = [stud scoreForAssignment:ass];
			NSDictionary *dict = [score calculateAssignmentScoreWithPrefs:self.prefs];
			double scoreFloat = 0;
			NSString *scoreStr;
				
			if([[score collectionCode] integerValue] == GRLExcused)
			{
				studCount--;
				continue;
			}
			else if((scoreStr = [dict objectForKey:@"curved"]))
				scoreFloat = [scoreStr doubleValue];
			else
				scoreFloat = [[dict objectForKey:@"raw"] doubleValue];
            
			totalPoints += scoreFloat;
		}
		else
		{
			totalPoints += [stud.gradeTotal doubleValue];
		}
	}
	
	return totalPoints/studCount;
}

- (double)meanWithStudents:(NSArray *)studs assignments:(NSArray *)asses
{
    if(!asses) //final score
        return [self meanWithStudents:studs assignment:nil];
    
    double totalPoints = 0;
    NSInteger maxPoints = 0;
    
    for(AssignmentObj *ass in asses)
    {
        double score = [self meanWithStudents:studs assignment:ass];
        
        totalPoints += score;
        maxPoints += [[ass maxPoints] integerValue];
    }
    
    return 100*(totalPoints)/maxPoints;
}

- (double)modeWithStudents:(NSArray *)studs assignment:(AssignmentObj *)ass count:(NSInteger *)count
{
    double theMode = 0;
    NSInteger theCount = 0;
    
    NSInteger studCount = [studs count];
    NSMutableArray *array = [NSMutableArray array];

    for(StudentObj *stud in studs)
    {
        if(ass)
        {
			ScoreObj *score = [stud scoreForAssignment:ass];
			NSDictionary *dict = [score calculateAssignmentScoreWithPrefs:self.prefs];
            
            double scoreFloat = 0;
            double max = [[ass maxPoints] doubleValue];
            NSString *scoreStr;
            
            if([[score collectionCode] integerValue] == GRLExcused)
            {
                studCount--;
                continue;
            }
            else if((scoreStr = [dict objectForKey:@"curved"]))
                scoreFloat = [scoreStr doubleValue];
            else
                scoreFloat = [[dict objectForKey:@"raw"] doubleValue];
            
            [array addObject:[NSNumber numberWithDouble:100*scoreFloat/max]];
        }
        else
        {            
            [array addObject:[NSNumber numberWithDouble:[stud.gradeTotal doubleValue]]];
        }
    }
    
    [array sortUsingSelector:@selector(compare:)];
    
    NSNumber *num;
    
    double lastNum = NSNotFound;
    NSInteger lastCount = 0;
    
    for(num in array)
    {
        if(lastNum == (double)NSNotFound)
        {
            lastNum = [num doubleValue];
            lastCount++;
        }
        else if([num doubleValue] == lastNum)
        {
            lastCount++;
        }
        else
        {
            if(lastCount > theCount)
            {
                theMode = lastNum;
                theCount = lastCount;
            }
            
            lastNum = [num doubleValue];
            lastCount = 1;
        }
    }
    
    if(lastCount > theCount)
    {
        theMode = lastNum;
        theCount = lastCount;
    }
    
    (*count) = theCount;
    return theMode;
}

- (double)modeWithStudents:(NSArray *)studs assignments:(NSArray *)asses
{
    NSInteger count;

    if(!asses)
        return [self modeWithStudents:studs assignment:nil count:&count];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for(AssignmentObj *ass in asses)
    {
        double score = [self modeWithStudents:studs assignment:ass count:&count];
        
        if(score != (double)NSNotFound)
            [array addObject:[NSNumber numberWithDouble:score]];
    }
    
    [array sortUsingSelector:@selector(compare:)];
    
    if(![array count])
        return NSNotFound;
        
    double theMode = NSNotFound;
    NSInteger theCount = 0;
    
    NSNumber *num;
    
    double lastNum = NSNotFound;
    NSInteger lastCount = 0;
    
    for(num in array)
    {
        if(lastNum == (double)NSNotFound)
        {
            lastNum = [num doubleValue];
            lastCount++;
        }
        else if([num doubleValue] == lastNum)
        {
            lastCount++;
        }
        else
        {
            if(lastCount > theCount)
            {
                theMode = lastNum;
                theCount = lastCount;
            }
            
            lastNum = [num doubleValue];
            lastCount = 1;
        }
    }
    
    if(lastCount > theCount)
    {
        theMode = lastNum;
        //theCount = lastCount;
    }
    
    return theMode;
}

- (double)medianWithStudents:(NSArray *)studs assignment:(AssignmentObj *)ass
{
    NSInteger studCount = [studs count];
    
    NSMutableArray *array = [NSMutableArray array];

    for(StudentObj *stud in studs)
    {
        if(ass)
        {
			ScoreObj *score = [stud scoreForAssignment:ass];
			NSDictionary *dict = [score calculateAssignmentScoreWithPrefs:self.prefs];
            
            double scoreFloat = 0;
            NSString *scoreStr;
            
            if([[score collectionCode] integerValue] == GRLExcused)
            {
                studCount--;
                continue;
            }
            else if((scoreStr = [dict objectForKey:@"curved"]))
                scoreFloat = [scoreStr doubleValue];
            else
                scoreFloat = [[dict objectForKey:@"raw"] doubleValue];
            
            [array addObject:[NSNumber numberWithDouble:100*scoreFloat/[ass.maxPoints doubleValue]]];
        }
        else
        {
            [array addObject:[NSNumber numberWithDouble:[stud.gradeTotal doubleValue]]];
        }
    }
    
    [array sortUsingSelector:@selector(compare:)];
    
    if(!studCount)
        return NSNotFound;
    
    return [[array objectAtIndex:studCount/2] doubleValue];
}

- (double)medianWithStudents:(NSArray *)studs assignments:(NSArray *)asses
{
    if(!asses)
        return [self medianWithStudents:studs assignment:nil];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for(AssignmentObj *ass in asses)
    {
        double score = [self medianWithStudents:studs assignment:ass];
        
        if(score != (double)NSNotFound)
            [array addObject:[NSNumber numberWithDouble:score]];
    }
    
    [array sortUsingSelector:@selector(compare:)];
    
    if(![array count])
        return NSNotFound;
    
    return [[array objectAtIndex:[array count]/2] doubleValue];
}

- (double)varianceWithStudents:(NSArray *)studs assignment:(AssignmentObj *)ass
{
    double totalPoints = 0;
    double average = [self meanWithStudents:studs assignment:ass];

    NSInteger studCount = [studs count];

    for(StudentObj *stud in studs)
    {
        if(ass)
        {
			ScoreObj *scoreObj = [stud scoreForAssignment:ass];
			NSDictionary *dict = [scoreObj calculateAssignmentScoreWithPrefs:self.prefs];
            
            double score = 0;
            NSString *scoreStr;
            
            if([[scoreObj collectionCode] integerValue] == GRLExcused)
            {
                studCount--;
                continue;
            }
            else if((scoreStr = [dict objectForKey:@"curved"]))
                score = [scoreStr doubleValue];
            else
                score = [[dict objectForKey:@"raw"] doubleValue];
            
            totalPoints += pow(score - average,2);
        }
        else
        {
            double score = [stud.gradeTotal doubleValue];
            
            totalPoints += pow(score - average,2);
        }
    }
    
    //very little variance, no?
    if(studCount == 1)
        return 0;
    
    return totalPoints/(studCount-1);
}

- (double)varianceWithStudents:(NSArray *)studs assignments:(NSArray *)asses
{
    if(!asses)
        return [self varianceWithStudents:studs assignment:nil];
    
    double totalVar = 0;
    
    for(AssignmentObj *ass in asses)
    {
        double var = [self varianceWithStudents:studs assignment:ass];
        
        if([ass.maxPoints integerValue] > 0)
            totalVar += 100*var/[ass.maxPoints doubleValue];
    }
    
    return totalVar/[asses count];
}

- (double)standardDeviationWithStudents:(NSArray *)studs assignments:(NSArray *)asses
{
    return sqrt([self varianceWithStudents:studs assignments:asses]);
}

- (double)minimum:(BOOL)isMin withStudents:(NSArray *)studs assignment:(AssignmentObj *)ass
{
    double theScore = NSNotFound;
    
    NSInteger studCount = [studs count];

    for(StudentObj *stud in studs)
    {
        if(ass)
        {
			ScoreObj *scoreObj = [stud scoreForAssignment:ass];
			NSDictionary *dict = [scoreObj calculateAssignmentScoreWithPrefs:self.prefs];
            
            double score = 0;
            double max = [[ass maxPoints] doubleValue];
            double percent;
            NSString *scoreStr;
            
            if([[scoreObj collectionCode] integerValue] == GRLExcused)
            {
                studCount--;
                continue;
            }
            else if((scoreStr = [dict objectForKey:@"curved"]))
                score = [scoreStr doubleValue];
            else
                score = [[dict objectForKey:@"raw"] doubleValue];
                
            percent = 100*score/max;
            
            if(max == 0)
            {
                if(score == 0)
                    percent = 0;
                else
                    percent = INFINITY;
            }
            
            if(theScore == NSNotFound || (percent < theScore && isMin) || (percent > theScore && !isMin))
                theScore = percent;
        }
        else
        {
            double score = [stud.gradeTotal doubleValue];
            
            if(theScore == NSNotFound || ((score < theScore && isMin) || (score > theScore && !isMin)))
                theScore = score;
        }
    }
    
    return theScore;
}

- (double)minimumWithStudents:(NSArray *)studs assignments:(NSArray *)asses
{
    if(!asses)
        return [self minimum:YES withStudents:studs assignment:nil];
    
    double theScore = NSNotFound;
    
    for(AssignmentObj *ass in asses)
    {
        double var = [self minimum:YES withStudents:studs assignment:ass];
        
        if(theScore == NSNotFound || var < theScore)
            theScore = var;
    }
    
    return theScore;
}

- (double)maximumWithStudents:(NSArray *)studs assignments:(NSArray *)asses
{
    if(!asses)
        return [self minimum:NO withStudents:studs assignment:nil];
    
    double theScore = NSNotFound;
    
    for(AssignmentObj *ass in asses)
    {
        double var = [self minimum:NO withStudents:studs assignment:ass];
        
        if(theScore == NSNotFound || var > theScore)
            theScore = var;
    }
    
    return theScore;
}

- (IBAction)popUpButtonAction:(id)sender
{
    NSInteger selectIndex = [sender indexOfSelectedItem];
    NSInteger count = [[sender itemArray] count];
    
    if(selectIndex >= count-2)
    {
		//mark the rest as on state
		for (id item in [sender itemArray]) {
			if (![item isSeparatorItem])
				[item setState:(selectIndex == count-2)];
		}
			
    }
    else
    {
        NSMenuItem *item = [sender selectedItem];
        [item setState:![item state]];
    }
}

- (void)runStatsSheet
{
    if(![[self.data.studentController arrangedObjects] count] || ![[self.data.assignmentController arrangedObjects] count])
    {
        NSRunAlertPanel(@"Statistics Error",
                        @"You need to have at least one student and one assignment to do any kind of statistical analysis.",
                        nil,
                        nil,
                        nil);
        return;
    }

    NSInteger index = 1;
	
    while(![[students itemAtIndex:index] isSeparatorItem])
	{   [students removeItemAtIndex:index]; index++; }
        
	index = 1;
    while(![[categories itemAtIndex:index] isSeparatorItem])
	{	[categories removeItemAtIndex:index]; index++; }
        
	index = 1;
    while(![[assignments itemAtIndex:index] isSeparatorItem])
    {  [assignments removeItemAtIndex:index]; index++; }
           
    NSEnumerator *objEnum;
    id obj;
    NSString *title;
	

    objEnum = [[self.data allStudentsSortedByName] reverseObjectEnumerator];
    index = [[self.data allStudentsSortedByName] count] - 1;
    while((obj = [objEnum nextObject]))
    {
        title = [obj name];
        while([students indexOfItemWithTitle:title] != -1)
            title = [NSString stringWithFormat:@"%@ ",title];
        
        [students insertItemWithTitle:title atIndex:1];
        [[students itemAtIndex:1] setTag:index];
        index--;
    }
    
    objEnum = [[self.data allCategoriesSortedByName] reverseObjectEnumerator];
    index = [[self.data allCategoriesSortedByName] count] - 1;
    while((obj = [objEnum nextObject]))
    {
        title = [obj name];
        while([categories indexOfItemWithTitle:title] != -1)
            title = [NSString stringWithFormat:@"%@ ",title];
        
        [categories insertItemWithTitle:title atIndex:1];
        [[categories itemAtIndex:1] setTag:index];
        index--;
    }
    
    objEnum = [[self.data allAssignmentsSortedByDueDate] reverseObjectEnumerator];
    index = [[self.data allAssignmentsSortedByDueDate] count] - 1;
    while((obj = [objEnum nextObject]))
    {
        title = [obj name];
        while([assignments indexOfItemWithTitle:title] != -1)
            title = [NSString stringWithFormat:@"%@ ",title];
        
        [assignments insertItemWithTitle:title atIndex:1];
        [[assignments itemAtIndex:1] setTag:index];
        index--;
    }
    
    [NSApp beginSheet:statsSheet
           modalForWindow:docWindow
           modalDelegate:nil
           didEndSelector:nil
           contextInfo:nil];
        
}

- (IBAction)dismissStatsSheet:(id)sender
{
    [NSApp endSheet:statsSheet];
    [statsSheet orderOut:nil];
}

@synthesize data;
@synthesize prefs;
@synthesize docWindow;
@synthesize statsSheet;
@synthesize statOptions;
@synthesize finalScore;
@synthesize assesVsCats;
@end
