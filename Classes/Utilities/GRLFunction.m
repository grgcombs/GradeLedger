//
//  GRLFunction.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLFunction.h"

@implementation GRLFunction

- (id)initWithString:(NSString *)eq
{
    if((self = [super init])) {
        equation = [eq retain];
	}
    return self;
}

- (void)dealloc
{
    [equation autorelease];
    [super dealloc];
}

- (CGFloat)evaluateAtX:(CGFloat)x
{
    if(![equation length])
        return x;

    char gs[5120];
   
	[[[equation componentsSeparatedByString:@"x"] componentsJoinedByString:[NSString stringWithFormat:@"%f",x]] getCString:gs maxLength:5119 encoding:NSUTF8StringEncoding];
    CGFloat ans = x;
    evaluate(gs, &ans);

    return ans;

}

- (NSString *)description
{
    return equation;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:equation forKey:@"equation"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if((self = [super init])) {
        equation = [[coder decodeObjectForKey:@"equation"] retain];
	}
    return self;
}

@synthesize equation;
@end
