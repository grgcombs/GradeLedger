//
//  NSColor-Additions.m
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "NSColor-Additions.h"


@implementation NSColor (Additions)

- (NSString *)hexForFloat:(CGFloat)fl
{
    NSString *string = [NSString string];
    
    NSInteger f = fl * 255;
    
    while(f >= 1)
    {
        NSInteger rem = f % 16;
        NSString *hex = nil;
        
        if(rem < 10)
            hex = [NSString stringWithFormat:@"%d",rem];
        else if(rem == 10)
            hex = @"A";
        else if(rem == 11)
            hex = @"B";
        else if(rem == 12)
            hex = @"C";
        else if(rem == 13)
            hex = @"D";
        else if(rem == 14)
            hex = @"E";
        else if(rem == 15)
            hex = @"F";
        
        string = [NSString stringWithFormat:@"%@%@",hex,string];
        f /= 16;
    }
    
    return string;
}

- (NSString *)hexForColor
{
    CGFloat red, green, blue, alpha;
    
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [NSString stringWithFormat:@"%@%@%@",
                     [self hexForFloat:red],
                     [self hexForFloat:green],
                     [self hexForFloat:blue]];
}

@end
