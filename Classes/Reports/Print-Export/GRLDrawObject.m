//
//  GRLDrawObject.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLDrawObject.h"


@implementation GRLDrawObject

- (id)init
{
    if((self = [super init])) {
        pageNumber = 0;
	}
    return self;
}

- (void)drawWithPageCount:(NSInteger)count
{
    //nada
}

@synthesize pageNumber;
@end
