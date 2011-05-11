//
//  GRLTextObject.h
//  GradeLedger by Gregory S. Combs, based on work at https://github.com/grgcombs/GradeLedger
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import "GRLDrawObject.h"

@interface GRLTextObject : GRLDrawObject
{
    NSString *string;
    NSDictionary *attributes;
    NSRect rect;
}

- (id)initWithString:(NSString *)str attributes:(NSDictionary *)attrs rect:(NSRect)drawRect pageNumber:(NSInteger)num;
+ (id)textObjectWithString:(NSString *)str attributes:(NSDictionary *)atr rect:(NSRect)drawRect pageNumber:(NSInteger)num;

@property (nonatomic, retain) NSString *string;
@property (nonatomic, retain) NSDictionary *attributes;
@end
