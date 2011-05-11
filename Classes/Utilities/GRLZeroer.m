//
//  GRLZeroer.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLZeroer.h"
#import "StudentObj.h"
#import "AssignmentObj.h"
#import "DateUtils.h"
#import "ScoreObj.h"

@implementation GRLZeroer

- (id)init
{
    if((self = [super init]))
	{
	}
	return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void)zeroAllBlankScores
{
    [self zeroAllBlankScoresOnAssignments:[data.assignmentController arrangedObjects] ifLate:NO];
}

- (void)zeroAllLateBlankScores
{
    [self zeroAllBlankScoresOnAssignments:[data.assignmentController arrangedObjects] ifLate:YES];
}

- (void)zeroAllBlankScoresOnAssignments:(NSArray *)asses ifLate:(BOOL)lateMatters
{    
    NSDate *today = [DateUtils today];
    
    for(StudentObj *stud in [self.data.studentController arrangedObjects])
    {
        
        for(AssignmentObj * ass in [self.data.assignmentController arrangedObjects])
        {
            NSDate *dueDate = [ass dueDate];
            ScoreObj *score = [stud scoreForAssignment:ass];
            
            if( ![score validScore] &&
                (!lateMatters || lateMatters && ((dueDate != nil && [dueDate isEarlierThanDate:today]) || 
                                 ([score.collectionCode integerValue] == GRLLate))))
            {
				score.score = [NSNumber numberWithInteger:0];
				// we don't need the return, but that's there in case we ever do...
            } 
        }
    }
}

@synthesize data;
@end
